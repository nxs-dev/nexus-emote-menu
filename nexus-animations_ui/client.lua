local loaded = false

local function unpackArgs (...)
    return table.unpack(...)
end

function loadApplication (applicationName, args)
    while not loaded do Citizen.Wait(200) end

    SendNUIMessage({
        action = "loadApplication",
        params = {
            applicationName = applicationName,
            args = args
        }
    })
end

function unloadApplication (applicationName)
    while not loaded do Citizen.Wait(200) end

    SendNUIMessage({
        action = "unloadApplication",
        params = {
            applicationName = applicationName
        }
    })
end

function changePage (applicationName, pageName, args)
    while not loaded do Citizen.Wait(200) end

    SendNUIMessage({
        action = "changePage",
        params = {
            applicationName = applicationName,
            pageName = pageName,
            args = args
        }
    })
end

function emit (eventName, args)
    while not loaded do Citizen.Wait(200) end

    SendNUIMessage({
        action = "emit",
        params = {
            eventName = eventName,
            args = args
        }
    })
end

function focus ()
    while not loaded do Citizen.Wait(200) end

    SetNuiFocusKeepInput(false)
    SetNuiFocus(true, true)
end

function unfocus ()
    while not loaded do Citizen.Wait(200) end

    SetNuiFocus(false, false)
end

AddEventHandler("ui:onLoad", function ()
    loaded = true

    -- ? Load defaults applications
end)

RegisterNetEvent("ui:loadApplication", loadApplication)
RegisterNetEvent("ui:unloadApplication", unloadApplication)
RegisterNetEvent("ui:changePage", changePage)
RegisterNetEvent("ui:emit", emit)
RegisterNetEvent("ui:focus", focus)
RegisterNetEvent("ui:unfocus", unfocus)

RegisterNUICallback("event", function (data, callback)
    if not data.event then
        return callback("ok")
    end

    if data.event.isServer then
        TriggerServerEvent(data.event.name, unpackArgs(data.args))
    else
        TriggerEvent(data.event.name, unpackArgs(data.args))
    end

    callback("ok")
end)

exports("loadApplication", loadApplication)
exports("unloadApplication", unloadApplication)
exports("changePage", changePage)
exports("emit", emit)
exports("focus", focus)
exports("unfocus", unfocus)
