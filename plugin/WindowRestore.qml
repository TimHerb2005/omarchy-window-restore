import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui
import "WindowRestoreModel.js" as Model

// Native settings + picker overlay for Window Restore, replacing the
// omarchy-menu-select/omarchy-menu-input-driven menus from
// hypr-restore-settings/hypr-restore-picker with a first-class Quickshell
// UI. All state is read reactively from the same cache files those Python
// scripts already own (~/.cache/hypr-restore-*), and every write goes back
// through them (`hypr-restore-settings <action> <value>`,
// `hypr-restore-picker --restore N`) so there is exactly one place that
// mutates history/hidden/config — this file only renders it and forwards
// user input.
Item {
  id: root

  property string homePath: Quickshell.env("HOME")
  property string settingsCli: root.homePath + "/.local/bin/hypr-restore-settings"
  property string pickerCli: root.homePath + "/.local/bin/hypr-restore-picker"

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string mode: "relaunch"
  property var config: ({})
  property var history: []
  property var hidden: []
  property var openWindowRows: []

  // "settings" (SUPER+D) or "picker" (SUPER+ALT+R) — which entry point was summoned.
  property string rootView: "settings"
  // Navigation stack for the settings tree, e.g. ["main", "settings", "exclusions"].
  property var viewStack: ["main"]
  property var rows: []
  property int selectedIndex: 0

  // Modal freeform text entry (max windows / hide workspace / exclusion class),
  // layered on top of whatever view is current rather than pushed onto the
  // stack — submitting or cancelling it returns to that same view.
  property bool inputMode: false
  property string inputPrompt: ""
  property string inputTarget: ""
  property string filterText: ""

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int rowHeight: Math.max(Style.space(40), Style.font.body + Style.spacing.rowPaddingX * 2)
  property int cardWidth: Math.min(Style.space(420), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(480), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }

    root.rootView = payload.view === "picker" ? "picker" : "settings"
    root.viewStack = [root.rootView === "picker" ? "picker" : "main"]
    root.opened = true
    root.selectedIndex = 0
    root.inputMode = false
    root.filterText = ""
    root.rebuildRows()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "io.github.timherb2005.window-restore")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function currentView() {
    return root.viewStack[root.viewStack.length - 1]
  }

  function push(view) {
    root.viewStack = root.viewStack.concat([view])
    root.selectedIndex = 0
    root.rebuildRows()
  }

  function pop() {
    if (root.viewStack.length <= 1) { root.dismiss(); return }
    root.viewStack = root.viewStack.slice(0, -1)
    root.selectedIndex = 0
    root.rebuildRows()
  }

  function rebuildRows() {
    var view = root.currentView()
    if (view === "main") root.rows = Model.mainMenu(root.mode)
    else if (view === "mode") root.rows = Model.modeMenu(root.mode)
    else if (view === "settings") root.rows = Model.settingsMenu(root.config)
    else if (view === "exclusions") root.rows = Model.exclusionsMenu(root.config.excluded_classes || [])
    else if (view === "exclusions-pick") root.rows = root.openWindowRows
    else if (view === "exclusions-remove") root.rows = (root.config.excluded_classes || []).map(function(c) { return { id: c, label: c } })
    else if (view === "notify") root.rows = Model.notifyMenu(!!root.config.notifications_enabled)
    else if (view === "pause") root.rows = Model.pauseMenu(!!root.config.pause_on_close)
    else if (view === "picker") root.rows = Model.pickerEntries(root.mode, root.history, root.hidden).map(function(e) { return { id: String(e.index), label: e.label } })
    else root.rows = []

    if (root.selectedIndex >= root.rows.length) root.selectedIndex = Math.max(0, root.rows.length - 1)
  }

  function runCtl(args) {
    Quickshell.execDetached([root.settingsCli].concat(args))
  }

  function beginInput(target, prompt) {
    root.inputMode = true
    root.inputTarget = target
    root.inputPrompt = prompt
    root.filterText = ""
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  // Modal text input never pushed a view, so it never pops one either — the
  // action lands and the underlying view (already visible) refreshes itself
  // reactively once the CLI writes the cache file back.
  function submitInput() {
    var value = root.filterText.trim()
    root.inputMode = false
    if (!value) return
    if (root.inputTarget === "max") root.runCtl(["set-max", value])
    else if (root.inputTarget === "workspace") root.runCtl(["set-workspace", value])
    else if (root.inputTarget === "exclusion") root.runCtl(["add-exclusion", value])
  }

  function fetchOpenWindows() {
    clientsProc.running = true
  }

  function activate(row) {
    var view = root.currentView()

    if (view === "main") {
      if (row.id === "mode") root.push("mode")
      else if (row.id === "settings") root.push("settings")
      else if (row.id === "bugreport") root.runCtl(["bugreport"])
    } else if (view === "mode") {
      root.runCtl(["set-mode", row.id])
      root.pop()
    } else if (view === "settings") {
      if (row.id === "max") root.beginInput("max", "Max windows in history (current: " + (root.config.max_windows !== undefined ? root.config.max_windows : 5) + ")")
      else if (row.id === "exclusions") root.push("exclusions")
      else if (row.id === "pause") root.push("pause")
      else if (row.id === "notify") root.push("notify")
      else if (row.id === "workspace") root.beginInput("workspace", "Hide workspace number (current: " + (root.config.hide_workspace !== undefined ? root.config.hide_workspace : 99) + ", recommended: >= 50)")
    } else if (view === "exclusions") {
      if (row.id === "manual") root.beginInput("exclusion", "Enter app class  (e.g. Alacritty, code, spotify)")
      else if (row.id === "pick") root.fetchOpenWindows()
      else if (row.id === "remove") root.push("exclusions-remove")
    } else if (view === "exclusions-pick") {
      root.runCtl(["add-exclusion", row.id])
      root.pop()
    } else if (view === "exclusions-remove") {
      root.runCtl(["remove-exclusion", row.id])
      root.pop()
    } else if (view === "notify") {
      root.runCtl(["set-notify", row.id])
      root.pop()
    } else if (view === "pause") {
      root.runCtl(["set-pause", row.id])
      root.pop()
    } else if (view === "picker") {
      Quickshell.execDetached([root.pickerCli, "--restore", row.id])
      root.dismiss()
    }
  }

  function headerText() {
    var view = root.currentView()
    if (view === "main") return "⚙ Window Restore"
    if (view === "mode") return "Select mode"
    if (view === "settings") return "Settings  (Esc → back)"
    if (view === "exclusions") return "Manage exclusion list"
    if (view === "exclusions-pick") return "Select app to exclude"
    if (view === "exclusions-remove") return "Select entry to remove"
    if (view === "notify") return "Notifications"
    if (view === "pause") return "Pause media on close"
    if (view === "picker") return "Restore window…"
    return "Window Restore"
  }

  function emptyText() {
    var view = root.currentView()
    if (view === "exclusions-pick") return "No new apps open"
    if (view === "exclusions-remove") return "Exclusion list is empty"
    if (view === "picker") return root.mode === "hide" ? "No hidden windows" : "No windows in history"
    return ""
  }

  Process {
    id: clientsProc
    command: ["hyprctl", "clients", "-j"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var rows = []
        try {
          var clients = JSON.parse(text)
          var excluded = root.config.excluded_classes || []
          var seen = ({})
          for (var i = 0; i < clients.length; i++) {
            var cls = clients[i].class
            if (cls && excluded.indexOf(cls) === -1 && !seen[cls]) {
              seen[cls] = true
              rows.push({ id: cls, label: cls })
            }
          }
          rows.sort(function(a, b) { return a.label < b.label ? -1 : a.label > b.label ? 1 : 0 })
        } catch (e) { rows = [] }
        root.openWindowRows = rows
        root.push("exclusions-pick")
      }
    }
  }

  function applyConfig(raw) {
    try { root.config = JSON.parse(raw) } catch (e) { root.config = {} }
    if (root.opened) root.rebuildRows()
  }

  function applyMode(raw) {
    root.mode = (raw || "relaunch").trim() || "relaunch"
    if (root.opened) root.rebuildRows()
  }

  function applyHistory(raw) {
    try { root.history = JSON.parse(raw) } catch (e) { root.history = [] }
    if (root.opened) root.rebuildRows()
  }

  function applyHidden(raw) {
    try { root.hidden = JSON.parse(raw) } catch (e) { root.hidden = [] }
    if (root.opened) root.rebuildRows()
  }

  FileView {
    id: configFile
    path: root.homePath + "/.cache/hypr-restore-config.json"
    watchChanges: true
    printErrors: false
    onLoaded: root.applyConfig(text())
    onLoadFailed: root.applyConfig("{}")
    onFileChanged: reload()
  }

  FileView {
    id: modeFile
    path: root.homePath + "/.cache/hypr-restore-mode"
    watchChanges: true
    printErrors: false
    onLoaded: root.applyMode(text())
    onLoadFailed: root.applyMode("relaunch")
    onFileChanged: reload()
  }

  FileView {
    id: historyFile
    path: root.homePath + "/.cache/hypr-window-history.json"
    watchChanges: true
    printErrors: false
    onLoaded: root.applyHistory(text())
    onLoadFailed: root.applyHistory("[]")
    onFileChanged: reload()
  }

  FileView {
    id: hiddenFile
    path: root.homePath + "/.cache/hypr-restore-hidden.json"
    watchChanges: true
    printErrors: false
    onLoaded: root.applyHidden(text())
    onLoadFailed: root.applyHidden("[]")
    onFileChanged: reload()
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-window-restore"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.inputMode) {
            if (event.key === Qt.Key_Escape) {
              root.inputMode = false
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.submitInput()
              event.accepted = true
            } else if (event.key === Qt.Key_Backspace) {
              root.filterText = root.filterText.slice(0, -1)
              event.accepted = true
            } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32) {
              root.filterText += event.text
              event.accepted = true
            }
            return
          }

          if (event.key === Qt.Key_Escape) {
            root.pop()
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.selectedIndex = Math.max(0, root.selectedIndex - 1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.selectedIndex = Math.min(root.rows.length - 1, root.selectedIndex + 1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.rows.length > 0) root.activate(root.rows[root.selectedIndex])
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.spacing.md

        Text {
          textFormat: Text.PlainText
          width: parent.width
          height: root.headerHeight
          verticalAlignment: Text.AlignVCenter
          text: root.inputMode ? (root.filterText || root.inputPrompt + "…") : root.headerText()
          color: root.foreground
          opacity: root.inputMode && !root.filterText ? 0.58 : 1
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
          elide: Text.ElideRight
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - Style.spacing.md
          visible: !root.inputMode

          ListView {
            id: resultList
            anchors.fill: parent
            visible: root.rows.length > 0
            model: root.rows
            clip: true
            spacing: Style.space(2)
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
              id: rowDelegate
              required property int index
              required property var modelData
              readonly property bool hasCursor: index === root.selectedIndex

              width: ListView.view.width
              height: root.rowHeight
              radius: root.cornerRadius
              color: hasCursor ? root.selectedBackground : "transparent"

              Text {
                textFormat: Text.PlainText
                anchors.fill: parent
                anchors.leftMargin: Style.space(12)
                anchors.rightMargin: Style.space(12)
                verticalAlignment: Text.AlignVCenter
                text: rowDelegate.modelData.label
                color: rowDelegate.hasCursor ? root.selectedText : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                elide: Text.ElideRight
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.selectedIndex = rowDelegate.index
                  root.activate(rowDelegate.modelData)
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.centerIn: parent
            visible: root.rows.length === 0
            text: root.emptyText()
            color: root.foreground
            opacity: 0.7
            font.family: root.fontFamily
            font.pixelSize: Style.font.title
          }
        }
      }
    }
  }
}
