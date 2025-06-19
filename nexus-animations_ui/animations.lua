local ped = nil
local bufferSize = 5
local depth = 3.0
local normalizedX, normalizedY = 0.5, 0.80
local props = {}

local function getBooleanResult (result)
    if result == 1 then
        return true
    elseif result == 0 then
        return false
    end

    return result
end
local _IsEntityAttachedToAnyPed = IsEntityAttachedToAnyPed
local _IsPedInAnyVehicle = IsPedInAnyVehicle
local _IsEntityInWater = IsEntityInWater
local _IsPedOnFoot = IsPedOnFoot
local _IsPedFalling = IsPedFalling
local _IsPedClimbing = IsPedClimbing
local _IsPedInParachuteFreeFall = IsPedInParachuteFreeFall
local _IsPedGettingIntoAVehicle = IsPedGettingIntoAVehicle
local _IsPedJumpingOutOfVehicle = IsPedJumpingOutOfVehicle
local _IsPedSwimming = IsPedSwimming
local _NetworkIsInSpectatorMode = NetworkIsInSpectatorMode
local _IsPedDeadOrDying = IsPedDeadOrDying
local _IsPedRagdoll = IsPedRagdoll
local _IsEntityInAir = IsEntityInAir
local _IsPedOnVehicle = IsPedOnVehicle
local _GetWaterHeight = GetWaterHeight
local _DoesAnimDictExist = DoesAnimDictExist
local _DoesEntityExist = DoesEntityExist
local _HasAnimDictLoaded = HasAnimDictLoaded

local function getBooleanResult (result)
    if result == 1 then
        return true
    elseif result == 0 then
        return false
    end

    return result
end

function IsEntityAttachedToAnyPedCustom (ped)
    return getBooleanResult(_IsEntityAttachedToAnyPed(ped))
end

function IsPedInAnyVehicleCustom (ped, atGetIn)
    return getBooleanResult(_IsPedInAnyVehicle(ped, atGetIn))
end

function IsEntityInWaterCustom (ped)
    return getBooleanResult(_IsEntityInWater(ped))
end

function IsPedOnFootCustom (ped)
    return getBooleanResult(_IsPedOnFoot(ped))
end

function IsPedFallingCustom (ped)
    return getBooleanResult(_IsPedFalling(ped))
end

function IsPedClimbingCustom (ped)
    return getBooleanResult(_IsPedClimbing(ped))
end

function IsPedInParachuteFreeFallCustom (ped)
    return getBooleanResult(_IsPedInParachuteFreeFall(ped))
end

function IsPedGettingIntoAVehicleCustom (ped)
    return getBooleanResult(_IsPedGettingIntoAVehicle(ped))
end

function IsPedJumpingOutOfVehicleCustom (ped)
    return getBooleanResult(_IsPedJumpingOutOfVehicle(ped))
end

function IsPedSwimmingCustom (ped)
    return getBooleanResult(_IsPedSwimming(ped))
end

function IsPedDeadOrDyingCustom (ped)
    return getBooleanResult(_IsPedDeadOrDying(ped))
end

function NetworkIsInSpectatorModeCustom ()
    return getBooleanResult(_NetworkIsInSpectatorMode())
end

function IsPedRagdollCustom (ped)
    return getBooleanResult(_IsPedRagdoll(ped))
end

function IsEntityInAirCustom (entity)
    return getBooleanResult(_IsEntityInAir(entity))
end

function IsPedOnVehicleCustom (ped)
    return getBooleanResult(_IsPedOnVehicle(ped))
end

function GetWaterHeightCustom (x, y, z)
    return getBooleanResult(_GetWaterHeight(x, y, z))
end

function DoesAnimDictExistCustom (dict)
    return getBooleanResult(_DoesAnimDictExist(dict))
end

function DoesEntityExistCustom (entity)
    return getBooleanResult(_DoesEntityExist(entity))
end

function HasAnimDictLoadedCustom (dict)
    return getBooleanResult(_HasAnimDictLoaded(dict))
end


function createPedAnim()
    ped = CreatePed(26, GetEntityModel(PlayerPedId()), 0.0, 0.0, 0.0, 0.0, false, false)
    SetEntityCollision(ped, false, true)
    SetEntityInvincible(ped, true)
    ClonePedToTarget(PlayerPedId(), ped)
    SetEntityCanBeDamaged(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)

    local camRotation = GetGameplayCamRot(2)
    SetEntityHeading(ped, camRotation.z + 180.0)
    SetEntityRotation(ped, camRotation.x * (-1), 0, camRotation.z + 180.0, false, false)

    local buffer = {}

    Citizen.CreateThread(function ()
        while ped do
            local world, normal = GetWorldCoordFromScreenCoord(normalizedX, normalizedY)
            local target = world + normal * depth

            buffer[#buffer + 1] = target

            if #buffer > bufferSize then
                table.remove(buffer, 1)
            end

            local averagedTarget = vector3(0, 0, 0)
            for k, v in pairs(buffer) do
                averagedTarget = averagedTarget + v
            end

            averagedTarget = averagedTarget / #buffer

            SetEntityCoords(ped, averagedTarget.x, averagedTarget.y, averagedTarget.z, false, false, false, true)

            Citizen.Wait(0)
        end
    end)
end

function destroyPedAnim()
    if DoesEntityExistCustom(ped) then
        DeletePed(ped)
        ped = nil
    end

    if #props > 0 then
        for i = 1, #props do
            if not DoesEntityExistCustom(props[i]) then goto continue end

            DeleteEntity(props[i])

            ::continue::
        end

        props = {}
    end

    SetFrontendActive(false)
    ReplaceHudColourWithRgba(117, 0, 0, 0, 186)
end

function doesPedExistAnim ()
    return ped ~= nil
end

function playAnimationAnim(category, dict, animation, data)
    if not DoesEntityExistCustom(ped) then return end

    if #props > 0 then
        for i = 1, #props do
            if not DoesEntityExistCustom(props[i]) then goto continue end

            DeleteEntity(props[i])

            ::continue::
        end

        props = {}
    end

    ClearPedTasksImmediately(ped)

    if category == "Expression" then
        return SetFacialIdleAnimOverride(ped, animation, dict)
    end

    if data and data.StartDelay then
        Wait(data.StartDelay)
    end

    if not DoesAnimDictExistCustom(dict) then return end

    while not HasAnimDictLoadedCustom(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end

    local AnimationDuration = -1
    local MovementType = 0
    local AttachWait = 0

    if data then
        if data.EmoteLoop then
            MovementType = 1
            if data.EmoteMoving then
                MovementType = 51
            end

        elseif data.EmoteMoving then
            MovementType = 51
        elseif data.EmoteMoving == false then
            MovementType = 0
        elseif data.EmoteStuck then
            MovementType = 50
        end
    else
        MovementType = 0
    end

    if data then
        if data.EmoteDuration == nil then
            data.EmoteDuration = -1
            AttachWait = 0
        else
            AnimationDuration = data.EmoteDuration
            AttachWait = data.EmoteDuration
        end
    end

    if data then
        if data.Prop then
            Wait(AttachWait)

            local propModel = data.Prop
            ESX.Streaming.RequestModel(propModel)

            local pos = GetEntityCoords(ped)
            local prop = CreateObject(propModel, pos.x + 0.0, pos.y + 0.0, pos.z + 0.0, false, false, false)
            while not DoesEntityExistCustom(prop) do Citizen.Wait(0) end

            props[#props + 1] = prop

            local PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(data.PropPlacement)
            AttachEntityToEntity(
                prop, ped,
                GetPedBoneIndex(ped, data.PropBone),
                PropPl1 + 0.0, PropPl2 + 0.0, PropPl3 + 0.0,
                PropPl4 + 0.0, PropPl5 + 0.0, PropPl6 + 0.0,
                true, true, false, true, 1, true
            )

            if data.SecondProp then
                local prop2Model = data.SecondProp
                ESX.Streaming.RequestModel(prop2Model)

                local prop2 = CreateObject(propModel, pos.x + 0.0, pos.y + 0.0, pos.z + 0.0, false, false, false)
                while not DoesEntityExistCustom(prop2) do Citizen.Wait(0) end

                props[#props + 1] = prop2

                local SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack(data.SecondPropPlacement)

                AttachEntityToEntity(
                    prop2, ped,
                    GetPedBoneIndex(ped, data.SecondPropBone),
                    SecondPropPl1 + 0.0, SecondPropPl2 + 0.0, SecondPropPl3 + 0.0,
                    SecondPropPl4 + 0.0, SecondPropPl5 + 0.0, SecondPropPl6 + 0.0,
                    true, true, false, true, 1, true
                )
            end
        end
    end

    TaskPlayAnim(ped, dict, animation, 2.0, 2.0, AnimationDuration, MovementType, 0, false, false, false)
    RemoveAnimDict(dict)
end



local animationsCategories = {
    { id = 0, name = "Preferite" },
    { id = 1, name = "Balli" },
    { id = 2, name = "Animazioni" },
    { id = 3, name = "Oggetti" },
    { id = 4, name = "Animazioni animali" },
    { id = 5, name = "Animazioni condivise" }
}

local favoritesAnimations = {}

local function getCategoryNameByID (categoryID)
    if categoryID == 1 then
        return "Dances"
    elseif categoryID == 2 then
        return "Emotes"
    elseif categoryID == 3 then
        return "PropEmotes"
    elseif categoryID == 4 then
        return "AnimalEmotes"
    elseif categoryID == 5 then
        return "Shared"
    end
end

RegisterKeyMapping('animmenu', 'Menu Animazioni', 'keyboard', 'F3')

RegisterCommand("animmenu", function ()
    exports['nexus-animations_ui']:emit("animations:show")
end)

local colors = {
	r = 0,
	g = 72,
	b = 255
}

function GetServerColor ()
	return colors
end

AddEventHandler("onClientResourceStart", function (resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    while GetResourceState("dpemotes") ~= "started" do Citizen.Wait(500) end

    local animations = {}
    local colors = GetServerColor()
    local animationslist = exports.dpemotes:GetAnimationsList()

    for k, v in pairs(animationslist) do
        for k2, v2 in pairs(animationslist[k]) do
            if k == "Dances" then
                animations[#animations + 1] = {
                    name = k2,
                    label = v2[3],
                    categoryId = 1
                }
            end

            if k == "Emotes" then
                animations[#animations + 1] = {
                    name = k2,
                    label = v2[3],
                    categoryId = 2
                }
            end

            if k == "PropEmotes" then
                animations[#animations + 1] = {
                    name = k2,
                    label = v2[3],
                    categoryId = 3
                }
            end

            if k == "AnimalEmotes" then
                animations[#animations + 1] = {
                    name = k2,
                    label = v2[3],
                    categoryId = 4
                }
            end

            if k == "Shared" then
                animations[#animations + 1] = {
                    name = k2,
                    label = v2[3],
                    categoryId = 5
                }
            end
        end
    end

    favoritesAnimations = json.decode(GetResourceKvpString("animations_favorites")) or {}

    exports['nexus-animations_ui']:loadApplication("animations", {
        colors = colors,
        categories = animationsCategories,
        animations = animations,
        favorites = favoritesAnimations,
        translate = {
            ANIMATIONS_UI_SUBTITLE = "Troverete tutte le animazioni",
            ANIMATIONS_UI_SEARCH = "Cerca...",
            ANIMATIONS_UI_STOP_ANIMATION = "Cancella animazione"
        }
    })
end)

AddEventHandler("animations:previewAnimation", function (categoryID, animationName)
    if categoryID == 0 then
        for k, v in pairs(favoritesAnimations) do
            if v.name ~= animationName then goto continue end

            categoryID = v.categoryId

            ::continue::
        end

        if categoryID == 0 then return end
    end

    local categoryName = getCategoryNameByID(categoryID)
    if not categoryName then return end

    if categoryName == "Shared" then
        return ESX.ShowNotification("~r~Vous ne pouvez pas prévisualiser une emote partagée")
    end

    local animationData = exports.dpemotes:GetAnimation(categoryName, animationName)
    if not animationData then return end

    local dict = animationData[1]
    local animation = animationData[2]
    local data = animationData.AnimationOptions

    if not doesPedExistAnim() then
        createPedAnim()
    end

    playAnimationAnim(categoryName, dict, animation, data)
end)

AddEventHandler("animations:playAnimation", function (categoryID, animationName)
    if categoryID == 0 then
        for k, v in pairs(favoritesAnimations) do
            if v.name ~= animationName then goto continue end

            categoryID = v.categoryId

            ::continue::
        end

        if categoryID == 0 then return end
    end

    local categoryName = getCategoryNameByID(categoryID)
    if not categoryName then return end

    if categoryName == "Shared" then
        return ExecuteCommand(("nearby %s"):format(animationName))
    end

    return ExecuteCommand(("e %s"):format(animationName))
end)

AddEventHandler("animations:addFavorite", function (value)
    favoritesAnimations[#favoritesAnimations + 1] = value

    SetResourceKvp("animations_favorites", json.encode(favoritesAnimations))
end)

AddEventHandler("animations:removeFavorite", function (value)
    for k, v in pairs(favoritesAnimations) do
        if v.name ~= value.name then goto continue end

        table.remove(favoritesAnimations, k)

        ::continue::
    end

    SetResourceKvp("animations_favorites", json.encode(favoritesAnimations))
end)

AddEventHandler("animations:deletePed", function ()
    destroyPedAnim()
end)

AddEventHandler("animations:stopAnimation", function ()
    ExecuteCommand('e c')
end)
