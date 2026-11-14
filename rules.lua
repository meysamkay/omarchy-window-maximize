-- Dialogs float above their application instead of joining its tiled layout.
local dialog_tag = "window-maximize-dialog"
local function dialog_rule(match)
  o.window(match, {
    float = true,
    center = true,
    -- Reject client requests without issuing fullscreen_state="0 0": that
    -- resets the workspace's maximized owner, even for a newly floating child.
    -- Focus only after placement, so initial focus cannot warp the pointer.
    no_initial_focus = true,
    suppress_event = "maximize fullscreen",
    tag = "+" .. dialog_tag,
  })
end

dialog_rule({ modal = true })
-- Some Qt/XWayland file choosers do not advertise a modal role.
-- Match plain Open/Save and descriptive chooser titles such as
-- "Choose CalculiX working directory", even without a modal role.
dialog_rule({
  title = "(?i)^(open|save|save as|open files?|open folder|save file|select .*(file|folder|directory)|choose .*(file|folder|directory)|file upload|import|export|confirm|preferences|all files)([ .:…—–-].*)?$",
})

local function is_dialog(window)
  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == dialog_tag then return true end
  end
  return false
end

local function coordinate(vector, key, index)
  return vector[key] or vector[index]
end

-- Snapshot before mapping: focusing a new surface can otherwise transfer the
-- workspace's maximized state before window.open is delivered.
local opening_parents = {}
hl.on("window.open_early", function(window)
  if not window then return end
  local parent = hl.get_active_window()
  if parent and parent.address ~= window.address and parent.mapped then
    opening_parents[window.address] = {
      address = parent.address,
      maximized = parent.fullscreen == 1,
    }
  end
end)
hl.on("window.close", function(window)
  if window then opening_parents[window.address] = nil end
end)

hl.on("window.open", function(window)
  if not window then return end
  local before = opening_parents[window.address]
  opening_parents[window.address] = nil
  if not is_dialog(window) then return end
  local address = "address:" .. window.address
  -- The last focused window is the owner for portals too (their PID differs).
  local parent = before and hl.get_window("address:" .. before.address) or hl.get_last_window()
  if not parent or parent.address == window.address or not parent.mapped
      or not parent.workspace or not window.workspace
      or parent.workspace.id ~= window.workspace.id then
    parent = nil
  end
  -- Prefer a window in this process when the focus history points elsewhere.
  if not parent or parent.pid ~= window.pid then
    for _, candidate in ipairs(hl.get_windows()) do
      if candidate.address ~= window.address and candidate.pid == window.pid
          and candidate.mapped and not candidate.hidden
          and candidate.workspace and window.workspace
          and candidate.workspace.id == window.workspace.id
          and (not parent or parent.pid ~= window.pid
            or candidate.focus_history_id < parent.focus_history_id) then
        parent = candidate
      end
    end
  end
  local parent_address = parent and "address:" .. parent.address or nil
  local keep_maximized = parent and (parent.fullscreen == 1
    or (before and before.address == parent.address and before.maximized))
  -- Wait until mapping/layout has completed before applying the geometry.
  hl.timer(function()
    local dialog = hl.get_window(address)
    if not dialog or not dialog.mapped then return end
    if dialog.fullscreen ~= 0 or dialog.fullscreen_client ~= 0 then
      hl.dispatch(hl.dsp.window.fullscreen_state({
        internal = 0, client = 0, action = "set", window = address,
      }))
    end
    if not dialog.floating then
      hl.dispatch(hl.dsp.window.float({ action = "set", window = address }))
    end
    local owner = parent_address and hl.get_window(parent_address) or nil
    if owner and owner.mapped and keep_maximized and owner.fullscreen ~= 1 then
      hl.dispatch(hl.dsp.window.fullscreen({
        mode = "maximized", action = "set", window = parent_address,
      }))
    end
    local width, height = coordinate(dialog.size, "x", 1), coordinate(dialog.size, "y", 2)
    if owner and owner.mapped then
      local ow, oh = coordinate(owner.size, "x", 1), coordinate(owner.size, "y", 2)
      width = math.max(1, math.min(width, 1100, math.floor(ow * 0.8)))
      height = math.max(1, math.min(height, 800, math.floor(oh * 0.8)))
      hl.dispatch(hl.dsp.window.resize({ x = width, y = height, relative = false, window = address }))
      -- Relative deltas avoid mixing global coordinates with monitor-local ones.
      local x = coordinate(owner.at, "x", 1) + (ow - width) / 2
      local y = coordinate(owner.at, "y", 2) + (oh - height) / 2
      hl.dispatch(hl.dsp.window.move({
        x = math.floor(x - coordinate(dialog.at, "x", 1)),
        y = math.floor(y - coordinate(dialog.at, "y", 2)),
        relative = true, window = address,
      }))
    else
      local monitor = dialog.monitor
      if not monitor then return end
      width = math.min(width, 1100, math.floor(monitor.width / monitor.scale * 0.65))
      height = math.min(height, 800, math.floor(monitor.height / monitor.scale * 0.7))
      hl.dispatch(hl.dsp.window.resize({ x = width, y = height, relative = false, window = address }))
      hl.dispatch(hl.dsp.window.center({ window = address }))
    end
    -- Restoring the parent's maximization also raises it. Give the child the
    -- final stacking position and focus, after parent state and geometry settle.
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = address }))
    local no_warps = hl.get_config("cursor.no_warps")
    hl.config({ cursor = { no_warps = true } })
    local ok, err = pcall(function()
      hl.dispatch(hl.dsp.focus({ window = address }))
    end)
    hl.config({ cursor = { no_warps = no_warps } })
    if not ok then error(err) end
  end, { timeout = 1, type = "oneshot" })
end)
