# Window Maximize Plugin (`meysam.window-maximize`)

A status bar widget and keyboard dispatcher for **Omarchy / Hyprland** to maximize and restore windows cleanly.

## Why Maximize Instead of Full Screen?

In Hyprland, standard full screen (`SUPER + F` / exclusive fullscreen):
- Eliminates window margins and covers the Omarchy bar completely.
- Forces applications into exclusive Wayland fullscreen mode.
- **The Issue**: Many applications (Chromium/Google Chrome, Electron apps, GTK file choosers, LibreOffice, GIMP, etc.) fail to display modal dialogs—such as "Open File...", "Save As...", or prompt popups—because the modal dialog renders invisibly behind the fullscreen surface or fails to map.

**Window Maximize** (`fullscreen 1` / `mode = "maximized"`):
- Expands the window to fill the entire working screen layout (just like when only one window is open on a workspace).
- Preserves the Omarchy top bar and monitor gaps.
- Modal dialogs, file pickers, and child windows render properly on top as floating windows.

## Features

- **Bar Widget**: Displays a clean maximize icon (`󰖯`) when normal, and turns into an active restore icon (`󰖱`) when the window is maximized.
- **Interactive**:
  - **Left-click**: Toggle maximize / restore.
  - **Right-click / Middle-click**: Restore to normal tiled layout.
  - **Hover Tooltip**: Shows current action ("Maximize window", "Restore window", "Exit full screen to maximize").
- **CLI & Shortcut Ready**: Ships with `omarchy-window-maximize` CLI script in `~/.local/bin/`.

## Keybinding

Toggle window maximization with **`SUPER + ALT + F`** (press once to maximize, press again to restore to its original tiled size).

This is configured in [bindings.lua](file:///home/meysam/.config/hypr/bindings.lua):

```lua
-- Maximize window (preserves gaps, top bar, and allows modal dialogs to display)
o.rebind("SUPER + ALT + F", "Maximize window", "omarchy-window-maximize toggle")
```
