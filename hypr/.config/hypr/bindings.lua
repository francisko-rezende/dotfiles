-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Vim-style focus movement (arrow keys still work too).
-- SUPER + J/K/L collide with defaults (toggle split, keybindings menu,
-- toggle workspace layout), so drop those before rebinding.
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- SUPER + J used to be the default "Toggle window split" bind before it was
-- claimed above for vim-style focus movement. Restore it on a free key.
o.bind("SUPER + SHIFT + T", "Toggle window split", hl.dsp.layout("togglesplit"))

-- Vim-style window swap (arrow keys still work too).
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- Vim-style move workspace to monitor (arrow keys still work too).
o.bind("SUPER + SHIFT + ALT + H", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + ALT + J", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))
o.bind("SUPER + SHIFT + ALT + K", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + ALT + L", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))

-- Vim-style move window into group (arrow keys still work too).
-- SUPER+ALT+K collides with the default "Tmux keybindings" binding, so drop
-- that one before rebinding it here.
hl.unbind("SUPER + ALT + K")

o.bind("SUPER + ALT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))
o.bind("SUPER + ALT + K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + ALT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))

-- Rectangle/PowerToys-style half-screen snap. Floats the active window (if
-- it isn't already) and sizes it to exactly half the monitor's work area.
-- Resize must happen before move: resizing a floating window keeps its
-- center fixed, so the edge only lands in the right place once we move last.
-- local function snap_half(side)
--   return function()
--     local win = hl.get_active_window()
--     if not win then
--       return
--     end
--
--     local mon = win.monitor
--     local reserved = mon.reserved
--     local area_x = mon.x + reserved.left
--     local area_y = mon.y + reserved.top
--     local area_w = (mon.width / mon.scale) - reserved.left - reserved.right
--     local area_h = (mon.height / mon.scale) - reserved.top - reserved.bottom
--     local half_w = math.floor(area_w / 2)
--
--     local target_x, target_w
--     if side == "left" then
--       target_x, target_w = area_x, half_w
--     else
--       target_x, target_w = area_x + half_w, math.floor(area_w) - half_w
--     end
--
--     hl.dispatch(hl.dsp.window.float({ action = "enable" }))
--     hl.dispatch(hl.dsp.window.resize({ x = target_w, y = math.floor(area_h), relative = false }))
--     hl.dispatch(hl.dsp.window.move({ x = math.floor(target_x), y = math.floor(area_y), relative = false }))
--   end
-- end
--
-- o.bind("SUPER + BRACKETLEFT", "Snap window to left half", snap_half("left"))
-- o.bind("SUPER + BRACKETRIGHT", "Snap window to right half", snap_half("right"))
