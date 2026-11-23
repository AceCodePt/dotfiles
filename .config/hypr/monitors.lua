-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Laptop panel: always on, regardless of lid state
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = omarchy_monitor_scale })

-- Any other monitor that gets connected mirrors the laptop panel
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale, mirror = "eDP-1" })
