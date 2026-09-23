local QBCore, ESX = nil, nil
local PursuitMods, OriginalHandling = {}, {}
local lastChange = 0

local function _t(key, ...)
    local lang = Config.Locale or 'en'
    if Locales and Locales[lang] and Locales[lang][key] then
        return string.format(Locales[lang][key], ...)
    elseif Locales and Locales['en'] and Locales['en'][key] then
        return string.format(Locales['en'][key], ...)
    end
    return key
end

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

local function getPlayerJob()
    local fw = getFramework()
    if fw == 'esx' and ESX then
        local data = ESX.GetPlayerData()
        if not data or not data.job then return nil, nil end
        local grade = type(data.job.grade) == 'table' and (data.job.grade.level or data.job.grade.grade) or data.job.grade
        return data.job.name, grade or 0
    elseif fw == 'qb' and QBCore then
        local data = QBCore.Functions.GetPlayerData()
        if not data or not data.job then return nil, nil end
        local grade = type(data.job.grade) == 'table' and (data.job.grade.level or data.job.grade.grade) or data.job.grade
        return data.job.name, grade or 0
    elseif fw == 'qbx' then
        local groups = exports.qbx_core:GetGroups()
        if not groups then return nil, nil end
        for name, grade in pairs(groups) do
            if exports.qbx_core:HasPrimaryGroup(name) then
                local lvl = type(grade) == 'table' and (grade.level or grade.grade) or grade
                return name, lvl or 0
            end
        end
    end
    return nil, nil
end

local function notify(msg)
    if Config.EnableNotify == false then return end
    local fw = getFramework()
    if fw == 'esx' and ESX then
        ESX.ShowNotification(msg)
    elseif fw == 'qb' and QBCore then
        QBCore.Functions.Notify(msg)
    elseif fw == 'qbx' then
        exports.qbx_core:Notify(msg, 'inform', 5000)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(msg)
        DrawNotification(false, false)
    end
end

local function isVehicleAllowed(veh)
    if not veh or veh == 0 then return false end
    local hash = GetEntityModel(veh)
    for _, name in ipairs(Config.AllowedVehicleNames or {}) do
        if joaat(name) == hash then
            return true
        end
    end
    return false
end

local function parseColor(c)
    if not c then return { Red = 255, Green = 255, Blue = 255 } end
    return {
        Red = c.Red or c.r or c[1] or 255,
        Green = c.Green or c.g or c[2] or 255,
        Blue = c.Blue or c.b or c[3] or 255
    }
end

local function createPurgeSpray(veh, x, y, z, rx, ry, rz, scale)
    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Wait(0) end
    UseParticleFxAssetNextCall('core')
    return StartParticleFxLoopedOnEntity("ent_sht_steam", veh, x, y, z, rx, ry, rz, scale, false, false, false)
end

local function triggerPurgeParticles(veh, color)
    local bone = GetEntityBoneIndexByName(veh, "bonnet")
    local pos = GetWorldPositionOfEntityBone(veh, bone)
    local off = GetOffsetFromEntityGivenWorldCoords(veh, pos.x, pos.y, pos.z)
    local particles = {}

    for i = 1, 4 do
        particles[#particles + 1] = createPurgeSpray(veh, off.x - 0.5, off.y + 0.05, off.z, 40.0, -20.0, 0.0, 0.5)
        particles[#particles + 1] = createPurgeSpray(veh, off.x + 0.5, off.y + 0.05, off.z, 40.0, 20.0, 0.0, 0.5)
    end

    local c = color or { Red = 255, Green = 255, Blue = 255 }
    local r, g, b = (c.Red or 255) / 255, (c.Green or 255) / 255, (c.Blue or 255) / 255

    for _, id in ipairs(particles) do
        SetParticleFxLoopedColour(id, r, g, b, true)
    end

    SetTimeout(2000, function()
        for _, id in ipairs(particles) do
            StopParticleFxLooped(id)
        end
    end)
end

local function applyPursuitHandling(veh, idx)
    if not veh or veh == 0 or not DoesEntityExist(veh) then return end
    local netId = VehToNet(veh)
    if not netId then return end

    if not OriginalHandling[netId] then
        OriginalHandling[netId] = {
            fInitialDragCoeff = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff"),
            fInitialDriveForce = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce"),
            fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel"),
            fBrakeForce = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce"),
            fTractionCurveMax = GetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMax"),
            fTractionCurveMin = GetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMin")
        }
    end

    if idx > #Config.Mods or idx <= 0 then
        PursuitMods[netId] = 0
        local h = OriginalHandling[netId]
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff", h.fInitialDragCoeff)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", h.fInitialDriveForce)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel", h.fInitialDriveMaxFlatVel)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", h.fBrakeForce)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMax", h.fTractionCurveMax)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMin", h.fTractionCurveMin)
        ModifyVehicleTopSpeed(veh, 1.0)

        ToggleVehicleMod(veh, 22, false)
        ClearVehicleXenonLightsCustomColor(veh)
        notify(_t('normalmod'))
    else
        PursuitMods[netId] = idx
        local mod = Config.Mods[idx]
        local h = OriginalHandling[netId]

        local speedAdd = mod.fInitialDriveMaxFlatVel or ((mod.TopSpeed or mod.TopSpeedBoost or mod.SpeedBoost) and ((mod.TopSpeed or mod.TopSpeedBoost or mod.SpeedBoost) / 3.6)) or 0
        local forceAdd = mod.fInitialDriveForce or (mod.Acceleration and (h.fInitialDriveForce * (mod.Acceleration / 100))) or 0
        local brakeAdd = mod.fBrakeForce or (mod.Braking and (h.fBrakeForce * (mod.Braking / 100))) or 0
        local gripAdd = mod.fTractionCurveMax or (mod.Handling and (mod.Handling * 0.005)) or 0
        local dragSub = mod.fInitialDragCoeff or (mod.Acceleration and (0.05 * (mod.Acceleration / 15))) or 0

        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff", h.fInitialDragCoeff - dragSub)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", h.fInitialDriveForce + forceAdd)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel", h.fInitialDriveMaxFlatVel + speedAdd)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeForce", h.fBrakeForce + brakeAdd)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMax", h.fTractionCurveMax + gripAdd)
        SetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMin", h.fTractionCurveMin + (mod.fTractionCurveMin or (gripAdd * 0.8)))
        ModifyVehicleTopSpeed(veh, 1.0)

        local color = parseColor(mod.Color or mod.HeadlightColor)
        ToggleVehicleMod(veh, 22, true)
        SetVehicleXenonLightsCustomColor(veh, color.Red, color.Green, color.Blue)

        triggerPurgeParticles(veh, color)
        TriggerServerEvent('ResGuard_PursuitMode:server:syncEffects', netId, color)
        notify(_t('newmod', mod.Name))
    end
end

local function setPursuitMode(veh, idx)
    if not veh or veh == 0 then return end
    local netId = VehToNet(veh)
    if not netId then return end
    TriggerServerEvent('ResGuard_PursuitMode:server:requestMode', idx, netId)
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
                local netId = VehToNet(veh)
                if netId and (PursuitMods[netId] or 0) > 0 then
                    sleep = 400
                    if GetVehicleEngineHealth(veh) < (Config.MinEngineHealth or 250.0) then
                        TriggerServerEvent('ResGuard_PursuitMode:server:requestMode', 0, netId)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('ResGuard_PursuitMode:client:syncEffects', function(netId, color)
    local veh = NetToVeh(netId)
    if veh and DoesEntityExist(veh) then
        local c = parseColor(color)
        ToggleVehicleMod(veh, 22, true)
        SetVehicleXenonLightsCustomColor(veh, c.Red, c.Green, c.Blue)
        triggerPurgeParticles(veh, c)
    end
end)

RegisterNetEvent('ResGuard_PursuitMode:client:applyMode', function(netId, targetIndex)
    local veh = NetToVeh(netId)
    if veh and DoesEntityExist(veh) then
        applyPursuitHandling(veh, targetIndex)
    end
end)

AddEventHandler('entityRemoved', function(entity)
    if entity and GetEntityType(entity) == 2 then
        local netId = VehToNet(entity)
        if netId then
            OriginalHandling[netId] = nil
            PursuitMods[netId] = nil
        end
    end
end)

local function cycleMode()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then return end

    local jobName, jobGrade = getPlayerJob()
    if not jobName or not jobGrade or not Config.Job[jobName] or Config.Job[jobName] > jobGrade then
        return
    end

    if not isVehicleAllowed(veh) then
        notify(_t('not_allowed_vehicle'))
        return
    end

    local now = GetGameTimer()
    if now - lastChange < (Config.Cooldown or 2000) then
        notify(_t('cooldown'))
        return
    end

    lastChange = now
    local netId = VehToNet(veh)
    if not netId then return end

    local nextIndex = (PursuitMods[netId] or 0) + 1
    setPursuitMode(veh, nextIndex)
end

local commandName = Config.Command or "pursuitmode"
RegisterCommand(commandName, cycleMode)
RegisterKeyMapping(commandName, "Switch Pursuit Mode", "KEYBOARD", Config.KeyBind or "G")

if commandName ~= "pursuit" then
    RegisterCommand("pursuit", cycleMode)
end
if commandName ~= "pursuitmod" then
    RegisterCommand("pursuitmod", cycleMode)
end

exports('GetPursuitMode', function(veh)
    if not veh or veh == 0 then return 0 end
    local netId = VehToNet(veh)
    return PursuitMods[netId] or 0
end)

exports('CyclePursuitMode', function()
    cycleMode()
end)

