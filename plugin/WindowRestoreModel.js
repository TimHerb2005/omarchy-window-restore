// Pure helpers that turn Window Restore's state (config/mode/history/hidden,
// all read reactively from the same cache files the CLI scripts use) into
// the row lists WindowRestore.qml renders. No side effects, no Quickshell
// imports — kept separate so the QML file stays focused on presentation,
// mirroring how ClipboardHistory.js/ReminderFlowModel.js split from their
// plugins' QML.

function mainMenu(mode) {
  var modeLabel = mode === "hide" ? "Hide" : "Relaunch"
  var modeIcon = mode === "hide" ? "󰈉" : "󰑓"
  return [
    { id: "mode", label: modeIcon + "  Mode: " + modeLabel },
    { id: "settings", label: "⚙  Settings" },
    { id: "bugreport", label: "🐛  Create bug report" },
  ]
}

function modeMenu(mode) {
  return [
    { id: "relaunch", label: "󰑓  Relaunch – app restarts fresh (default)" + (mode === "relaunch" ? "  ✓" : "") },
    { id: "hide", label: "󰈉  Hide – process stays alive, YouTube keeps playing" + (mode === "hide" ? "  ✓" : "") },
  ]
}

function settingsMenu(config) {
  var maxW = config.max_windows !== undefined ? config.max_windows : 5
  var excl = config.excluded_classes || []
  var pause = config.pause_on_close !== undefined ? config.pause_on_close : true
  var hideWs = config.hide_workspace !== undefined ? config.hide_workspace : 99
  var notif = config.notifications_enabled !== undefined ? config.notifications_enabled : true
  return [
    { id: "max", label: "  Max windows: " + maxW },
    { id: "exclusions", label: "  Exclusions: " + excl.length },
    { id: "pause", label: "  Pause on close: " + (pause ? "On" : "Off") },
    { id: "notify", label: "  Notifications: " + (notif ? "On" : "Off") },
    { id: "workspace", label: "  Hide workspace: " + hideWs },
  ]
}

function exclusionsMenu(excluded) {
  var count = excluded.length
  return [
    { id: "manual", label: "  Enter app ID manually" },
    { id: "pick", label: "  Pick from open windows" },
    { id: "remove", label: count > 0 ? "  Remove entry  (" + count + " in list)" : "  Remove entry  (list empty)" },
  ]
}

function notifyMenu(enabled) {
  return [
    { id: "on", label: "  On – show notifications" + (enabled ? "  ✓" : "") },
    { id: "off", label: "󰂛  Off – suppress all notifications" + (!enabled ? "  ✓" : "") },
  ]
}

function pauseMenu(enabled) {
  return [
    { id: "on", label: "  On – pause media when closing/hiding a window" + (enabled ? "  ✓" : "") },
    { id: "off", label: "  Off – never pause media automatically" + (!enabled ? "  ✓" : "") },
  ]
}

// Mirrors hypr-restore-picker's relaunch_label(): PWAs show the site host
// instead of the generic browser class.
function relaunchLabel(entry) {
  var args = entry.args || []
  var appArg = null
  for (var i = 0; i < args.length; i++) {
    if (args[i].indexOf("--app=") === 0) { appArg = args[i]; break }
  }
  if (appArg) {
    var rest = appArg.slice("--app=https://".length)
    return rest.split("/")[0]
  }
  return entry.class || "?"
}

function pickerEntries(mode, history, hidden) {
  if (mode === "hide") {
    return (hidden || []).map(function(e, i) {
      return { index: i, label: (i + 1) + ". " + (e.class || "?") }
    })
  }
  return (history || []).map(function(e, i) {
    return { index: i, label: (i + 1) + ". " + relaunchLabel(e) }
  })
}
