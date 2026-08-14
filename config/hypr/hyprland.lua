-- Hyprland Configuration for SkillArch (Lua format, Hyprland >= 0.55)
-- GNOME + Hyprland coexistence setup
-- Wiki: https://wiki.hypr.land/Configuring/Start/

-- Load optional local override files from ~/.config/hypr (not tracked by SkillArch).
-- Errors inside an existing file are reported; missing files are silently skipped.
local function source_optional(name)
    local home = os.getenv("HOME")
    if not home then return end
    local path = home .. "/.config/hypr/" .. name
    local f = io.open(path, "r")
    if not f then return end
    f:close()
    dofile(path)
end

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- GNOME compatibility
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt/Wayland variables
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- GTK variables for Wayland
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")

-- Cursor theme (hyprcursor)
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt Quick Controls theming (pour hyprpolkitagent)
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")

------------------
---- MONITORS ----
------------------

-- Auto-detect and configure all monitors with preferred resolution
-- Override in ~/.config/hypr/monitors.lua for custom multi-screen setups
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Custom monitor overrides (create ~/.config/hypr/monitors.lua)
-- Example multi-screen setup:
--   hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1 })
--   hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@60", position = "1920x0", scale = 1 })
--   hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
--   hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", default = true })
source_optional("monitors.lua")

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "fr",
        kb_variant = "azerty",
        kb_model   = "",
        kb_options = "caps:swapescape",
        kb_rules   = "",

        follow_mouse = 1,
        natural_scroll = false,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
            drag_lock = true,
            disable_while_typing = true,
        },

        sensitivity = 0,
    },
})

-- Logitech wireless mouse - flat profile for raw input
hl.device({
    name = "logitech-usb-receiver-mouse",
    sensitivity = 0.4,
    accel_profile = "flat",
})

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(a7c080ff)", "rgba(83c092ff)" }, angle = 45 },
            inactive_border = "rgba(5c6a72aa)",
        },

        layout = "dwindle",
        allow_tearing = true,
    },

    decoration = {
        rounding = 8,

        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            xray = false,
            ignore_opacity = false,
            vibrancy = 0.2,
            vibrancy_darkness = 0.5,
            noise = 0.0117,
            contrast = 0.8916,
            brightness = 0.8172,
        },

        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = "rgba(1e232680)",
            color_inactive = "rgba(1e232640)",
            offset = { 0, 2 },
            scale = 1.0,
        },

        -- Active/inactive window dimming
        dim_inactive = true,
        dim_strength = 0.05,
    },

    animations = {
        enabled = true,
    },
})

-- Animations - Optimized for smoothness
-- Custom bezier curves
hl.curve("wind",   { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn",  { type = "bezier", points = { { 0.1, 1.1 },  { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 },      { 1, 1 } } })

-- Window animations (ultra fast)
hl.animation({ leaf = "windows",     enabled = true, speed = 1, bezier = "wind",   style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 1, bezier = "winIn",  style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "wind",   style = "slide" })

-- Border animations
hl.animation({ leaf = "border",      enabled = true, speed = 2,  bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })

-- Fade animations
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "default" })

-- Workspace animations (ultra fast)
hl.animation({ leaf = "workspaces",       enabled = true, speed = 2, bezier = "wind", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "wind", style = "slide" })

-- Layer-shell surfaces (QuickSettings etc.) - no animation
hl.animation({ leaf = "layers", enabled = false })

----------------------------
---- LAYOUT / GESTURES  ----
----------------------------

hl.config({
    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },

    debug = {
        vfr = true,
    },
})

-- 3-finger horizontal swipe to switch workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- 4-finger vertical swipe to toggle floating
hl.gesture({ fingers = 4, direction = "up", action = "float" })

----------------------
---- WINDOW RULES ----
----------------------

-- GNOME Settings/Control Center - Always float regardless of how it's opened
hl.window_rule({
    name  = "float-gnome-control-center",
    match = { class = "gnome-control-center" },
    float = true, center = true, size = { 1000, 700 },
})
hl.window_rule({
    name  = "float-gnome-settings",
    match = { class = "org\\.gnome\\.Settings" },
    float = true, center = true, size = { 1000, 700 },
})
hl.window_rule({
    match = { class = "gnome-control-center", title = "Settings" },
    float = true,
})

-- GNOME Nautilus - always float
hl.window_rule({
    name  = "float-nautilus",
    match = { class = "org\\.gnome\\.Nautilus" },
    float = true, center = true, size = { 1000, 700 },
})

-- PulseAudio Volume Control
hl.window_rule({ match = { class = "pavucontrol" }, float = true })
hl.window_rule({ match = { title = "Help: SkillArch.*" }, float = true })

-- Clipboard manager
hl.window_rule({
    name  = "float-clipse",
    match = { class = "floating" },
    float = true, center = true, size = { 800, 600 },
})

-- Security tools - Pen testing apps
hl.window_rule({ match = { class = "burpsuite-.*" }, float = true })
hl.window_rule({ match = { title = "Wireshark" }, float = true })
hl.window_rule({ match = { title = "Metasploit" }, float = true })

-- Browser picture-in-picture
hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "Picture-in-Picture" },
    float = true,
    pin   = true,
    size  = { 640, 360 },
    move  = { "monitor_w-window_w-20", "monitor_h-window_h-20" },
})

-- Firefox sharing indicator
hl.window_rule({
    match = { title = "Firefox — Sharing Indicator" },
    workspace = "special:silent",
})
hl.window_rule({
    match = { title = ".*is sharing (your screen|a window)\\." },
    workspace = "special:silent",
})

-- Dialog windows
hl.window_rule({
    name  = "float-portal-gtk",
    match = { class = "xdg-desktop-portal-gtk" },
    float = true, center = true, size = { 800, 600 },
})

-- Terminal dropdown (scratchpad alternative)
hl.window_rule({
    name  = "kitty-dropdown",
    match = { class = "kitty-dropdown" },
    float = true,
    size  = { "monitor_w*0.8", "monitor_h*0.6" },
    move  = { "monitor_w*0.1", "monitor_h*0.05" },
})

-- Opacity rules
hl.window_rule({ match = { class = "kitty" }, opacity = "0.95 0.85" })
hl.window_rule({ match = { class = "code-url-handler" }, opacity = "0.90 0.80" })
hl.window_rule({ match = { class = "zen-alpha" }, opacity = "1.0 override" })

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/start-bar.sh")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("/opt/skillarch/config/hypr/scripts/wallpaper-rotate.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("clipse -listen")
    hl.exec_cmd("/usr/lib/gsd-rfkill")
end)

---------------------
---- KEYBINDINGS ----
---------------------

-- Key bindings - AZERTY layout adapted from i3
local mainMod = "SUPER"

-- Terminal and apps
-- Keep core launchers available even when a submap like resize is active.
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"), { submap_universal = true })
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("zen-browser"), { submap_universal = true })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("rofi -show drun"), { submap_universal = true })
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.exec_cmd("rofi -show run"), { submap_universal = true })
hl.bind(mainMod .. " + CTRL + Space", hl.dsp.exec_cmd("rofi -show window"), { submap_universal = true })

-- Window management
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float())

-- Workspaces - AZERTY bindings (SUPER = go to, SUPER+SHIFT = move window to)
local wsKeys = {
    "ampersand", "eacute", "quotedbl", "apostrophe", "parenleft",
    "minus", "egrave", "underscore", "ccedilla", "agrave",
}
for i, key in ipairs(wsKeys) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Screenshots
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Images/screenshot_$(date +%Y%m%d_%H%M%S).png'))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Audio controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))

-- Media controls
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"))

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5% && quickshell ipc call brightness refresh"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%- && quickshell ipc call brightness refresh"))

-- Keyboard backlight toggle
hl.bind("ALT + Space", hl.dsp.exec_cmd("/opt/skillarch/scripts/toggle-kbd-backlight"))

-- Night light (hyprsunset) - Toggle blue light filter
hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd("pkill -x hyprsunset || hyprsunset >/dev/null 2>&1"))

-- Notifications
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd("swaync-client -d -sw"))

-- Super hold: show app icons in workspace indicators
hl.bind("Super_L", hl.dsp.exec_cmd("quickshell ipc call workspaces reveal"), { non_consuming = true })
hl.bind("Super_L", hl.dsp.exec_cmd("quickshell ipc call workspaces dismiss"), { release = true, non_consuming = true })
hl.bind("SUPER + Super_L", hl.dsp.exec_cmd("quickshell ipc call workspaces dismiss"), { release = true, non_consuming = true })

-- Resize mode (like i3)
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("Left",  hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("Right", hl.dsp.window.resize({ x = 20,  y = 0, relative = true }), { repeating = true })
    hl.bind("Up",    hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("Down",  hl.dsp.window.resize({ x = 0, y = 20,  relative = true }), { repeating = true })
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

-- App shortcuts
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("XDG_CURRENT_DESKTOP=GNOME gnome-control-center"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("emote"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("XDG_CURRENT_DESKTOP=GNOME gnome-control-center bluetooth"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("XDG_CURRENT_DESKTOP=GNOME gnome-control-center wifi"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("kitty --class=floating -e clipse"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("cursor"))

-- Lock screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Power menu
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("wlogout"))

-- Hyprland controls
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exit())

-- Help bindings (adapted from i3)
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd('kitty --title "Help: SkillArch Bindings" zsh -ic "ska-help-bindings"'))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd('kitty --title "Help: SkillArch Aliases" zsh -ic "ska-help-aliases"'))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.exec_cmd('kitty --title "Help: SkillArch packages" zsh -ic "ska-help-packages"'))

-- Mouse bindings
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspace overview (Quickshell)
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("quickshell ipc call overview toggle"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("quickshell ipc call quicksettings toggle"))

-- Scratchpad equivalent (special workspace)
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(mainMod .. " + A", hl.dsp.workspace.toggle_special("scratchpad"))

--------------------------
---- MODE OVERRIDES  -----
--------------------------

-- Mode-specific overrides (desktop or vm)
-- Desktop: empty file (defaults above are desktop-ready)
-- VM: disables animations, blur, shadows for performance
source_optional("hyprland-mode.lua")
