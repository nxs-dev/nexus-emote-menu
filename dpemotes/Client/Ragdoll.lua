local isInRagdoll = false

Citizen.CreateThread(function()
 local hey = 0
 while true do
    Citizen.Wait(hey)
    hey = 3000
    if isInRagdoll then
      hey = 7
      SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
    end
  end
end)

Citizen.CreateThread(function()
    local cazzo = 0
    while true do
    Citizen.Wait(cazzo)
    cazzo = 3000
    if IsControlJustPressed(2, Config.RagdollKeybind) and Config.RagdollEnabled and IsPedOnFoot(PlayerPedId()) then
        if isInRagdoll then
            cazzo = 7
            isInRagdoll = false
        else
            cazzo = 7
            isInRagdoll = true
            Wait(500)
        end
    end
  end
end)

