local QBCore, ESX = nil, nil
local ActivePursuits, VehicleStates, LastModeChange = {}, {}, {}

local function getFramework()
    if Config.Framework and Config.Framework ~= 'auto' then
        return Config.Framework
    end
    if GetResourceState('es_extended') == 'started' then return 'esx' end
    if GetResourceState('qb-core') == 'started' then return 'qb' end
    if GetResourceState('qbx_core') == 'started' then return 'qbx' end
    return nil
end

CreateThread(function()
    local fw = getFramework()
    if fw == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    elseif fw == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

local function getPlayerJob(src)
    local fw = getFramework()
    if fw == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.job then
            return xPlayer.job.name, xPlayer.job.grade
        end
    elseif fw == 'qb' and QBCore then
        local player = QBCore.Functions.GetPlayer(src)
        if player and player.PlayerData and player.PlayerData.job then
            return player.PlayerData.job.name, player.PlayerData.job.grade.level
        end
    elseif fw == 'qbx' then
        local groups = exports.qbx_core:GetGroups(src)
        if not groups then return nil, nil end
        for name, grade in pairs(groups) do
            if exports.qbx_core:HasPrimaryGroup(src, name) then
                local lvl = type(grade) == 'table' and (grade.level or grade.grade) or grade
                return name, lvl or 0
            end
        end
    end
    return nil, nil
end

RegisterNetEvent('ResGuard_PursuitMode:server:syncEffects', function(netId, color)
    if netId and color then
        TriggerClientEvent('ResGuard_PursuitMode:client:syncEffects', -1, netId, color)
    end
end)

RegisterNetEvent('ResGuard_PursuitMode:server:requestMode', function(targetIndex, vehNetId)
    local src = source
    if not src or src == 0 or not vehNetId or type(targetIndex) ~= 'number' then return end

    local now = GetGameTimer()
    if LastModeChange[src] and (now - LastModeChange[src]) < (Config.Cooldown or 2000) then
        return
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end

    local isAuthorized = false
    local jobName, jobGrade = getPlayerJob(src)
    if jobName and jobGrade and Config.Job[jobName] and jobGrade >= Config.Job[jobName] then
        isAuthorized = true
    end

    if not isAuthorized then return end

    local modelHash = GetEntityModel(vehicle)
    local isAllowed = false
    for _, name in ipairs(Config.AllowedVehicleNames or {}) do
        if joaat(name) == modelHash then
            isAllowed = true
            break
        end
    end

    if not isAllowed then return end

    LastModeChange[src] = now
    ActivePursuits[vehNetId] = {
        mode = targetIndex,
        player = src
    }

    TriggerClientEvent('ResGuard_PursuitMode:client:applyMode', src, vehNetId, targetIndex)
end)

exports('GetVehiclePursuitState', function(netId)
    return VehicleStates[netId] or 0
end)

exports('SetVehiclePursuitState', function(netId, state)
    VehicleStates[netId] = state
end)
