local unit = 'mph'
local enabled = true
local defaultOn = true
local forceOff = false
local userOn = nil

local function unitToMS(val)
    -- returns meters/second
    if not val then return nil end
    val = tonumber(val)
    if not val then return nil end
    if unit == 'kph' then
        return val / 3.6
    end
    -- mph
    return val / 2.236936
end

local function getLimitForVehicle(veh)
    if not veh or veh == 0 then return nil end

    local model = GetEntityModel(veh)
    local class = GetVehicleClass(veh)

    -- model override (highest priority)
    for k, v in pairs(Config.ModelLimits or {}) do
        if GetHashKey(k) == model then
            return v
        end
    end

    -- class override
    local classLimit = (Config.ClassLimits or {})[class]
    if classLimit then return classLimit end

    -- default
    return Config.DefaultLimit
end

local function shouldLimiterRun(ped, veh)
    if not Config.Enabled or not enabled then return false end
    if forceOff then return false end

    -- user toggle state
    local on = userOn
    if on == nil then on = defaultOn end
    if not on then return false end

    if not veh or veh == 0 then return false end
    if GetPedInVehicleSeat(veh, -1) ~= ped then return false end

    if Config.ExemptIfSirenOn and IsVehicleSirenOn(veh) then
        return false
    end

    return true
end

CreateThread(function()
    if not Config.AllowToggle then return end

    if Config.ToggleCommand and Config.ToggleCommand ~= '' then
        RegisterCommand(Config.ToggleCommand, function()
            TriggerServerEvent('qbx_speedlimiter:server:toggle')
        end, false)
    end

    -- Only register a bindable key mapping if you actually want a keybind.
    if Config.ToggleKeybind and Config.ToggleCommand and Config.ToggleCommand ~= '' then
        RegisterKeyMapping(Config.ToggleCommand, 'Toggle Speed Limiter', 'keyboard', Config.ToggleKeybind)
    end
end)


-- Listen to statebags pushed from server
CreateThread(function()
    local ply = PlayerId()
    while true do
        Wait(500)

        local st = LocalPlayer.state
        if st and st.speedLimiter_unit then unit = string.lower(st.speedLimiter_unit) end
        if st and st.speedLimiter_enabled ~= nil then enabled = st.speedLimiter_enabled end
        if st and st.speedLimiter_defaultOn ~= nil then defaultOn = st.speedLimiter_defaultOn end
        if st and st.speedLimiter_forceOff ~= nil then forceOff = st.speedLimiter_forceOff end
        if st and st.speedLimiter_userOn ~= nil then userOn = st.speedLimiter_userOn end
    end
end)

-- Enforcer loop
CreateThread(function()
    local tick = tonumber(Config.TickRate) or 150

    while true do
        Wait(tick)

        local ped = PlayerPedId()
        if not ped or ped == 0 then goto continue end

        local veh = GetVehiclePedIsIn(ped, false)
        if not shouldLimiterRun(ped, veh) then goto continue end

        local limit = getLimitForVehicle(veh)
        local limitMS = unitToMS(limit)
        if not limitMS then goto continue end

        -- If player is already below limit, don't force anything
        local speed = GetEntitySpeed(veh)
        if speed > limitMS then
            -- Smooth enforcement:
            -- 1) cap max speed
            -- 2) gently reduce forward power if still exceeding
            SetVehicleMaxSpeed(veh, limitMS)

            -- Extra nudge down if they are really above the cap
            if (speed - limitMS) > 2.0 then
                SetVehicleForwardSpeed(veh, limitMS)
            end
        else
            -- Reset cap so other handling mods etc. aren't permanently affected
            SetVehicleMaxSpeed(veh, 999.0)
        end

        ::continue::
    end
end)

-- Small helper notification when toggled (client observes state change)
CreateThread(function()
    local last = nil
    while true do
        Wait(300)
        if forceOff then
            last = false
        else
            local current = userOn
            if current == nil then current = defaultOn end
            if last ~= current then
                last = current
                if Config.AllowToggle then
                    local u = string.upper(unit)
                    if current then
                        Config.Notify(('Speed limiter: ON (%s)'):format(u))
                    else
                        Config.Notify('Speed limiter: OFF')
                    end
                end
            end
        end
    end
end)
