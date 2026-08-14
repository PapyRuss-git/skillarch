-- Hyprland VM Mode - Performance optimized overrides
-- Sourced at the end of hyprland.lua to override desktop defaults

hl.config({
    -- VM-specific: force software cursors when the VM backend needs it.
    -- Desktop sessions should keep hardware cursors to avoid stale greeter cursors.
    cursor = {
        no_hardware_cursors = true,
    },

    -- Disable Caps Lock → Escape swap in VM
    input = {
        kb_options = "",
    },

    -- Tighter gaps, no tearing
    general = {
        gaps_in = 3,
        gaps_out = 3,
        allow_tearing = false,
    },

    -- No visual effects
    decoration = {
        rounding = 0,
        blur = {
            enabled = false,
        },
        shadow = {
            enabled = false,
        },
        dim_inactive = false,
    },

    -- No animations
    animations = {
        enabled = false,
    },

    -- VM display settings
    misc = {
        vrr = 0,
    },
})

-- Full opacity everywhere
hl.window_rule({ match = { class = "kitty" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = "code-url-handler" }, opacity = "1.0 override" })
