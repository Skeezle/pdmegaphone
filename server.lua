local unit = string.lower(Config.Unit or 'mph')

local function normalizeUnit(u)
    u = string.lower(u or 'mph')
    if u ~= 'mph' and u ~= 'kph' then u = 'mph' end
    return u
end

local function isExemptJob(src)
    if not Config.ExemptJobs or next(Config.ExemptJobs) == nil then return false end

    -- Qbox typically provides exports.qbx_core:GetPlayer(src)
    if GetResourceState('qbx_core') == 'started' then
        local player = exports.qbx_core:GetPlayer(src)
        if player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name then
            return Config.ExemptJobs[player.PlayerData.job.name] == true
        end
    end

    -- QBCore fallback (if present)
    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local p = QBCore.Functions.GetPlayer(src)
        if p and p.PlayerData and p.PlayerData.job and p.PlayerData.job.name then
            return Config.ExemptJobs[p.PlayerData.job.name] == true
        end
    end

    return false
end

-- Provide unit + defaults to clients via statebag on player
AddEventHandler('playerJoining', function()
    local src = source
    local ply = Player(src)
    if not ply then return end

    ply.state.speedLimiter_unit = normalizeUnit(unit)
    ply.state.speedLimiter_enabled = Config.Enabled == true
    ply.state.speedLimiter_defaultOn = Config.DefaultOn == true
end)

-- -- Toggle request from client
RegisterNetEvent('qbx_speedlimiter:server:toggle', function()
    if not Config.AllowToggle then return end

    local src = source
    local ply = Player(src)
    if not ply then return end

    -- If job exempt, force OFF (so they can't turn it on/off and get weird state)
    if isExemptJob(src) then
        ply.state.speedLimiter_forceOff = true
        ply.state.speedLimiter_userOn = false
        return
    end

    ply.state.speedLimiter_forceOff = false

    local current = ply.state.speedLimiter_userOn
    if current == nil then current = (Config.DefaultOn == true) end
    ply.state.speedLimiter_userOn = not current
end)


-- Re-check exemptions periodically (so job changes apply)
CreateThread(function()
    while true do
        Wait(5000)
        for _, src in ipairs(GetPlayers()) do
            local ply = Player(tonumber(src))
            if ply then
                local exempt = isExemptJob(tonumber(src))
                ply.state.speedLimiter_forceOff = exempt == true
            end
        end
    end
end)
