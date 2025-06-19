local EmoteTable = {}
local FavEmoteTable = {}
local KeyEmoteTable = {}
local DanceTable = {}
local PropETable = {}
local WalkTable = {}
local FaceTable = {}
local ShareTable = {}
local FavoriteEmote = ""

Citizen.CreateThread(function()
  while true do
    local porcodio = 500
    if Config.FavKeybindEnabled then
      if IsControlPressed(0, Config.FavKeybind) then
        if not IsPedSittingInAnyVehicle(PlayerPedId()) then
          if FavoriteEmote ~= "" then
            porcodio = 7
            EmoteCommandStart(nil,{FavoriteEmote, 0})
          end
        end
      end
    end
    Citizen.Wait(porcodio)
  end
end)

lang = Config.MenuLanguage

function AddEmoteMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, Config.Languages[lang]['emotes'], "", "", Menuthing, Menuthing)
    local dancemenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['danceemotes'], "", "", Menuthing, Menuthing)
    local propmenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['propemotes'], "", "", Menuthing, Menuthing)
    table.insert(EmoteTable, Config.Languages[lang]['danceemotes'])
    table.insert(EmoteTable, Config.Languages[lang]['danceemotes'])

    if Config.SharedEmotesEnabled then
      sharemenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['shareemotes'], Config.Languages[lang]['shareemotesinfo'], "", Menuthing, Menuthing)
      shareddancemenu = _menuPool:AddSubMenu(sharemenu, Config.Languages[lang]['sharedanceemotes'], "", "", Menuthing, Menuthing)
      table.insert(ShareTable, 'none')
      table.insert(EmoteTable, Config.Languages[lang]['shareemotes'])
    end

    if Config.SharedEmotesEnabled then
      for a,b in pairsByKeys(DP.Shared) do
        x,y,z,otheremotename = table.unpack(b)
        if otheremotename == nil then
          shareitem = NativeUI.CreateItem(z, "/nearby (~g~"..a.."~w~)")
        else 
          shareitem = NativeUI.CreateItem(z, "/nearby (~g~"..a.."~w~) "..Config.Languages[lang]['makenearby'].." (~y~"..otheremotename.."~w~)")
        end
        sharemenu:AddItem(shareitem)
        table.insert(ShareTable, a)
      end
    end

    for a,b in pairsByKeys(DP.PropEmotes) do
      x,y,z = table.unpack(b)
      propitem = NativeUI.CreateItem(z, "/e ("..a..")")
      propmenu:AddItem(propitem)
      table.insert(PropETable, a)
      if not Config.SqlKeybinding then
        propfavitem = NativeUI.CreateItem(z, Config.Languages[lang]['set']..z..Config.Languages[lang]['setboundemote'])
        favmenu:AddItem(propfavitem)
        table.insert(FavEmoteTable, a)
      end
    end


    dancemenu.OnItemSelect = function(sender, item, index)
      EmoteMenuStart(DanceTable[index], "dances")
    end

    if Config.SharedEmotesEnabled then
      sharemenu.OnItemSelect = function(sender, item, index)
        if ShareTable[index] ~= 'none' then
          target, distance = GetClosestPlayer()
          if(distance ~= -1 and distance < 3) then
            _,_,rename = table.unpack(DP.Shared[ShareTable[index]])
            TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), ShareTable[index])
            SimpleNotify(Config.Languages[lang]['sentrequestto']..GetPlayerName(target))
          else
            SimpleNotify(Config.Languages[lang]['nobodyclose'])
          end
        end
      end

      shareddancemenu.OnItemSelect = function(sender, item, index)
        target, distance = GetClosestPlayer()
        if(distance ~= -1 and distance < 3) then
          _,_,rename = table.unpack(DP.Dances[DanceTable[index]])
          TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), DanceTable[index], 'Dances')
          SimpleNotify(Config.Languages[lang]['sentrequestto']..GetPlayerName(target)) 
        else
          SimpleNotify(Config.Languages[lang]['nobodyclose'])
        end
      end
    end

    propmenu.OnItemSelect = function(sender, item, index)
      EmoteMenuStart(PropETable[index], "props")
    end

    submenu.OnItemSelect = function(sender, item, index)
     if EmoteTable[index] ~= Config.Languages[lang]['favoriteemotes'] then
      EmoteMenuStart(EmoteTable[index], "emotes")
    end
  end
end
