Config = {}

-- =========================
-- Units / Defaults
-- =========================
-- Choose one: 'mph' or 'kph'
Config.Unit = 'mph'

-- Master switch (if false, script does nothing)
Config.Enabled = true

-- Default limit applied when nothing else matches.
-- Set to nil/false to disable global default and only use class/model limits.
Config.DefaultLimit = 170

-- How often to check/enforce (ms). Lower = tighter enforcement, higher = less CPU.
Config.TickRate = 200

-- =========================
-- Optional: Toggle
-- =========================
Config.AllowToggle = false
Config.ToggleCommand = 'speedlimiter'   -- /speedlimiter
Config.ToggleKeybind = 'nil'             -- set to nil to disable keybind

-- If true, limiter starts ON for everyone
Config.DefaultOn = true

-- =========================
-- Optional: Exemptions
-- =========================
-- Qbox jobs to exempt (set to {} for none)
Config.ExemptJobs = {}

-- Exempt if in emergency vehicle with siren on? (good for police/ems pursuits)
Config.ExemptIfSirenOn = false

-- =========================
-- Per Vehicle Class limits (optional)
-- =========================
-- GTA class IDs:
-- 0 Compacts, 1 Sedans, 2 SUVs, 3 Coupes, 4 Muscle, 5 Sports Classics,
-- 6 Sports, 7 Super, 8 Motorcycles, 9 Off-road, 10 Industrial, 11 Utility,
-- 12 Vans, 13 Cycles, 14 Boats, 15 Helicopters, 16 Planes, 17 Service,
-- 18 Emergency, 19 Military, 20 Commercial, 21 Trains
Config.ClassLimits = {
    -- [6] = 120,   -- Sports
    -- [7] = 150,   -- Super
    -- [8] = 110,   -- Motorcycles
    -- [18] = 140,  -- Emergency
}

-- =========================
-- Per Model limits (optional)
-- =========================
-- Use spawn names (model strings) like "adder", "police3", "sultanrs"
Config.ModelLimits = {
    -- adder = 160,
    -- sultanrs = 130,
    -- police3 = 150,
}

-- =========================
-- Notifications (disabled)
-- =========================
Config.Notify = function(_) end

-- =========================
-- Notifications (optional)
-- =========================
-- Config.Notify = function(msg)
--     -- If you use ox_lib:
--     if GetResourceState('ox_lib') == 'started' then
--         lib.notify({ description = msg, type = 'inform' })
--         return
--     end
--     -- fallback
--     print('[SpeedLimiter] ' .. msg)
-- end
