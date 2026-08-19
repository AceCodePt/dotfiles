-- Personal keybinding overrides (ported from the pre-quattro bindings.conf).
-- Loaded after Omarchy's defaults via require("hypr.bindings").

-- Workspace switching on letter keys (defaults use the number row).
-- SUPER+O and SUPER+P were bound by default to "Pop window out" and
-- "Pseudo window", so unbind them before rebinding.
hl.unbind("SUPER + O")
hl.unbind("SUPER + P")
hl.unbind("SUPER + SHIFT + O")
hl.unbind("SUPER + SHIFT + P")

o.bind("SUPER + Y", "Switch to workspace 1", hl.dsp.focus({ workspace = "1" }))
o.bind("SUPER + U", "Switch to workspace 2", hl.dsp.focus({ workspace = "2" }))
o.bind("SUPER + I", "Switch to workspace 3", hl.dsp.focus({ workspace = "3" }))
o.bind("SUPER + O", "Switch to workspace 4", hl.dsp.focus({ workspace = "4" }))
o.bind("SUPER + P", "Switch to workspace 5", hl.dsp.focus({ workspace = "5" }))

hl.unbind("SUPER + SHIFT + Y")
o.bind("SUPER + SHIFT + Y", "Move window to workspace 1", hl.dsp.window.move({ workspace = "1" }))
o.bind("SUPER + SHIFT + U", "Move window to workspace 2", hl.dsp.window.move({ workspace = "2" }))
o.bind("SUPER + SHIFT + I", "Move window to workspace 3", hl.dsp.window.move({ workspace = "3" }))
o.bind("SUPER + SHIFT + O", "Move window to workspace 4", hl.dsp.window.move({ workspace = "4" }))
o.bind("SUPER + SHIFT + P", "Move window to workspace 5", hl.dsp.window.move({ workspace = "5" }))

-- Terminal opens Tmux (overrides the default SUPER+RETURN Terminal binding).
hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Tmux", "uwsm-app -- xdg-terminal-exec --dir=\"$(omarchy-cmd-terminal-cwd)\" tmux new -A -s dotfiles -c ~/dotfiles")

-- Dictate: push-to-talk on SUPER+D.
o.bind("SUPER + D", "Dictate", "voxtype record start")
o.bind("SUPER + D", "Dictate", "voxtype record stop", { release = true })

-- Activity monitor.
o.bind("SUPER + SHIFT + T", "Activity", "omarchy-launch-tui btop")

-- Keyboard layout switch (overrides default SUPER+L "Toggle workspace layout").
hl.unbind("SUPER + L")
o.bind("SUPER + L", "Switch Languages", "hyprctl switchxkblayout all next")

-- Brightness.
o.bind("SUPER + F1", "Lower Brightness", "brightnessctl set 1%-")
o.bind("SUPER + F2", "Higher Brightness", "brightnessctl set 1%+")

-- OBS key passthrough.
hl.bind("F7", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))
hl.bind("F8", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))

-- Pin window.
o.bind("SUPER + CTRL + P", "Pin", "pin")
