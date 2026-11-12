import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "meysam.window-maximize"

  Commons.Translations {
    id: strings
    directory: Qt.resolvedUrl("i18n")
  }

  readonly property var activeToplevel: ToplevelManager.activeToplevel

  readonly property var activeHyprWindow: {
    var active = activeToplevel
    var list = Hyprland.toplevels ? Hyprland.toplevels.values : []
    for (var i = 0; i < list.length; i++) {
      var win = list[i]
      if (!win) continue
      if (active && win.toplevel === active) return win
      if (win.toplevel && win.toplevel.activated) return win
    }
    return null
  }

  readonly property int fullscreenState: {
    if (!activeHyprWindow || !activeHyprWindow.lastIpcObject) return 0
    return Number(activeHyprWindow.lastIpcObject.fullscreen || 0)
  }

  readonly property bool isMaximized: fullscreenState === 1
  readonly property bool isFullscreen: fullscreenState >= 2
  readonly property bool hasWindow: activeToplevel !== null || activeHyprWindow !== null

  readonly property bool hideWhenEmpty: Boolean(setting("hideWhenEmpty", false))
  visible: !vertical && (!hideWhenEmpty || hasWindow)

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function toggleMaximize() {
    if (root.bar) {
      root.bar.run("omarchy-window-maximize toggle")
    } else {
      Quickshell.execDetached(["omarchy-window-maximize", "toggle"])
    }
  }

  function unmaximize() {
    if (root.bar) {
      root.bar.run("omarchy-window-maximize restore")
    } else {
      Quickshell.execDetached(["omarchy-window-maximize", "restore"])
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar

    // \u{f05b1} is window-restore (󰖱), \u{f05af} is window-maximize (󰖯)
    text: root.isMaximized ? "\u{f05b1}" : "\u{f05af}"
    fontFamily: root.bar ? root.bar.fontFamily : Style.font.family

    active: root.isMaximized
    useActiveColor: true
    dimmed: !root.hasWindow

    tooltipText: {
      if (!root.hasWindow) return strings.t("tooltip.noWindow")
      if (root.isMaximized) return strings.t("tooltip.restore")
      if (root.isFullscreen) return strings.t("tooltip.unfullscreen")
      return strings.t("tooltip.maximize")
    }

    onPressed: function(mouseButton) {
      if (!root.hasWindow) return
      if (mouseButton === Qt.RightButton || mouseButton === Qt.MiddleButton) {
        root.unmaximize()
      } else {
        root.toggleMaximize()
      }
    }
  }
}
