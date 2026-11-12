-- Omarchy Window Maximize: Modal Dialog Window Rules
-- Ensures modal dialogs, file pickers, and prompts open floating and centered over the active window.

-- Float and center all Wayland modal dialogs
o.window({ modal = true }, { float = true, center = true })

-- Float common file dialogs, pickers, and alerts that may not carry the Wayland modal flag
o.window({
  title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|Confirm|Select a File|Choose.*|Preferences|File Upload).*",
}, { float = true, center = true })
