
-----------------------------------------------------------------------------------------------------
-- Shared Emotes Syncing  ---------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

RegisterServerEvent("ServerEmoteRequest")
AddEventHandler("ServerEmoteRequest", function(target, emotename, etype)
	TriggerClientEvent("ClientEmoteRequestReceive", target, emotename, etype)
end)

RegisterServerEvent("ServerValidEmote") 
AddEventHandler("ServerValidEmote", function(target, requestedemote, otheremote)
	TriggerClientEvent("SyncPlayEmote", source, otheremote, source)
	TriggerClientEvent("SyncPlayEmoteSource", target, requestedemote)
end)

-----------------------------------------------------------------------------------------------------
-- Keybinding  --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

if Config.SqlKeybinding then
  MySQL.ready(function()

	RegisterServerEvent("dp:ServerKeybindExist")
	AddEventHandler('dp:ServerKeybindExist', function()
		local src = source local srcid = GetPlayerIdentifier(source)
		MySQL.Async.fetchAll('SELECT * FROM dpkeybinds WHERE `id`=@id;', {id = srcid}, function(dpkeybinds)
			if dpkeybinds[1] then
				TriggerClientEvent("dp:ClientKeybindExist", src, true)
			else
				TriggerClientEvent("dp:ClientKeybindExist", src, false)
			end
		end)
	end)

	--  This is my first time doing SQL stuff, and after i finished everything i realized i didnt have to store the keybinds in the database at all.
	--  But remaking it now is a little pointless since it does it job just fine!

	RegisterServerEvent("dp:ServerKeybindCreate")
	AddEventHandler("dp:ServerKeybindCreate", function()
		local src = source local srcid = GetPlayerIdentifier(source)
		MySQL.Async.execute('INSERT INTO dpkeybinds (`id`, `keybind1`, `emote1`, `keybind2`, `emote2`, `keybind3`, `emote3`, `keybind4`, `emote4`, `keybind5`, `emote5`, `keybind6`, `emote6`) VALUES (@id, @keybind1, @emote1, @keybind2, @emote2, @keybind3, @emote3, @keybind4, @emote4, @keybind5, @emote5, @keybind6, @emote6);',
		{id = srcid, keybind1 = "num4", emote1 = "", keybind2 = "num5", emote2 = "", keybind3 = "num6", emote3 = "", keybind4 = "num7", emote4 = "", keybind5 = "num8", emote5 = "", keybind6 = "num9", emote6 = ""}, function(created) TriggerClientEvent("dp:ClientKeybindGet", src, "num4", "", "num5", "", "num6", "", "num7", "", "num8", "", "num8", "") end)
	end)

	RegisterServerEvent("dp:ServerKeybindGrab")
	AddEventHandler("dp:ServerKeybindGrab", function()
		local src = source local srcid = GetPlayerIdentifier(source)
		MySQL.Async.fetchAll('SELECT keybind1, emote1, keybind2, emote2, keybind3, emote3, keybind4, emote4, keybind5, emote5, keybind6, emote6 FROM `dpkeybinds` WHERE `id` = @id',
		{['@id'] = srcid}, function(kb)
			if kb[1].keybind1 ~= nil then
				TriggerClientEvent("dp:ClientKeybindGet", src, kb[1].keybind1, kb[1].emote1, kb[1].keybind2, kb[1].emote2, kb[1].keybind3, kb[1].emote3, kb[1].keybind4, kb[1].emote4, kb[1].keybind5, kb[1].emote5, kb[1].keybind6, kb[1].emote6)
			else
				TriggerClientEvent("dp:ClientKeybindGet", src, "num4", "", "num5", "", "num6", "", "num7", "", "num8", "", "num8", "")
			end
		end)
	end)

	RegisterServerEvent("dp:ServerKeybindUpdate")
	AddEventHandler("dp:ServerKeybindUpdate", function(key, emote)
		local src = source local myid = GetPlayerIdentifier(source)
		if key == "num4" then chosenk = "keybind1" elseif key == "num5" then chosenk = "keybind2" elseif key == "num6" then chosenk = "keybind3" elseif key == "num7" then chosenk = "keybind4" elseif key == "num8" then chosenk = "keybind5" elseif key == "num9" then chosenk = "keybind6" end
		if chosenk == "keybind1" then
			MySQL.Async.execute("UPDATE dpkeybinds SET emote1=@emote WHERE id=@id", {id = myid, emote = emote}, function() TriggerClientEvent("dp:ClientKeybindGetOne", src, key, emote) end)
		elseif chosenk == "keybind2" then
			MySQL.Async.execute("UPDATE dpkeybinds SET emote2=@emote WHERE id=@id", {id = myid, emote = emote}, function() TriggerClientEvent("dp:ClientKeybindGetOne", src, key, emote) end)
		elseif chosenk == "keybind3" then
			MySQL.Async.execute("UPDATE dpkeybinds SET emote3=@emote WHERE id=@id", {id = myid, emote = emote}, function() TriggerClientEvent("dp:ClientKeybindGetOne", src, key, emote) end)
		elseif chosenk == "keybind4" then
			MySQL.Async.execute("UPDATE dpkeybinds SET emote4=@emote WHERE id=@id", {id = myid, emote = emote}, function() TriggerClientEvent("dp:ClientKeybindGetOne", src, key, emote) end)
		elseif chosenk == "keybind5" then
			MySQL.Async.execute("UPDATE dpkeybinds SET emote5=@emote WHERE id=@id", {id = myid, emote = emote}, function() TriggerClientEvent("dp:ClientKeybindGetOne", src, key, emote) end)
		elseif chosenk == "keybind6" then
			MySQL.Async.execute("UPDATE dpkeybinds SET emote6=@emote WHERE id=@id", {id = myid, emote = emote}, function() TriggerClientEvent("dp:ClientKeybindGetOne", src, key, emote) end)
		end
	end)
  end)
else
	print("[dp] ^3Sql Keybinding^7 is turned ^1off^7, if you want to enable /emotebind, import dpkeybinding.sql and set ^3SqlKeybinding = ^2true^7 in config.lua.")
end
