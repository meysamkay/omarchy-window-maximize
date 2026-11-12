# Window Maximize Plugin (`io.github.meysamkay.window-maximize`)

A status bar widget, keyboard dispatcher, and window rules package for **Omarchy / Hyprland** to maximize and restore windows cleanly while ensuring dialogs and popups float properly.

## Why Maximize Instead of Full Screen?

In Hyprland, standard full screen (`SUPER + F` / exclusive fullscreen):
- Eliminates window margins and covers the Omarchy bar completely.
- Forces applications into exclusive Wayland fullscreen mode (`fullscreen 2`).
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
- **Modal Dialog Rules (`rules.lua`)**: Ships with automated window rules that force all modal popups, file pickers, and alerts to float centered over the active window.

## Keybinding Setup

Toggle window maximization with **`SUPER + ALT + F`** (press once to maximize, press again to restore to its original tiled size).

Add to `~/.config/hypr/bindings.lua`:

```lua
-- Maximize window (preserves gaps, top bar, and allows modal dialogs to display)
o.rebind("SUPER + ALT + F", "Maximize window", "omarchy-window-maximize toggle")
```

## Modal Dialog Floating Rules

The plugin includes `rules.lua` to ensure modal popups and file dialogs float centered directly in front of the window.

To enable them, add this one-liner to the bottom of `~/.config/hypr/hyprland.lua`:

```lua
-- Window Maximize plugin: load modal dialog floating rules
do local path = os.getenv("HOME") .. "/.config/omarchy/plugins/io.github.meysamkay.window-maximize/rules.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end
```

Alternatively, you can paste the rules directly into your `hyprland.lua`:

```lua
o.window({ modal = true }, { float = true, center = true })
o.window({
  title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|Confirm|Select a File|Choose.*|Preferences|File Upload).*",
}, { float = true, center = true })
```

## Installation

Install directly through the Omarchy shell plugin manager:

```bash
omarchy plugin add https://github.com/meysamkay/omarchy-window-maximize.git --enable
```

## Removal

To remove the plugin:

```bash
omarchy plugin remove io.github.meysamkay.window-maximize
```

## Dependencies

- Omarchy Quattro shell (`quickshell`)
- Hyprland compositor
- `jq` (standard in Omarchy)
- No root or elevated privileges required.

## License

MIT License. See [LICENSE](LICENSE) for details.
