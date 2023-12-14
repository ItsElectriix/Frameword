BJCore = nil
TriggerEvent('BJCore:GetObject', function(obj) BJCore = obj end)

Drops = {}
DropsCache = {}
Trunks = {}
Gloveboxes = {}
Stashes = {}
Safes = {}
Bins = {
	["policetrash"] = {
		items = {},
		isOpen = false,
		label = "Trash Locker",
	}
}
Smelter = {
	[1] = { items = {} },
	[2] = { items = {} },
	[3] = { items = {} },
	[4] = { items = {} }
}
Crafting = {}
ShopItems = {}

local PawnLimits = {}

RegisterServerEvent("inventory:server:LoadDrops")
AddEventHandler('inventory:server:LoadDrops', function()
	local src = source
	if next(Drops) ~= nil then
		TriggerClientEvent("inventory:client:SetDrops", src, DropsCache)
	end
end)

RegisterServerEvent("inventory:server:addTrunkItems")
AddEventHandler('inventory:server:addTrunkItems', function(plate, items)
	Trunks[plate] = {}
	Trunks[plate].items = items
end)

RegisterServerEvent("inventory:server:combineItem")
AddEventHandler('inventory:server:combineItem', function(item, fromItem, toItem)
	local src = source
	local ply = BJCore.Functions.GetPlayer(src)

	ply.Functions.AddItem(item, 1)
	ply.Functions.RemoveItem(fromItem, 1)
	ply.Functions.RemoveItem(toItem, 1)
end)

RegisterServerEvent("inventory:server:CraftItems")
AddEventHandler('inventory:server:CraftItems', function(itemName, itemCosts, amount, toSlot, points)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local amount = tonumber(amount)
	if itemName ~= nil and itemCosts ~= nil then
		for k, v in pairs(itemCosts) do
			Player.Functions.RemoveItem(k, (v*amount))
		end
		Player.Functions.AddItem(itemName, amount, toSlot)
		Player.Functions.SetMetaData("craftingrep", Player.PlayerData.metadata["craftingrep"]+(points*amount))
		TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
	end
end)

RegisterServerEvent('inventory:server:CraftAttachment')
AddEventHandler('inventory:server:CraftAttachment', function(itemName, itemCosts, amount, toSlot, points)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local amount = tonumber(amount)
	if itemName ~= nil and itemCosts ~= nil then
		for k, v in pairs(itemCosts) do
			Player.Functions.RemoveItem(k, (v*amount))
		end
		Player.Functions.AddItem(itemName, amount, toSlot)
		Player.Functions.SetMetaData("attachmentcraftingrep", Player.PlayerData.metadata["attachmentcraftingrep"]+(points*amount))
		TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, false)
	end
end)

RegisterServerEvent("inventory:server:SetIsOpenState")
AddEventHandler('inventory:server:SetIsOpenState', function(IsOpen, type, id)
	if not IsOpen then
		if type == "stash" then
			Stashes[id].isOpen = false
		elseif type == "trunk" then
			Trunks[id].isOpen = false
		elseif type == "glovebox" then
			Gloveboxes[id].isOpen = false
		elseif type == "safe" then
			Safes[id].isOpen = false
		elseif type == "bin" then
			Bins[id].isOpen = false
		elseif type == "smelter" then
			Smelter[id].isOpen = false
		elseif type == "crafting" then
			Crafting[id].isOpen = false
        elseif type == "drop" then
			Drops[id].isOpen = false
		end
	end
end)

RegisterServerEvent("inventory:server:OpenInventory")
AddEventHandler('inventory:server:OpenInventory', function(name, id, other, label)
    local src = source
    TriggerEvent('inventory:server:OpenInventoryFromServer', src, name, id, other, label)
end)

AddEventHandler('inventory:server:OpenInventoryFromServer', function(playerSrc, name, id, other, label)
    if source ~= nil and source ~= '' and source > 0 then
        return
    end
	local src = playerSrc
	local Player = BJCore.Functions.GetPlayer(src)
	local PlayerAmmo = {}
	BJCore.Functions.ExecuteSql(false, "SELECT * FROM `playerammo` WHERE `citizenid` = @citizenid", function(ammo)
		if ammo[1] ~= nil then
			PlayerAmmo = json.decode(ammo[1].ammo)
		end

		if name ~= nil and id ~= nil then
			local secondInv = {}
			if name == "stash" then
				if Stashes[id] ~= nil then
					if Stashes[id].isOpen then
						local Target = BJCore.Functions.GetPlayer(Stashes[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Stashes[id].isOpen, name, id, Stashes[id].label)
						else
							Stashes[id].isOpen = false
						end
					end
				end
				local maxweight = 1000000
				local slots = 50
				if other ~= nil then 
					maxweight = other.maxweight ~= nil and other.maxweight or 1000000
					slots = other.slots ~= nil and other.slots or 50
				end
				secondInv.name = "stash-"..id
				secondInv.label = "Stash-"..id
				secondInv.maxweight = maxweight
				secondInv.inventory = {}
				secondInv.slots = slots
				if label and label ~= nil then secondInv.label = label; end
				if Stashes[id] ~= nil and Stashes[id].isOpen then
                    TriggerClientEvent('BJCore:Notify', src, "Someone else is rummaging around in this stash", 'error')
                    return
				else
					local stashItems = GetStashItems(id)
					if next(stashItems) ~= nil then
						secondInv.inventory = stashItems
						Stashes[id] = {}
						Stashes[id].items = stashItems
						Stashes[id].isOpen = src
						Stashes[id].label = secondInv.label
                        Stashes[id].slots = slots
                        Stashes[id].temp = other ~= nil and other.temp or false
					else
						Stashes[id] = {}
						Stashes[id].items = {}
						Stashes[id].isOpen = src
						Stashes[id].label = secondInv.label
                        Stashes[id].slots = slots
                        Stashes[id].temp = other ~= nil and other.temp or false
					end
				end
			elseif name == "trunk" then
				if Trunks[id] ~= nil then
					if Trunks[id].isOpen then
						local Target = BJCore.Functions.GetPlayer(Trunks[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Trunks[id].isOpen, name, id, Trunks[id].label)
						else
							Trunks[id].isOpen = false
						end
					end
				end
				secondInv.name = "trunk-"..id
				secondInv.label = "Trunk-"..id
				secondInv.maxweight = other.maxweight ~= nil and other.maxweight or 60000
				secondInv.inventory = {}
				secondInv.slots = other.slots ~= nil and other.slots or 50
				if (Trunks[id] ~= nil and Trunks[id].isOpen) then
					secondInv.name = "none-inv"
					secondInv.label = "Trunk-None"
					secondInv.maxweight = other.maxweight ~= nil and other.maxweight or 60000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					if id ~= nil then 
						local ownedItems = GetOwnedVehicleItems(id)
						if IsVehicleOwned(id) and next(ownedItems) ~= nil then
							secondInv.inventory = ownedItems
							Trunks[id] = {}
							Trunks[id].items = ownedItems
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						elseif Trunks[id] ~= nil and not Trunks[id].isOpen then
							secondInv.inventory = Trunks[id].items
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						else
							Trunks[id] = {}
							Trunks[id].items = {}
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						end
					end
				end
			elseif name == "glovebox" then
				if Gloveboxes[id] ~= nil then
					if Gloveboxes[id].isOpen then
						local Target = BJCore.Functions.GetPlayer(Gloveboxes[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Gloveboxes[id].isOpen, name, id, Gloveboxes[id].label)
						else
							Gloveboxes[id].isOpen = false
						end
					end
				end
				secondInv.name = "glovebox-"..id
				secondInv.label = "Glovebox-"..id
				secondInv.maxweight = 10000
				secondInv.inventory = {}
				secondInv.slots = 5
				if Gloveboxes[id] ~= nil and Gloveboxes[id].isOpen then
					secondInv.name = "none-inv"
					secondInv.label = "Glovebox-None"
					secondInv.maxweight = 10000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					local ownedItems = GetOwnedVehicleGloveboxItems(id)
					if Gloveboxes[id] ~= nil and not Gloveboxes[id].isOpen then
						secondInv.inventory = Gloveboxes[id].items
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					elseif IsVehicleOwned(id) and next(ownedItems) ~= nil then
						secondInv.inventory = ownedItems
						Gloveboxes[id] = {}
						Gloveboxes[id].items = ownedItems
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					else
						Gloveboxes[id] = {}
						Gloveboxes[id].items = {}
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					end
				end
			elseif name == "shop" then
				secondInv.name = "itemshop-"..id
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = SetupShopItems(id, other.items)
				ShopItems[id] = {}
				ShopItems[id].items = other.items
				secondInv.slots = #other.items
			elseif name == "saleshop" then
				secondInv.name = "itemsale-"..id
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = SetupShopItems(id, other.items)
				ShopItems[id] = {}
				ShopItems[id].items = other.items
				secondInv.slots = #other.items
			elseif name == "traphouse" then
				secondInv.name = "traphouse-"..id
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = other.slots
			elseif name == "attachment_crafting" then
				secondInv.name = "attachment_crafting"
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = #other.items
			elseif name == "otherplayer" then
				local OtherPlayer = BJCore.Functions.GetPlayer(tonumber(id))
				if OtherPlayer ~= nil then
					secondInv.name = "otherplayer-"..id
					secondInv.label = "Player-"..id
					secondInv.maxweight = BJCore.Config.Player.MaxWeight
					secondInv.inventory = OtherPlayer.PlayerData.items
					--if Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty then
						secondInv.slots = BJCore.Config.Player.MaxInvSlots + 1
					-- else
					-- 	secondInv.slots = BJCore.Config.Player.MaxInvSlots - 1
					-- end
					Citizen.Wait(250)
				end
            elseif name == "safe" then
				if Safes[id] ~= nil then
					if Safes[id].isOpen then
						local Target = BJCore.Functions.GetPlayer(Safes[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Safes[id].isOpen, name, id, Safes[id].label)
						else
							Safes[id].isOpen = false
						end
					end
				end
				local maxweight = 500000
				local slots = 50
				if other ~= nil then 
					maxweight = other.maxweight ~= nil and other.maxweight or 500000
					slots = other.slots ~= nil and other.slots or 50
				end
				secondInv.name = "safe-"..id
				secondInv.label = "Safe-"..id
				secondInv.maxweight = maxweight
				secondInv.inventory = {}
				secondInv.slots = slots
				if Safes[id] ~= nil and Safes[id].isOpen then
					secondInv.name = "none-inv"
					secondInv.label = "Safe-None"
					secondInv.maxweight = 500000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					local safeItems = GetSafeItems(id)
					if next(safeItems) ~= nil then
						secondInv.inventory = safeItems
						Safes[id] = {}
						Safes[id].items = safeItems
						Safes[id].isOpen = src
						Safes[id].label = secondInv.label
					else
						Safes[id] = {}
						Safes[id].items = {}
						Safes[id].isOpen = src
						Safes[id].label = secondInv.label
					end
				end
			elseif name == "bin" then
				if Bins[id] ~= nil then
					if Bins[id].isOpen then
						local Target = BJCore.Functions.GetPlayer(Bins[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Bins[id].isOpen, name, id, Bins[id].label)
						else
							Bins[id].isOpen = false
						end
					end
				end
				if Bins[id] ~= nil and not Bins[id].isOpen then
					secondInv.name = "bin-"..id
					secondInv.label = "Bin-"..tostring(id)
					if label and label ~= nil then secondInv.label = label; end
					secondInv.maxweight = 200000
					secondInv.inventory = Bins[id].items
					secondInv.slots = 30
					Bins[id].isOpen = src
					Bins[id].label = secondInv.label
				else
					secondInv.name = "bin-inv"
					secondInv.label = "Bin-None"
					secondInv.maxweight = 200000
					secondInv.inventory = {}
					secondInv.slots = 30
					--Bins[id].label = secondInv.label
				end
			elseif name == "smelter" then
				if Smelter[id] ~= nil then
					if Smelter[id].isOpen then
						local Target = BJCore.Functions.GetPlayer(Smelter[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Smelter[id].isOpen, name, id, Smelter[id].label)
						else
							Smelter[id].isOpen = false
						end
					end
				end
				if Smelter[id] ~= nil and not Smelter[id].isOpen then
					secondInv.name = "smelter-"..id
					secondInv.label = "Smelter-"..tostring(id)
					secondInv.maxweight = 200000
					if other.items then
                        secondInv.inventory = SetupItems(other.items)
                        secondInv.slots = #other.items
                        Smelter[id].items = other.items
					else
						secondInv.inventory = {}
						secondInv.slots = 1
					end
					Smelter[id].isOpen = src
					Smelter[id].label = secondInv.label
				else
					secondInv.name = "smelter-inv"
					secondInv.label = "Smelter-None"
					secondInv.maxweight = 200000
					secondInv.inventory = {}
					secondInv.slots = 30
					--Smelter[id].label = secondInv.label
				end
			elseif name == "crafting" then
				id = tostring(id)
				if Crafting[id] ~= nil then
					if Crafting[id].isOpen then
						local Target = BJCore.Functions.GetPlayer(Crafting[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Crafting[id].isOpen, name, id, Crafting[id].label)
							return
						else
							Crafting[id].isOpen = false
						end
					end
				end
				secondInv.name = "crafting-"..id
				secondInv.label = "Crafting-"..tostring(id)
				secondInv.maxweight = 200000
				secondInv.slots = 9
				secondInv.tabType = other.tabType
				if label and label ~= nil then secondInv.label = label; end
				if Crafting[id] ~= nil then
					if other.items then
                        secondInv.inventory = SetupItems(other.items)
                        Crafting[id].items = secondInv.inventory
					else
						secondInv.inventory = Crafting[id].items
					end
					Crafting[id].isOpen = src
					Crafting[id].label = secondInv.label
				elseif Crafting[id] == nil then
					Crafting[id] = {
						isOpen = src,
						label = secondInv.label,
						items = other.items and SetupItems(other.items) or {}
					}
					secondInv.inventory = Crafting[id].items
				end
			else
				if Drops[id] ~= nil then
					if Drops[id].isOpen then
						local Target = BJCore.Functions.GetPlayer(Drops[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('inventory:client:CheckOpenState', Drops[id].isOpen, name, id, Drops[id].label)
						else
							Stashes[id].isOpen = false
						end
					end

                    if not Drops[id].isOpen then
					    secondInv.name = id
					    secondInv.label = "Dropped-"..tostring(id)
					    secondInv.maxweight = 100000
					    secondInv.inventory = Drops[id].items
					    secondInv.slots = 30
					    Drops[id].isOpen = src
					    Drops[id].label = secondInv.label
                        TriggerClientEvent('inventory:client:SetCurrentDrop', src, id)
                    else
                        TriggerClientEvent('BJCore:Notify', src, "Someone else is rummaging around in this area", 'error')
                        secondInv.name = "none-inv"
                        secondInv.label = "Dropped-None"
                        secondInv.maxweight = 100000
                        secondInv.inventory = {}
                        secondInv.slots = 0
                    end
				else
					secondInv.name = "none-inv"
					secondInv.label = "Dropped-None"
					secondInv.maxweight = 100000
					secondInv.inventory = {}
					secondInv.slots = 0
					--Drops[id].label = secondInv.label
				end
			end
			TriggerClientEvent("inventory:client:OpenInventory", src, PlayerAmmo, Player.PlayerData.items, secondInv)
		else
			TriggerClientEvent("inventory:client:OpenInventory", src, PlayerAmmo, Player.PlayerData.items)
		end
	end, {["@citizenid"] = Player.PlayerData.citizenid})
end)

RegisterServerEvent("inventory:server:SaveInventory")
AddEventHandler('inventory:server:SaveInventory', function(type, id, data)
	local src = source
	if type == "trunk" then
		if (IsVehicleOwned(id)) then
			SaveOwnedVehicleItems(id, Trunks[id].items)
		else
			Trunks[id].isOpen = false
		end
	elseif type == "glovebox" then
		if (IsVehicleOwned(id)) then
			SaveOwnedGloveboxItems(id, Gloveboxes[id].items)
		else
			Gloveboxes[id].isOpen = false
		end
	elseif type == "stash" then
		SaveStashItems(id, Stashes[id].items, src)
	elseif type == "safe" then
		SaveSafeItems(id, Safes[id].items)
	elseif type == "bin" then
		if Bins[id] ~= nil then
			Bins[id].isOpen = false		
		end
	elseif type == "drop" then
		if Drops[id] ~= nil then
			Drops[id].isOpen = false
			if Drops[id].items == nil or next(Drops[id].items) == nil then
                Drops[id] = nil
                DropsCache[id] = nil
				TriggerClientEvent("inventory:client:RemoveDropItem", -1, id)
			end
		end
	elseif type == "smelter" then
        if Smelter[id] ~= nil then
        	Smelter[id].isOpen = false
			if Smelter[id].items == nil or next(Smelter[id].items) == nil then
                Smelter[id].items = {}
			else
                TriggerEvent("smelter:server:DoOrder", source, Smelter[id].items, id)
                Smelter[id].items = {}
			end
		end
	elseif type == "crafting" then
        if Crafting[id] ~= nil then
        	Crafting[id].isOpen = false
			if Crafting[id].items == nil or next(Crafting[id].items) == nil then
                Crafting[id].items = {}
			else
				local recipeName = data and data.recipe or ''
				print(source..': Trying to craft: '..recipeName)
                local rows = {{false,false,false},{false,false,false},{false,false,false}}
                local items = Crafting[id].items
                for k,v in pairs(items) do
                    if k <= 3 then
                        rows[1][k] = items[k]
                    elseif k <= 6 then
                        rows[2][k - 3] = items[k]
                    elseif k <= 9 then
                        rows[3][k - 6] = items[k]
                    end
                end
                TriggerEvent("Crafting:TryCraft", source, recipeName, id, rows)
			end	
        end
	end
end)

RegisterServerEvent("inventory:server:SetCraftingItems")
AddEventHandler('inventory:server:SetCraftingItems', function(id, items)
	if Crafting[id] then
		Crafting[id].items = items
	end
end)

RegisterServerEvent("inventory:server:UseItemSlot")
AddEventHandler('inventory:server:UseItemSlot', function(slot)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local itemData = Player.Functions.GetItemBySlot(slot)

	if itemData ~= nil then
		local itemInfo = BJCore.Shared.Items[itemData.name]
		if itemData.type == "weapon" then
			if itemData.info.quality ~= nil then
				if itemData.info.quality > 0 then
					TriggerClientEvent("inventory:client:UseWeapon", src, itemData, true)
				else
					TriggerClientEvent("inventory:client:UseWeapon", src, itemData, false)
				end
			else
				TriggerClientEvent("inventory:client:UseWeapon", src, itemData, true)
			end
			TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
		elseif itemData.useable then
			TriggerClientEvent("BJCore:Client:UseItem", src, itemData)
			TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "use")
		end
	end
end)

RegisterServerEvent("inventory:server:UseItem")
AddEventHandler('inventory:server:UseItem', function(inventory, item)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if inventory == "player" or inventory == "hotbar" then
		local itemData = Player.Functions.GetItemBySlot(item.slot)
		if itemData ~= nil then
			TriggerClientEvent('inventory:client:ItemBox', src, itemData, "use")
			TriggerClientEvent("BJCore:Client:UseItem", src, itemData)
		end
	end
end)

RegisterServerEvent("inventory:server:SetInventoryData")
AddEventHandler('inventory:server:SetInventoryData', function(dropCoords, fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount, binData)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	local fromSlot = tonumber(fromSlot)
    local toSlot = tonumber(toSlot)
    
	if (fromInventory == "player" or fromInventory == "hotbar") and (BJCore.Shared.SplitStr(toInventory, "-")[1] == "itemshop" or BJCore.Shared.SplitStr(toInventory, "-")[1] == "jobshop" or toInventory == "crafting") then
		return
	end

	-- if BJCore.Shared.SplitStr(fromInventory, "-")[1] == "itemsale" and (toInventory == "player" or toInventory == "hotbar") then
	-- 	return
	-- end

	if fromInventory == "player" or fromInventory == "hotbar" then
		local fromItemData = Player.Functions.GetItemBySlot(fromSlot)
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "otherplayer" then
				local playerId = tonumber(BJCore.Shared.SplitStr(toInventory, "-")[2])
				local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
				local toItemData = OtherPlayer.PlayerData.items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						OtherPlayer.Functions.RemoveItem(itemInfo["name"], toAmount, fromSlot)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="citizen1", toName=itemInfo["name"], toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=OtherPlayer.PlayerData.citizenid})
						TriggerEvent("bj-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount.. "** with player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
					end
				else
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="citizen2", name=itemInfo["name"], amount=fromAmount, target=OtherPlayer.PlayerData.citizenid})
					TriggerEvent("bj-log:server:CreateLog", "robbing", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** to player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | id: *"..OtherPlayer.PlayerData.source.."*)")
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				OtherPlayer.Functions.AddItem(itemInfo["name"], fromAmount, toSlot, fromItemData.info)
			elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "trunk" then
				local plate = BJCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Trunks[plate].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				--TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromTrunk(plate, fromSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="trunk1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=plate})
						TriggerEvent("bj-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="trunk2", name=fromItemData.name, amount=fromAmount, target=plate})
					TriggerEvent("bj-log:server:CreateLog", "trunk", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "glovebox" then
				local plate = BJCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Gloveboxes[plate].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="glovebox1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=plate})
						TriggerEvent("bj-log:server:CreateLog", "glovebox", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="glovebox2", name=fromItemData.name, amount=fromAmount, target=plate})
					TriggerEvent("bj-log:server:CreateLog", "glovebox", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "stash" then
				local stashId = BJCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = Stashes[stashId].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name or toItemData.unique then
						RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="stash1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=stashId})
						TriggerEvent("bj-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
					end
				else
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="stash2", name=fromItemData.name, amount=fromAmount, target=stashId})
					TriggerEvent("bj-log:server:CreateLog", "stash", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - stash: *" .. stashId .. "*")
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "safe" then
				local safeId = tonumber(BJCore.Shared.SplitStr(toInventory, "-")[2])
				local toItemData = Safes[safeId].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.PlayerData.items[fromSlot] = toItemData
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromSafe(safeId, fromSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="safe1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=safeId})
						TriggerEvent("bj-log:server:CreateLog", "safe", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - safe: *" .. safeId .. "*")
					end
				else
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="safe2", name=fromItemData.name, amount=fromAmount, target=safeId})
					TriggerEvent("bj-log:server:CreateLog", "safe", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - safe: *" .. safeId .. "*")
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToSafe(safeId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)				
			elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "traphouse" then
				-- Traphouse
				local traphouseId = BJCore.Shared.SplitStr(toInventory, "-")[2]
				local toItemData = exports['qb-traphouses']:GetInventoryData(traphouseId, toSlot)
				local IsItemValid = exports['qb-traphouses']:CanItemBeSaled(fromItemData.name:lower())
				if IsItemValid then
					Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData ~= nil then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							exports['qb-traphouses']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount)
							Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
							TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="traphouse1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=traphouseId})
							TriggerEvent("bj-log:server:CreateLog", "traphouse", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
						end
					else
						local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="traphouse2", name=fromItemData.name, amount=fromAmount, target=traphouseId})
						TriggerEvent("bj-log:server:CreateLog", "traphouse", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - traphouse: *" .. traphouseId .. "*")
					end
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					exports['qb-traphouses']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
				else
					TriggerClientEvent('BJCore:Notify', src, "You can\'t sell this item", 'error')
				end
			elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "bin" then
				local toInventory2 = tonumber(BJCore.Shared.SplitStr(toInventory, "-")[2])
				if (toInventory2 == nil or toInventory2 == 0) and toInventory ~= "bin-policetrash" then
					CreateNewBin(src, fromSlot, toSlot, fromAmount, binData)
				else
					if toInventory2 == nil then toInventory = BJCore.Shared.SplitStr(toInventory, "-")[2]
					else toInventory = toInventory2; end
					local toItemData = Bins[toInventory].items[toSlot]
					Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData ~= nil then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
							RemoveFromBin(toInventory, fromSlot, itemInfo["name"], toAmount)
							TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="bin1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=toInventory})
							TriggerEvent("bj-log:server:CreateLog", "bin", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - binid: *" .. toInventory .. "*")
						end
					else
						local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="bin2", name=fromItemData.name, amount=fromAmount, target=toInventory})
						TriggerEvent("bj-log:server:CreateLog", "bin", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - binid: *" .. toInventory .. "*")
					end
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					AddToBin(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
					if itemInfo["name"] == "radio" then
						TriggerClientEvent('bj-radio:onRadioDrop', src)
					end
				end
			elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "itemsale" then
				
				local saleType = BJCore.Shared.SplitStr(toInventory, "-")[2]
				local itemData = nil

				for k,v in pairs(ShopItems[saleType].items) do
					if v.name == fromItemData.name then
						itemData = v
						break
					end
				end

				if itemData ~= nil then
					local price = tonumber((itemData.price*fromAmount))
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					if isPawnShop(BJCore.Shared.SplitStr(toInventory, "-")[2]) then
						local canSell = canSellPawn(BJCore.Shared.SplitStr(toInventory, "-")[2], fromItemData.name, fromAmount)
						if canSell ~= 0 then
							price = tonumber((itemData.price*canSell))
							if Player.Functions.RemoveItem(fromItemData.name, canSell, fromSlot) then
								Player.Functions.AddMoney("cash", price, "shop-item-sold")
								TriggerClientEvent('BJCore:Notify', src, tostring(canSell) .. "x " .. itemInfo["label"] .. " sold for "..BJCore.Config.Currency.Symbol .. tostring(price), "success")
								TriggerEvent("bj-log:server:CreateLog", "shops", "Sold item (Pawn Shop)", "green", "**"..GetPlayerName(src) .. "** sold "..tostring(fromAmount).." " .. itemInfo["label"] .. " for "..BJCore.Config.Currency.Symbol..price)								
							end
							if fromAmount ~= canSell then TriggerClientEvent('BJCore:Notify', src, "You could only sell "..canSell.." of your item as this pawn shop couldn't buy them all", "primary", 10000); end
						else
							TriggerClientEvent('BJCore:Notify', src, "This pawn shop is not buying anymore of this item today. Come back another time", "error")
						end
					elseif Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot) then
						Player.Functions.AddMoney("cash", price, "shop-item-sold")
						TriggerClientEvent('BJCore:Notify', src, tostring(fromAmount) .. "x " .. itemInfo["label"] .. " sold for "..BJCore.Config.Currency.Symbol .. tostring(price), "success")
						TriggerEvent("bj-log:server:CreateLog", "shops", "Sold item", "green", "**"..GetPlayerName(src) .. "** sold "..tostring(fromAmount).." " .. itemInfo["label"] .. " for "..BJCore.Config.Currency.Symbol..price)
					end
				else
					TriggerClientEvent('BJCore:Notify', src, "You can't sell this item here", "error")
				end
			elseif BJCore.Shared.SplitStr(toInventory,"-")[1] == "smelter" then
				local smelterid = tonumber(BJCore.Shared.SplitStr(toInventory,"-")[2])
				local toItemData = Smelter[smelterid].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromSmelter(smelterid, fromSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
						--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="glovebox1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=plate})
						--TriggerEvent("bj-log:server:CreateLog", "smelter", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="glovebox2", name=fromItemData.name, amount=fromAmount, target=plate})
					--TriggerEvent("bj-log:server:CreateLog", "glovebox", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToSmelter(smelterid, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
			elseif BJCore.Shared.SplitStr(toInventory,"-")[1] == "crafting" then
				local craftingid = BJCore.Shared.SplitStr(toInventory,"-")[2]
				local toItemData = Crafting[craftingid].items[toSlot]
				Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						RemoveFromCrafting(craftingid, fromSlot, itemInfo["name"], toAmount)
						Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
						--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="glovebox1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=plate})
						--TriggerEvent("bj-log:server:CreateLog", "crafting", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="glovebox2", name=fromItemData.name, amount=fromAmount, target=plate})
					--TriggerEvent("bj-log:server:CreateLog", "glovebox", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToCrafting(craftingid, toSlot, itemInfo["name"], fromAmount, fromItemData.info)	
			else
				-- drop
				toInventory = tonumber(toInventory)
				if toInventory == nil or toInventory == 0 then
					CreateNewDrop(src, fromSlot, toSlot, fromAmount, dropCoords)
				else
					local toItemData = Drops[toInventory].items[toSlot]
					Player.Functions.RemoveItem(fromItemData.name, fromAmount, fromSlot)
					TriggerClientEvent("inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData ~= nil then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
						if toItemData.name ~= fromItemData.name then
							Player.Functions.AddItem(toItemData.name, toAmount, fromSlot, toItemData.info)
							RemoveFromDrop(toInventory, fromSlot, itemInfo["name"], toAmount)
							TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="drop1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=toInventory})
							TriggerEvent("bj-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
						end
					else
						local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="drop2", name=fromItemData.name, amount=fromAmount, target=toInventory})
						TriggerEvent("bj-log:server:CreateLog", "drop", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - dropid: *" .. toInventory .. "*")
					end
					local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
					AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
					if itemInfo["name"] == "radio" then
						TriggerClientEvent('bj-radio:onRadioDrop', src)
					end
				end
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn't exist", "error")
		end
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "otherplayer" then
		local playerId = tonumber(BJCore.Shared.SplitStr(fromInventory, "-")[2])
		local OtherPlayer = BJCore.Functions.GetPlayer(playerId)
		local fromItemData = OtherPlayer.PlayerData.items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				OtherPlayer.Functions.RemoveItem(itemInfo["name"], fromAmount, fromSlot)
				TriggerClientEvent("inventory:client:CheckWeapon", OtherPlayer.PlayerData.source, fromItemData.name)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						OtherPlayer.Functions.AddItem(itemInfo["name"], toAmount, fromSlot, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2citizen1", toName=itemInfo["name"], toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=OtherPlayer.PlayerData.citizenid})
						TriggerEvent("bj-log:server:CreateLog", "robbing", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
					end
				else
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2citizen2", name=fromItemData.name, amount=fromAmount, target=OtherPlayer.PlayerData.citizenid})
					TriggerEvent("bj-log:server:CreateLog", "robbing", "Retrieved Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) took item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** from player: **".. GetPlayerName(OtherPlayer.PlayerData.source) .. "** (citizenid: *"..OtherPlayer.PlayerData.citizenid.."* | *"..OtherPlayer.PlayerData.source.."*)")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = OtherPlayer.PlayerData.items[toSlot]
				OtherPlayer.Functions.RemoveItem(itemInfo["name"], fromAmount, fromSlot)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						OtherPlayer.Functions.RemoveItem(itemInfo["name"], toAmount, toSlot)
						OtherPlayer.Functions.AddItem(itemInfo["name"], toAmount, fromSlot, toItemData.info)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				OtherPlayer.Functions.AddItem(itemInfo["name"], fromAmount, toSlot, fromItemData.info)
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn\'t exist", "error")
		end
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "trunk" then
		local plate = BJCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Trunks[plate].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2trunk1", toName=itemInfo["name"], toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=plate})
						TriggerEvent("bj-log:server:CreateLog", "trunk", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
					else
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2trunk3", name=toItemData.name, amount=toAmount, target=plate})
						TriggerEvent("bj-log:server:CreateLog", "trunk", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
					end
				else
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2trunk2", name=fromItemData.name, amount=fromAmount, target=plate})
					TriggerEvent("bj-log:server:CreateLog", "trunk", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = Trunks[plate].items[toSlot]
				RemoveFromTrunk(plate, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						RemoveFromTrunk(plate, toSlot, itemInfo["name"], toAmount)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn\'t exist", "error")
		end
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "glovebox" then
		local plate = BJCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Gloveboxes[plate].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2glovebox1", toName=itemInfo["name"], toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=plate})
						TriggerEvent("bj-log:server:CreateLog", "glovebox", "Swapped", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src..")* swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** plate: *" .. plate .. "*")
					else
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2glovebox3", name=toItemData.name, amount=toAmount, target=plate})
						TriggerEvent("bj-log:server:CreateLog", "glovebox", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from plate: *" .. plate .. "*")
					end
				else
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2glovebox2", name=fromItemData.name, amount=fromAmount, target=plate})
					TriggerEvent("bj-log:server:CreateLog", "glovebox", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** plate: *" .. plate .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = Gloveboxes[plate].items[toSlot]
				RemoveFromGlovebox(plate, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						RemoveFromGlovebox(plate, toSlot, itemInfo["name"], toAmount)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn\'t exist??", "error")
		end
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "stash" then
		local stashId = BJCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Stashes[stashId].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name or toItemData.unique then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2stash1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=stashId})
						TriggerEvent("bj-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. stashId .. "*")
					else
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2stash3", name=toItemData.name, amount=toAmount, target=stashId})
						TriggerEvent("bj-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. stashId .. "*")
					end
				else
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2stash2", name=fromItemData.name, amount=fromAmount, target=stashId})
					TriggerEvent("bj-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. stashId .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = Stashes[stashId].items[toSlot]
				RemoveFromStash(stashId, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name or toItemData.unique then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						RemoveFromStash(stashId, toSlot, itemInfo["name"], toAmount)
						AddToStash(stashId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToStash(stashId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn\'t exist", "error")
		end
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "safe" then
		local safeId = tonumber(BJCore.Shared.SplitStr(fromInventory, "-")[2])
		local fromItemData = Safes[safeId].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromSafe(safeId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToSafe(safeId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2safe1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=safeId})
						TriggerEvent("bj-log:server:CreateLog", "safe", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** safe: *" .. safeId .. "*")
					else
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2safe3", name=toItemData.name, amount=toAmount, target=safeId})
						TriggerEvent("bj-log:server:CreateLog", "safe", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from safe: *" .. safeId .. "*")
					end
				else
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2safe2", name=fromItemData.name, amount=fromAmount, target=safeId})
					TriggerEvent("bj-log:server:CreateLog", "safe", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** safe: *" .. safeId .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = Safes[safeId].items[toSlot]
				RemoveFromSafe(safeId, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						RemoveFromSafe(safeId, toSlot, itemInfo["name"], toAmount)
						AddToSafe(safeId, fromSlot, toSlot, itemInfo["name"], toAmount, toItemData.info)
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToSafe(safeId, toSlot, fromSlot, itemInfo["name"], fromAmount, fromItemData.info)
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn\'t exist??", "error")
		end		
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "traphouse" then
		local traphouseId = BJCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = exports['qb-traphouses']:GetInventoryData(traphouseId, fromSlot)
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				exports['qb-traphouses']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						exports['qb-traphouses']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2stash1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=traphouseId})
						TriggerEvent("bj-log:server:CreateLog", "stash", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** stash: *" .. traphouseId .. "*")
					else
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2stash3", name=toItemData.name, amount=toAmount, target=traphouseId})
						TriggerEvent("bj-log:server:CreateLog", "stash", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** from stash: *" .. traphouseId .. "*")
					end
				else
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2stash2", name=fromItemData.name, amount=fromAmount, target=traphouseId})
					TriggerEvent("bj-log:server:CreateLog", "stash", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** stash: *" .. traphouseId .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				local toItemData = exports['qb-traphouses']:GetInventoryData(traphouseId, toSlot)
				exports['qb-traphouses']:RemoveHouseItem(traphouseId, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						exports['qb-traphouses']:RemoveHouseItem(traphouseId, toSlot, itemInfo["name"], toAmount)
						exports['qb-traphouses']:AddHouseItem(traphouseId, fromSlot, itemInfo["name"], toAmount, toItemData.info, src)
					end
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				exports['qb-traphouses']:AddHouseItem(traphouseId, toSlot, itemInfo["name"], fromAmount, fromItemData.info, src)
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn't exist", "error")
		end
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "itemshop" or BJCore.Shared.SplitStr(fromInventory, "-")[1] == "itemsale" then
		local shopType = BJCore.Shared.SplitStr(fromInventory, "-")[2]
		local itemData = ShopItems[shopType].items[fromSlot]
		local itemInfo = BJCore.Shared.Items[itemData.name:lower()]
		local bankBalance = Player.PlayerData.money["bank"]
		local cashBalance = Player.PlayerData.money["cash"]
		local price = tonumber((itemData.price*fromAmount))

		if BJCore.Shared.SplitStr(shopType, "_")[1] == "Dealer" then
			if BJCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
				price = tonumber(itemData.price)
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					itemData.info.serial = tostring(Config.RandomInt(2) .. Config.RandomStr(3) .. Config.RandomInt(1) .. Config.RandomStr(2) .. Config.RandomInt(3) .. Config.RandomStr(4))
					Player.Functions.AddItem(itemData.name, 1, toSlot, itemData.info)
					TriggerClientEvent('bj-drugs:client:updateDealerItems', src, itemData, 1)
					TriggerClientEvent('BJCore:Notify', src, itemInfo["label"] .. " purchased", "success")
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemshop", {type="dealer", name=itemInfo["name"], amount=1, paymentType="cash", price=price})
					TriggerEvent("bj-log:server:CreateLog", "dealers", "Dealer item purchased", "green", "**"..GetPlayerName(src) .. "** purchased a " .. itemInfo["label"] .. " for "..BJCore.Config.Currency.Symbol..price)
				else
					TriggerClientEvent('BJCore:Notify', src, "You don\'t have enough cash", "error")
				end
			else
				if Player.Functions.RemoveMoney("cash", price, "dealer-item-bought") then
					Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
					TriggerClientEvent('bj-drugs:client:updateDealerItems', src, itemData, fromAmount)
					TriggerClientEvent('BJCore:Notify', src, itemInfo["label"] .. " purchased", "success")
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemshop", {type="dealer", name=itemInfo["name"], amount=fromAmount, paymentType="cash", price=price})
					TriggerEvent("bj-log:server:CreateLog", "dealers", "Dealer item gekocht", "green", "**"..GetPlayerName(src) .. "** heeft een " .. itemInfo["label"] .. " gekocht voor "..BJCore.Config.Currency.Symbol..price)
				else
					TriggerClientEvent('BJCore:Notify', src, "You don't have enough cash", "error")
				end
			end
		elseif BJCore.Shared.SplitStr(shopType, "_")[1] == "Itemshop" then
			if not itemData.requiresWeaponLicense or (itemData.requiresWeaponLicense and Player.PlayerData.metadata["licences"]["gun"]) then
				if cashBalance >= price then
					if BJCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
						itemData.info.serial = tostring(Config.RandomInt(2) .. Config.RandomStr(3) .. Config.RandomInt(1) .. Config.RandomStr(2) .. Config.RandomInt(3) .. Config.RandomStr(4))
					end
					Player.Functions.RemoveMoney("cash", price, "itemshop-bought-item")
					Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
					TriggerClientEvent('bj-shops:client:UpdateShop', src, BJCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
					TriggerClientEvent('BJCore:Notify', src, itemInfo["label"] .. " purchased", "success")
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemshop", {type="itemshop", name=itemInfo["name"], amount=fromAmount, paymentType="cash", price=price})
					TriggerEvent("bj-log:server:CreateLog", "shops", "Shop item purchased", "green", "**"..GetPlayerName(src) .. "** purchased x"..fromAmount.." ".. itemInfo["label"] .. " for "..BJCore.Config.Currency.Symbol..price)
					if itemData.requiresWeaponLicense and BJCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then SaveGunRecord(src, itemInfo["label"], itemData.info.serial); end
					if BJCore.Shared.SplitStr(shopType, "_")[2] == "hospital" then TriggerEvent("bj-log:server:CreateLog", "ems", "Item Taken", "green", "**"..GetPlayerName(src) .. "** ("..Player.PlayerData.citizenid..") purchased/took x"..fromAmount.." "..itemInfo["label"].." for "..BJCore.Config.Currency.Symbol..price.." from EMS Stock/Shop") end
				-- elseif bankBalance >= price then
				-- 	Player.Functions.RemoveMoney("bank", price, "itemshop-bought-item")
				-- 	Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
				-- 	TriggerClientEvent('bj-shops:client:UpdateShop', src, BJCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
				-- 	TriggerClientEvent('BJCore:Notify', src, itemInfo["label"] .. " purchased", "success")
				-- 	TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemshop", {type="itemshop", name=itemInfo["name"], amount=fromAmount, paymentType="bank", price=price})
				-- 	TriggerEvent("bj-log:server:CreateLog", "shops", "Shop item purchased", "green", "**"..GetPlayerName(src) .. "** purchased a " .. itemInfo["label"] .. " for "..BJCore.Config.Currency.Symbol..price)
				else
					TriggerClientEvent('BJCore:Notify', src, "You don't have enough cash", "error")
				end
			else
				TriggerClientEvent('BJCore:Notify', src, "You need a gun license to purchase this", "error")
			end
        elseif BJCore.Shared.SplitStr(shopType, "_")[1] == "Jobshop" then
			if not itemData.requiresWeaponLicense or (itemData.requiresWeaponLicense and Player.PlayerData.metadata["licences"]["gun"]) then
                local job = BJCore.Shared.SplitStr(shopType, "_")[2]
                TriggerEvent('moneysafe:server:WithdrawMoneyForPurchase', job, price, function(canPay)
                    if canPay then
                        if BJCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then
                            itemData.info.serial = tostring(Config.RandomInt(2) .. Config.RandomStr(3) .. Config.RandomInt(1) .. Config.RandomStr(2) .. Config.RandomInt(3) .. Config.RandomStr(4))
                        end
                        Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
                        TriggerClientEvent('bj-shops:client:UpdateShop', src, BJCore.Shared.SplitStr(shopType, "_")[2], itemData, fromAmount)
                        TriggerClientEvent('BJCore:Notify', src, itemInfo["label"] .. " purchased", "success")
                        TriggerClientEvent('BJCore:Notify', src, "You paid "..BJCore.Config.Currency.Symbol..price.." from the job safe", "success")
                        TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemshop", {type="itemshop", name=itemInfo["name"], amount=fromAmount, paymentType="cash", price=price})
                        TriggerEvent("bj-log:server:CreateLog", "shops", "Shop item purchased", "green", "**"..GetPlayerName(src) .. "** purchased x"..fromAmount.." ".. itemInfo["label"] .. " for "..BJCore.Config.Currency.Symbol..price)
                        if itemData.requiresWeaponLicense and BJCore.Shared.SplitStr(itemData.name, "_")[1] == "weapon" then SaveGunRecord(src, itemInfo["label"], itemData.info.serial); end
                    else
                        TriggerClientEvent('BJCore:Notify', src, "There is not enough money in the safe", "error")
                    end
                end)
			else
				TriggerClientEvent('BJCore:Notify', src, "You need a gun license to purchase this", "error")
			end
        elseif BJCore.Shared.SplitStr(shopType, "_")[1] == "Playershop" then
            local id = tonumber(BJCore.Shared.SplitStr(shopType, "_")[2])
            TriggerEvent('playershops:server:tryBuyItem', id, src, itemData.name, tonumber(fromAmount), toSlot)
		else
			if Player.Functions.RemoveMoney("cash", price, "unkown-itemshop-bought-item") then
				Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
				if shopType == "police" and itemData.info and itemData.info.serial then
					SaveGunRecord(src, itemInfo["label"], itemData.info.serial)
				end
				TriggerClientEvent('BJCore:Notify', src, itemInfo["label"] .. " purchased", "success")
				TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemshop", {type="other", name=itemInfo["name"], amount=fromAmount, paymentType="cash", price=price})
				TriggerEvent("bj-log:server:CreateLog", "police", "Armory Purchase", "greed", "**"..GetPlayerName(src) .. "** ("..Player.PlayerData.citizenid..") purchased/took x"..fromAmount.." "..itemInfo["label"].." for "..BJCore.Config.Currency.Symbol..price.." from Police Armory. Info: "..BJCore.Common.Dump(itemData.info))
				if shopType == "police" then
					TriggerEvent("bj-log:server:CreateLog", "police_armory", "Armory Purchase", "greed", "**"..Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname.."** ("..Player.PlayerData.citizenid..") purchased/took x"..fromAmount.." "..itemInfo["label"].." for "..BJCore.Config.Currency.Symbol..price.." from Police Armory. Info: "..BJCore.Common.Dump(itemData.info))
				end
				TriggerEvent("bj-log:server:CreateLog", "shops", "Shop item purchased", "green", "**"..GetPlayerName(src) .. "** purchased x"..fromAmount.." " .. itemInfo["label"] .. " for "..BJCore.Config.Currency.Symbol..price)
			elseif bankBalance >= price then
				Player.Functions.RemoveMoney("bank", price, "unkown-itemshop-bought-item")
				Player.Functions.AddItem(itemData.name, fromAmount, toSlot, itemData.info)
				if shopType == "police" and itemData.info and itemData.info.serial then
					SaveGunRecord(src, itemInfo["label"], itemData.info.serial)
				end
				TriggerClientEvent('BJCore:Notify', src, itemInfo["label"] .. " purchased", "success")
				TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemshop", {type="other", name=itemInfo["name"], amount=fromAmount, paymentType="bank", price=price})
				TriggerEvent("bj-log:server:CreateLog", "police", "Armory Purchase", "greed", "**"..GetPlayerName(src) .. "** ("..Player.PlayerData.citizenid..") purchased/took x"..fromAmount.." "..itemInfo["label"].." for "..BJCore.Config.Currency.Symbol..price.." from Police Armory. Info: "..BJCore.Common.Dump(itemData.info))
				if shopType == "police" then
					TriggerEvent("bj-log:server:CreateLog", "police_armory", "Armory Purchase", "greed", "**"..Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname.."** ("..Player.PlayerData.citizenid..") purchased/took x"..fromAmount.." "..itemInfo["label"].." for "..BJCore.Config.Currency.Symbol..price.." from Police Armory. Info: "..BJCore.Common.Dump(itemData.info))
				end
				TriggerEvent("bj-log:server:CreateLog", "shops", "Shop item purchased", "green", "**"..GetPlayerName(src) .. "** purchased x"..fromAmount.." ".. itemInfo["label"] .. " for "..BJCore.Config.Currency.Symbol..price)
			else
				TriggerClientEvent('BJCore:Notify', src, "You don\'t have enough cash", "error")
			end
		end
	elseif fromInventory == "attachment_crafting" then
		local itemData = Config.AttachmentCrafting["items"][fromSlot]
		if hasCraftItems(src, itemData.costs, fromAmount) then
			TriggerClientEvent("inventory:client:CraftAttachment", src, itemData.name, itemData.costs, fromAmount, toSlot, itemData.points)
		else
			TriggerClientEvent("inventory:client:UpdatePlayerInventory", src, true)
			TriggerClientEvent('BJCore:Notify', src, "You don't have the right items..", "error")
		end
    elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "bin" then
    	if BJCore.Shared.SplitStr(fromInventory, "-")[2] == "policetrash" then
    		fromInventory = "policetrash"
    	else
			fromInventory = tonumber(BJCore.Shared.SplitStr(fromInventory, "-")[2])
		end
		local fromItemData = Bins[fromInventory].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromBin(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToBin(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('bj-radio:onRadioDrop', src)
						end
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=fromInventory})
						TriggerEvent("bj-log:server:CreateLog", "bin", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - binid: *" .. fromInventory .. "*")
					else
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin3", name=toItemData.name, amount=toAmount, target=fromInventory})
						TriggerEvent("bj-log:server:CreateLog", "bin", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from binid: *" .. fromInventory .. "*")
					end
				else
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin2", name=fromItemData.name, amount=fromAmount, target=fromInventory})
					TriggerEvent("bj-log:server:CreateLog", "bin", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  binid: *" .. fromInventory .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				toInventory = tonumber(toInventory)
				local toItemData = Bins[toInventory].items[toSlot]
				RemoveFromBin(fromInventory, fromSlot, itemInfo["name"], fromAmount, binData)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						RemoveFromBin(toInventory, toSlot, itemInfo["name"], toAmount)
						AddToBin(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('bj-radio:onRadioDrop', src)
						end
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToBin(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
				if itemInfo["name"] == "radio" then
					TriggerClientEvent('bj-radio:onRadioDrop', src)
				end
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn't exist", "error")
		end
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "smelter" then
		fromInventory = tonumber(BJCore.Shared.SplitStr(fromInventory, "-")[2])
		local fromItemData = Smelter[fromInventory].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromSmelter(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToSmelter(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('bj-radio:onRadioDrop', src)
						end
						--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=fromInventory})
						--TriggerEvent("bj-log:server:CreateLog", "smelter", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - binid: *" .. fromInventory .. "*")
					else
						--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin3", name=toItemData.name, amount=toAmount, target=fromInventory})
						--TriggerEvent("bj-log:server:CreateLog", "smelter", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from binid: *" .. fromInventory .. "*")
					end
				else
					--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin2", name=fromItemData.name, amount=fromAmount, target=fromInventory})
					--TriggerEvent("bj-log:server:CreateLog", "smelter", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  binid: *" .. fromInventory .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				toInventory = tonumber(toInventory)
				local toItemData = Smelter[toInventory].items[toSlot]
				RemoveFromSmelter(fromInventory, fromSlot, itemInfo["name"], fromAmount, binData)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						RemoveFromSmelter(toInventory, toSlot, itemInfo["name"], toAmount)
						AddToSmelter(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('bj-radio:onRadioDrop', src)
						end
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToSmelter(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
				if itemInfo["name"] == "radio" then
					TriggerClientEvent('bj-radio:onRadioDrop', src)
				end
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn't exist", "error")
		end
	elseif BJCore.Shared.SplitStr(fromInventory, "-")[1] == "crafting" then
		fromInventory = BJCore.Shared.SplitStr(fromInventory, "-")[2]
		local fromItemData = Crafting[fromInventory].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromCrafting(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
                        fromAmount = fromItemData.amount
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToCrafting(fromInventory, fromSlot, toItemData.name, toAmount, toItemData.info)
						if toItemData.name == "radio" then
							TriggerClientEvent('bj-radio:onRadioDrop', src)
						end
						--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=fromInventory})
						--TriggerEvent("bj-log:server:CreateLog", "crafting", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - binid: *" .. fromInventory .. "*")
					else
						--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin3", name=toItemData.name, amount=toAmount, target=fromInventory})
						--TriggerEvent("bj-log:server:CreateLog", "crafting", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from binid: *" .. fromInventory .. "*")
					end
				else
					--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2bin2", name=fromItemData.name, amount=fromAmount, target=fromInventory})
					--TriggerEvent("bj-log:server:CreateLog", "crafting", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  binid: *" .. fromInventory .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
            elseif BJCore.Shared.SplitStr(toInventory, "-")[1] == "crafting" then
				local toItemData = Crafting[fromInventory].items[toSlot]
				if toItemData ~= nil then
                    RemoveFromCrafting(fromInventory, fromSlot, itemInfo["name"], fromAmount)
					local toItemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					if toItemData.name ~= fromItemData.name then
                        fromAmount = fromItemData.amount
						RemoveFromCrafting(fromInventory, toSlot, toItemData.name, toItemData.amount)
						AddToCrafting(fromInventory, fromSlot, toItemData.name, toItemData.amount)
						--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="glovebox1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=plate})
						--TriggerEvent("bj-log:server:CreateLog", "crafting", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..itemInfo["name"].."**, amount: **" .. toAmount .. "** with name: **" .. fromItemData.name .. "**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
					end
				else
                    RemoveFromCrafting(fromInventory, fromSlot, itemInfo["name"], fromAmount)
					--TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="glovebox2", name=fromItemData.name, amount=fromAmount, target=plate})
					--TriggerEvent("bj-log:server:CreateLog", "glovebox", "Dropped Item", "red", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) dropped new item; name: **"..itemInfo["name"].."**, amount: **" .. fromAmount .. "** - plate: *" .. plate .. "*")
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToCrafting(fromInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)	
			else
				toInventory = tonumber(toInventory)
				local toItemData = Crafting[toInventory].items[toSlot]
				RemoveFromCrafting(fromInventory, fromSlot, itemInfo["name"], fromAmount, binData)
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						RemoveFromCrafting(toInventory, toSlot, itemInfo["name"], toAmount)
						AddToCrafting(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('bj-radio:onRadioDrop', src)
						end
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToCrafting(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
				if itemInfo["name"] == "radio" then
					TriggerClientEvent('bj-radio:onRadioDrop', src)
				end
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn't exist", "error")
		end
	else
		-- drop
		fromInventory = tonumber(fromInventory)
		local fromItemData = Drops[fromInventory].items[fromSlot]
		local fromAmount = tonumber(fromAmount) ~= nil and tonumber(fromAmount) or fromItemData.amount
		if fromItemData ~= nil and fromItemData.amount >= fromAmount then
			local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.Functions.GetItemBySlot(toSlot)
				RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				if toItemData ~= nil then
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						Player.Functions.RemoveItem(toItemData.name, toAmount, toSlot)
						AddToDrop(fromInventory, toSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('bj-radio:onRadioDrop', src)
						end
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2drop1", toName=toItemData.name, toAmount=toAmount, fromName=fromItemData.name, fromAmount=fromAmount, target=fromInventory})
						TriggerEvent("bj-log:server:CreateLog", "drop", "Swapped Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) swapped item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** with item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount .. "** - dropid: *" .. fromInventory .. "*")
					else
						TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2drop3", name=toItemData.name, amount=toAmount, target=fromInventory})
						TriggerEvent("bj-log:server:CreateLog", "drop", "Stacked Item", "orange", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) stacked item; name: **"..toItemData.name.."**, amount: **" .. toAmount .. "** - from dropid: *" .. fromInventory .. "*")
					end
				else
					TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="2drop2", name=fromItemData.name, amount=fromAmount, target=fromInventory})
					TriggerEvent("bj-log:server:CreateLog", "drop", "Received Item", "green", "**".. GetPlayerName(src) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..src.."*) reveived item; name: **"..fromItemData.name.."**, amount: **" .. fromAmount.. "** -  dropid: *" .. fromInventory .. "*")
				end
				Player.Functions.AddItem(fromItemData.name, fromAmount, toSlot, fromItemData.info)
			else
				toInventory = tonumber(toInventory)
				local toItemData = Drops[toInventory].items[toSlot]
				RemoveFromDrop(fromInventory, fromSlot, itemInfo["name"], fromAmount)
				--Player.PlayerData.items[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
					--Player.PlayerData.items[fromSlot] = toItemData
					local toAmount = tonumber(toAmount) ~= nil and tonumber(toAmount) or toItemData.amount
					if toItemData.name ~= fromItemData.name then
						local itemInfo = BJCore.Shared.Items[toItemData.name:lower()]
						RemoveFromDrop(toInventory, toSlot, itemInfo["name"], toAmount)
						AddToDrop(fromInventory, fromSlot, itemInfo["name"], toAmount, toItemData.info)
						if itemInfo["name"] == "radio" then
							TriggerClientEvent('bj-radio:onRadioDrop', src)
						end
					end
				else
					--Player.PlayerData.items[fromSlot] = nil
				end
				local itemInfo = BJCore.Shared.Items[fromItemData.name:lower()]
				AddToDrop(toInventory, toSlot, itemInfo["name"], fromAmount, fromItemData.info)
				if itemInfo["name"] == "radio" then
					TriggerClientEvent('bj-radio:onRadioDrop', src)
				end
			end
		else
			TriggerClientEvent("BJCore:Notify", src, "Item doesn't exist", "error")
		end
	end
end)

function hasCraftItems(source, CostItems, amount)
	local Player = BJCore.Functions.GetPlayer(source)
	for k, v in pairs(CostItems) do
		if Player.Functions.GetItemByName(k) ~= nil then
			if Player.Functions.GetItemByName(k).amount < (v * amount) then
				return false
			end
		else
			return false
		end
	end
	return true
end

function IsVehicleOwned(plate)
	local val = false
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = @plate", function(result)
		if (result[1] ~= nil) then
			val = true
		else
			val = false
		end
	end, {["@plate"] = plate})
	return val
end

local function escape_str(s)
	local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
	local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
	for i, c in ipairs(in_char) do
	  s = s:gsub(c, '\\' .. out_char[i])
	end
	return s
end

-- Shop Items
function SetupShopItems(shop, shopItems)
	local items = {}
	if shopItems ~= nil and next(shopItems) ~= nil then
		for k, item in pairs(shopItems) do
			local itemInfo = BJCore.Shared.Items[item.name:lower()]
			items[item.slot] = {
				name = itemInfo["name"],
				amount = tonumber(item.amount),
				info = item.info ~= nil and item.info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"], 
				type = itemInfo["type"], 
				unique = itemInfo["unique"], 
				useable = itemInfo["useable"], 
				price = item.price or 0,
				image = itemInfo["image"],
				slot = item.slot,
			}
		end
	end
	return items
end

-- Generate Items
function SetupItems(data)
	local items = {}
	if data ~= nil and next(data) ~= nil then
		for k, item in pairs(data) do
			local itemInfo = BJCore.Shared.Items[item.name:lower()]
			items[item.slot] = {
				name = itemInfo["name"],
				amount = tonumber(item.amount),
				info = item.info ~= nil and item.info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"], 
				type = itemInfo["type"], 
				unique = itemInfo["unique"], 
				useable = itemInfo["useable"], 
				image = itemInfo["image"],
				slot = item.slot,
			}
		end
	end
	return items
end

-- Stash Items
function GetStashItems(stashId)
	local items = {}
	if Stashes[stashId] ~= nil and Stashes[stashId].temp then
		return Stashes[stashId].items
	end
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `stashitems` WHERE `stash` = @stashId", function(result)
		if result[1] ~= nil then
			if result[1].items ~= nil then
				result[1].items = json.decode(result[1].items)
				if result[1].items ~= nil then 
					for k, item in pairs(result[1].items) do
						local itemInfo = BJCore.Shared.Items[item.name:lower()]
						items[item.slot] = {
							name = itemInfo["name"],
							amount = tonumber(item.amount),
							info = item.info ~= nil and item.info or "",
							label = itemInfo["label"],
							description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
							weight = itemInfo["weight"],
							type = itemInfo["type"],
							unique = itemInfo["unique"],
							useable = itemInfo["useable"],
							shouldClose = itemInfo["shouldClose"],
							image = itemInfo["image"],
							slot = item.slot,
						}
					end
				end
			end
		end
	end, {["@stashId"] = stashId})
	return items
end

BJCore.Functions.RegisterServerCallback('bj-inventory:server:GetStashItems', function(source, cb, stashId)
	cb(GetStashItems(stashId))
end)

RegisterServerEvent('bj-inventory:server:SaveStashItems')
AddEventHandler('bj-inventory:server:SaveStashItems', function(stashId, items)
	BJCore.Functions.ExecuteSql(false, "SELECT * FROM `stashitems` WHERE `stash` = @stashId", function(result)
		if result[1] ~= nil then
			BJCore.Functions.ExecuteSql(false, "UPDATE `stashitems` SET `items` = @items WHERE `stash` = @stashId", nil, {
				["@items"] = json.encode(items),
				["@stashId"] = stashId,
			})
		else
			BJCore.Functions.ExecuteSql(false, "INSERT INTO `stashitems` (`stash`, `items`) VALUES (@stashId, @items)", nil, {
				["@stashId"] = stashId,
				["@items"] = json.encode(items)
			})
		end
	end, {["@stashId"] = stashId})
end)

function SaveStashItems(stashId, items, origin)
	if Stashes[stashId].label ~= "Stash-None" then
		if items == nil then
			items = Stashes[stashId].items
		end
		for slot, item in pairs(items) do
			item.description = nil
		end
		if string.find(stashId, "cookstation") then
			TriggerEvent("restaurant:manageCookStash", stashId, items, origin)
		end
		if Stashes[stashId].temp then
			Stashes[stashId].items = items
			Stashes[stashId].isOpen = false
			return
		end
		BJCore.Functions.ExecuteSql(false, "SELECT * FROM `stashitems` WHERE `stash` = @stashId", function(result)
			if result[1] ~= nil then
				BJCore.Functions.ExecuteSql(false, "UPDATE `stashitems` SET `items` = @items WHERE `stash` = @stashId", function(data)
					Stashes[stashId].isOpen = false
				end, {
					["@items"] = json.encode(items),
					["@stashId"] = stashId,
				})
			else
				BJCore.Functions.ExecuteSql(false, "INSERT INTO `stashitems` (`stash`, `items`) VALUES (@stashId, @items)", function(data)
					Stashes[stashId].isOpen = false
				end, {
					["@stashId"] = stashId,
					["@items"] = json.encode(items)
				})
			end
		end, {["@stashId"] = stashId})
	end
end
exports("SaveStashItems", SaveStashItems)

function AddToStash(stashId, slot, otherslot, itemName, amount, info, slots)
	if Stashes[stashId] == nil then
		stashItems = GetStashItems(stashId)
		if next(stashItems) ~= nil then
			Stashes[stashId] = {}
			Stashes[stashId].items = stashItems
			Stashes[stashId].isOpen = nil
			Stashes[stashId].label = ""
			Stashes[stashId].slots = slots ~= slots and slots or 50
		else
			Stashes[stashId] = {}
			Stashes[stashId].items = {}
			Stashes[stashId].isOpen = nil
			Stashes[stashId].label = ""
			Stashes[stashId].slots = slots ~= slots and slots or 50
		end
	end
	local amount = tonumber(amount)
	local ItemData = BJCore.Shared.Items[itemName]
	if not ItemData.unique then
		if Stashes[stashId].items[slot] ~= nil and Stashes[stashId].items[slot].name == itemName then
			Stashes[stashId].items[slot].amount = Stashes[stashId].items[slot].amount + amount
		else
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Stashes[stashId].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	else
        if Stashes[stashId].items[slot] ~= nil then
            local newSlot = slot
            for i = 1, Stashes[stashId].slots, 1 do
                if Stashes[stashId].items[i] == nil then
                    newSlot = i
                    break
                end
            end
            local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Stashes[stashId].items[newSlot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = newSlot,
			}
        else
            local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Stashes[stashId].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = slot,
			}
        end
	end
end
exports("AddToStash", AddToStash)

function RemoveFromStash(stashId, slot, itemName, amount)
	local amount = tonumber(amount)
	if Stashes[stashId].items[slot] ~= nil and Stashes[stashId].items[slot].name == itemName then
		if Stashes[stashId].items[slot].amount > amount then
			Stashes[stashId].items[slot].amount = Stashes[stashId].items[slot].amount - amount
		else
			Stashes[stashId].items[slot] = nil
			if next(Stashes[stashId].items) == nil then
				Stashes[stashId].items = {}
			end
		end
	else
		Stashes[stashId].items[slot] = nil
		if Stashes[stashId].items == nil then
			Stashes[stashId].items[slot] = nil
		end
	end
end
exports("RemoveFromStash", RemoveFromStash)

-- Trunk items
function GetOwnedVehicleItems(plate)
	local items = {}
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `trunkitems` WHERE `plate` = @plate", function(result)
		if result[1] ~= nil then
			if result[1].items ~= nil then
				result[1].items = json.decode(result[1].items)
				if result[1].items ~= nil then 
					for k, item in pairs(result[1].items) do
						local itemInfo = BJCore.Shared.Items[item.name:lower()]
						items[item.slot] = {
							name = itemInfo["name"],
							amount = tonumber(item.amount),
							info = item.info ~= nil and item.info or "",
							label = itemInfo["label"],
							description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
							weight = itemInfo["weight"], 
							type = itemInfo["type"], 
							unique = itemInfo["unique"], 
							useable = itemInfo["useable"],
							shouldClose = itemInfo["shouldClose"], 
							image = itemInfo["image"],
							slot = item.slot,
						}
					end
				end
			end
		end
	end, {["@plate"] = plate})
	return items
end

function SaveOwnedVehicleItems(plate, items)
	if Trunks[plate].label ~= "Trunk-None" then
		if items ~= nil then
			for slot, item in pairs(items) do
				item.description = nil
			end

			BJCore.Functions.ExecuteSql(false, "SELECT * FROM `trunkitems` WHERE `plate` = @plate", function(result)
				if result[1] ~= nil then
					BJCore.Functions.ExecuteSql(false, "UPDATE `trunkitems` SET `items` = @items WHERE `plate` = @plate", function(result) 
						Trunks[plate].isOpen = false
					end, {
						["@items"] = json.encode(items),
						["@plate"] = plate,
					})
				else
					BJCore.Functions.ExecuteSql(false, "INSERT INTO `trunkitems` (`plate`, `items`) VALUES (@plate, @items)", function(result) 
						Trunks[plate].isOpen = false
					end, {
						["@items"] = json.encode(items),
						["@plate"] = plate,
					})
				end
			end, {["@plate"] = plate})
		end
	end
end

function AddToTrunk(plate, slot, otherslot, itemName, amount, info)
	local amount = tonumber(amount)
	local ItemData = BJCore.Shared.Items[itemName]

	if not ItemData.unique then
		if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
			Trunks[plate].items[slot].amount = Trunks[plate].items[slot].amount + amount
		else
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Trunks[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"], 
				type = itemInfo["type"], 
				unique = itemInfo["unique"], 
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"], 
				image = itemInfo["image"],
				slot = slot,
			}
		end
	else
		if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Trunks[plate].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = otherslot,
			}
		else
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Trunks[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	end
end

function RemoveFromTrunk(plate, slot, itemName, amount)
	if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
		if Trunks[plate].items[slot].amount > amount then
			Trunks[plate].items[slot].amount = Trunks[plate].items[slot].amount - amount
		else
			Trunks[plate].items[slot] = nil
			if next(Trunks[plate].items) == nil then
				Trunks[plate].items = {}
			end
		end
	else
		Trunks[plate].items[slot]= nil
		if Trunks[plate].items == nil then
			Trunks[plate].items[slot] = nil
		end
	end
end

-- Glovebox items
function GetOwnedVehicleGloveboxItems(plate)
	local items = {}
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `gloveboxitemsnew` WHERE `plate` = @plate", function(result)
		if result[1] ~= nil then 
			if result[1].items ~= nil then
				result[1].items = json.decode(result[1].items)
				if result[1].items ~= nil then 
					for k, item in pairs(result[1].items) do
						local itemInfo = BJCore.Shared.Items[item.name:lower()]
						items[item.slot] = {
							name = itemInfo["name"],
							amount = tonumber(item.amount),
							info = item.info ~= nil and item.info or "",
							label = itemInfo["label"],
							description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
							weight = itemInfo["weight"],
							type = itemInfo["type"],
							unique = itemInfo["unique"],
							useable = itemInfo["useable"],
							shouldClose = itemInfo["shouldClose"],
							image = itemInfo["image"],
							slot = item.slot,
						}
					end
				end
			end
		end
	end, {["plate"] = plate})
	return items
end

function SaveOwnedGloveboxItems(plate, items)
	if Gloveboxes[plate].label ~= "Glovebox-None" then
		if items ~= nil then
			for slot, item in pairs(items) do
				item.description = nil
			end

			BJCore.Functions.ExecuteSql(false, "SELECT * FROM `gloveboxitemsnew` WHERE `plate` = @plate", function(result)
				if result[1] ~= nil then
					BJCore.Functions.ExecuteSql(false, "UPDATE `gloveboxitemsnew` SET `items` = @items WHERE `plate` = @plate", function(result) 
						Gloveboxes[plate].isOpen = false
					end, {
						["@items"] = json.encode(items),
						["@plate"] = plate,
					})
				else
					BJCore.Functions.ExecuteSql(false, "INSERT INTO `gloveboxitemsnew` (`plate`, `items`) VALUES (@plate, @items)", function(result) 
						Gloveboxes[plate].isOpen = false
					end, {
						["@items"] = json.encode(items),
						["@plate"] = plate,
					})
				end
			end, {["@plate"] = plate})
		end
	end
end

function AddToGlovebox(plate, slot, otherslot, itemName, amount, info)
	local amount = tonumber(amount)
	local ItemData = BJCore.Shared.Items[itemName]

	if not ItemData.unique then
		if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
			Gloveboxes[plate].items[slot].amount = Gloveboxes[plate].items[slot].amount + amount
		else
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Gloveboxes[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	else
		if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Gloveboxes[plate].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = otherslot,
			}
		else
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Gloveboxes[plate].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	end
end

function RemoveFromGlovebox(plate, slot, itemName, amount)
	if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
		if Gloveboxes[plate].items[slot].amount > amount then
			Gloveboxes[plate].items[slot].amount = Gloveboxes[plate].items[slot].amount - amount
		else
			Gloveboxes[plate].items[slot] = nil
			if next(Gloveboxes[plate].items) == nil then
				Gloveboxes[plate].items = {}
			end
		end
	else
		Gloveboxes[plate].items[slot]= nil
		if Gloveboxes[plate].items == nil then
			Gloveboxes[plate].items[slot] = nil
		end
	end
end

-- Safe Items
function GetSafeItems(safeId)
	local items = {}
	BJCore.Functions.ExecuteSql(true, "SELECT * FROM `player_safes` WHERE `safeid` = '"..safeId.."'", function(result)
		if result[1] ~= nil then 
			if result[1].items ~= nil then
				result[1].items = json.decode(result[1].items)
				if result[1].items ~= nil then 
					for k, item in pairs(result[1].items) do
						local itemInfo = BJCore.Shared.Items[item.name:lower()]
						items[item.slot] = {
							name = itemInfo["name"],
							amount = tonumber(item.amount),
							info = item.info ~= nil and item.info or "",
							label = itemInfo["label"],
							description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
							weight = itemInfo["weight"],
							type = itemInfo["type"],
							unique = itemInfo["unique"],
							useable = itemInfo["useable"],
							shouldClose = itemInfo["shouldClose"],
							image = itemInfo["image"],
							slot = item.slot,
						}
					end
				end
			end
		end
	end)
	return items
end

BJCore.Functions.RegisterServerCallback('bj-inventory:server:GetSafeItems', function(source, cb, safeId)
	cb(GetSafeItems(safeId))
end)

RegisterServerEvent('bj-inventory:server:SaveSafeItems')
AddEventHandler('bj-inventory:server:SaveSafeItems', function(safeId, items)
	BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_safes` WHERE `safeid` = '"..safeId.."'", function(result)
		if result[1] ~= nil then
			BJCore.Functions.ExecuteSql(false, "UPDATE `player_safes` SET `items` = '"..json.encode(items).."' WHERE `safeid` = '"..safeId.."'")
		else
			print("[Inventory:Safes] - Failed to save items for safeid: "..safeId)
			--BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_safes` (`safeid`, `items`) VALUES ('"..safeId.."', '"..json.encode(items).."')")
		end
	end)
end)

function SaveSafeItems(safeId, items)
	if Safes[safeId].label ~= "Safe-None" then
		if items ~= nil then
			for slot, item in pairs(items) do
				item.description = nil
			end

			BJCore.Functions.ExecuteSql(false, "SELECT * FROM `player_safes` WHERE `safeid` = '"..safeId.."'", function(result)
				if result[1] ~= nil then
					BJCore.Functions.ExecuteSql(false, "UPDATE `player_safes` SET `items` = '"..json.encode(items).."' WHERE `safeid` = '"..safeId.."'")
					Safes[safeId].isOpen = false
				else
					print("[Inventory:Safes] - Failed to save items for safeid: "..safeId)
					-- BJCore.Functions.ExecuteSql(false, "INSERT INTO `player_safes` (`safeid`, `items`) VALUES ('"..safeId.."', '"..json.encode(items).."')")
					-- Safes[safeId].isOpen = false
				end
			end)
		end
	end
end

function AddToSafe(safeId, slot, otherslot, itemName, amount, info)
	local amount = tonumber(amount)
	local ItemData = BJCore.Shared.Items[itemName]
	if not ItemData.unique then
		if Safes[safeId].items[slot] ~= nil and Safes[safeId].items[slot].name == itemName then
			Safes[safeId].items[slot].amount = Safes[safeId].items[slot].amount + amount
		else
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Safes[safeId].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	else
		if Safes[safeId].items[slot] ~= nil and Safes[safeId].items[slot].name == itemName then
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Safes[safeId].items[otherslot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = otherslot,
			}
		else
			local itemInfo = BJCore.Shared.Items[itemName:lower()]
			Safes[safeId].items[slot] = {
				name = itemInfo["name"],
				amount = amount,
				info = info ~= nil and info or "",
				label = itemInfo["label"],
				description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				shouldClose = itemInfo["shouldClose"],
				image = itemInfo["image"],
				slot = slot,
			}
		end
	end
end

function RemoveFromSafe(safeId, slot, itemName, amount)
	local amount = tonumber(amount)
	if Safes[safeId].items[slot] ~= nil and Safes[safeId].items[slot].name == itemName then
		if Safes[safeId].items[slot].amount > amount then
			Safes[safeId].items[slot].amount = Safes[safeId].items[slot].amount - amount
		else
			Safes[safeId].items[slot] = nil
			if next(Safes[safeId].items) == nil then
				Safes[safeId].items = {}
			end
		end
	else
		Safes[safeId].items[slot] = nil
		if Safes[safeId].items == nil then
			Safes[safeId].items[slot] = nil
		end
	end
end

-- Smelter Items
function AddToSmelter(id, slot, itemName, amount, info)
	local amount = tonumber(amount)
	if Smelter[id].items[slot] ~= nil and Smelter[id].items[slot].name == itemName then
		Smelter[id].items[slot].amount = Smelter[id].items[slot].amount + amount
	else
		local itemInfo = BJCore.Shared.Items[itemName:lower()]
		Smelter[id].items[slot] = {
			name = itemInfo["name"],
			amount = amount,
			info = info ~= nil and info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			image = itemInfo["image"],
			slot = slot,
			id = id,
		}
	end
end

function RemoveFromSmelter(id, slot, itemName, amount)
	if Smelter[id].items[slot] ~= nil and Smelter[id].items[slot].name == itemName then
		if Smelter[id].items[slot].amount > amount then
			Smelter[id].items[slot].amount = Smelter[id].items[slot].amount - amount
		else
			Smelter[id].items[slot] = nil
			if next(Smelter[id].items) == nil then
				Smelter[id].items = {}
				--TriggerClientEvent("inventory:client:RemoveDropItem", -1, id)
			end
		end
	else
		Smelter[id].items[slot] = nil
		if Smelter[id].items == nil then
			Smelter[id].items[slot] = nil
			--TriggerClientEvent("inventory:client:RemoveDropItem", -1, id)
		end
	end
end

-- Crafting Items
function AddToCrafting(id, slot, itemName, amount, info)
	local amount = tonumber(amount)
	if Crafting[id].items[slot] ~= nil and Crafting[id].items[slot].name == itemName then
		Crafting[id].items[slot].amount = Crafting[id].items[slot].amount + amount
	else
		local itemInfo = BJCore.Shared.Items[itemName:lower()]
		Crafting[id].items[slot] = {
			name = itemInfo["name"],
			amount = amount,
			info = info ~= nil and info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = slot,
			id = id,
		}
	end
end

function RemoveFromCrafting(id, slot, itemName, amount)
	if Crafting[id].items[slot] ~= nil and Crafting[id].items[slot].name == itemName then
		if Crafting[id].items[slot].amount > amount then
			Crafting[id].items[slot].amount = Crafting[id].items[slot].amount - amount
		else
			Crafting[id].items[slot] = nil
			if next(Crafting[id].items) == nil then
				Crafting[id].items = {}
				--TriggerClientEvent("inventory:client:RemoveDropItem", -1, id)
			end
		end
	else
		Crafting[id].items[slot] = nil
		if Crafting[id].items == nil then
			Crafting[id].items[slot] = nil
			--TriggerClientEvent("inventory:client:RemoveDropItem", -1, id)
		end
	end
end

-- Drop items
function AddToDrop(dropId, slot, itemName, amount, info)
	local amount = tonumber(amount)
	if Drops[dropId].items[slot] ~= nil and Drops[dropId].items[slot].name == itemName then
		Drops[dropId].items[slot].amount = Drops[dropId].items[slot].amount + amount
	else
		local itemInfo = BJCore.Shared.Items[itemName:lower()]
		Drops[dropId].items[slot] = {
			name = itemInfo["name"],
			amount = amount,
			info = info ~= nil and info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			shouldClose = itemInfo["shouldClose"],
			image = itemInfo["image"],
			slot = slot,
			id = dropId,
		}
	end
end

function RemoveFromDrop(dropId, slot, itemName, amount)
	if Drops[dropId].items[slot] ~= nil and Drops[dropId].items[slot].name == itemName then
		if Drops[dropId].items[slot].amount > amount then
			Drops[dropId].items[slot].amount = Drops[dropId].items[slot].amount - amount
		else
			Drops[dropId].items[slot] = nil
			if next(Drops[dropId].items) == nil then
				Drops[dropId].items = {}
				--TriggerClientEvent("inventory:client:RemoveDropItem", -1, dropId)
			end
		end
	else
		Drops[dropId].items[slot] = nil
		if Drops[dropId].items == nil then
			Drops[dropId].items[slot] = nil
			--TriggerClientEvent("inventory:client:RemoveDropItem", -1, dropId)
		end
	end
end

function CreateDropId(DropType)
	if DropType ~= nil then
		local id = math.random(10000, 99999)
		local dropid = id
		while DropType[dropid] ~= nil do
			id = math.random(10000, 99999)
			dropid = id
		end
		return dropid
	else
		local id = math.random(10000, 99999)
		local dropid = id
		return dropid
	end
end

function CreateNewDrop(source, fromSlot, toSlot, itemAmount, dropCoords)
	local Player = BJCore.Functions.GetPlayer(source)
	local itemData = Player.Functions.GetItemBySlot(fromSlot)
	if Player.Functions.RemoveItem(itemData.name, itemAmount, itemData.slot) then
		TriggerClientEvent("inventory:client:CheckWeapon", source, itemData.name)
		local itemInfo = BJCore.Shared.Items[itemData.name:lower()]
		local dropId = CreateDropId(Drops)
		Drops[dropId] = {}
		Drops[dropId].items = {}
        Drops[dropId].isOpen = false

		Drops[dropId].items[toSlot] = {
			name = itemInfo["name"],
			amount = itemAmount,
			info = itemData.info ~= nil and itemData.info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			shouldClose = itemInfo["shouldClose"],
			image = itemInfo["image"],
			slot = toSlot,
            id = dropId
        }
        DropsCache[dropId] = {
            id = dropId,
            coords = dropCoords
        }
		TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="3drop", name=itemData.name, amount=itemAmount})
		TriggerEvent("bj-log:server:CreateLog", "drop", "New Item Drop", "red", "**".. GetPlayerName(source) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..source.."*) dropped new item; name: **"..itemData.name.."**, amount: **" .. itemAmount .. "**")
		TriggerClientEvent("inventory:client:DropItemAnim", source)
		TriggerClientEvent("inventory:client:AddDropItem", -1, dropId, dropCoords)
		if itemData.name:lower() == "radio" then
			TriggerClientEvent('bj-radio:onRadioDrop', source)
		end
	else
		TriggerClientEvent("BJCore:Notify", src, "You don't have this item", "error")
		return
	end
end

-- Bins
function CreateNewBin(source, fromSlot, toSlot, itemAmount, binData)
	local Player = BJCore.Functions.GetPlayer(source)
	local itemData = Player.Functions.GetItemBySlot(fromSlot)
	if Player.Functions.RemoveItem(itemData.name, itemAmount, itemData.slot) then
		TriggerClientEvent("inventory:client:CheckWeapon", source, itemData.name)
		local itemInfo = BJCore.Shared.Items[itemData.name:lower()]
		local dropId = CreateDropId(Bins)
		binData.binid = dropId
		Bins[dropId] = {}
		Bins[dropId].items = {}

		Bins[dropId].items[toSlot] = {
			name = itemInfo["name"],
			amount = itemAmount,
			info = itemData.info ~= nil and itemData.info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			shouldClose = itemInfo["shouldClose"],
			image = itemInfo["image"],
			slot = toSlot,
            id = dropId
        }
		TriggerEvent("bj-log:server:sendLog", Player.PlayerData.citizenid, "itemswapped", {type="3bin", name=itemData.name, amount=itemAmount})
		TriggerEvent("bj-log:server:CreateLog", "bin", "New Bin Created", "red", "**".. GetPlayerName(source) .. "** (citizenid: *"..Player.PlayerData.citizenid.."* | id: *"..source.."*) dropped new item; name: **"..itemData.name.."**, amount: **" .. itemAmount .. "**")
		TriggerClientEvent("inventory:client:DropItemAnim", source)
		TriggerEvent("storage:server:CreateBin", binData)		
		if itemData.name:lower() == "radio" then
			TriggerClientEvent('bj-radio:onRadioDrop', source)
		end
	else
		TriggerClientEvent("BJCore:Notify", src, "You don't have this item", "error")
		return
	end
end

function AddToBin(dropId, slot, itemName, amount, info)
	local amount = tonumber(amount)
	if Bins[dropId].items[slot] ~= nil and Bins[dropId].items[slot].name == itemName then
		Bins[dropId].items[slot].amount = Bins[dropId].items[slot].amount + amount
	else
		local itemInfo = BJCore.Shared.Items[itemName:lower()]
		Bins[dropId].items[slot] = {
			name = itemInfo["name"],
			amount = amount,
			info = info ~= nil and info or "",
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"],
			type = itemInfo["type"],
			unique = itemInfo["unique"],
			useable = itemInfo["useable"],
			shouldClose = itemInfo["shouldClose"],
			image = itemInfo["image"],
			slot = slot,
			id = dropId,
		}
	end
end

function RemoveFromBin(dropId, slot, itemName, amount)
	if Bins[dropId].items[slot] ~= nil and Bins[dropId].items[slot].name == itemName then
		if Bins[dropId].items[slot].amount > amount then
			Bins[dropId].items[slot].amount = Bins[dropId].items[slot].amount - amount
		else
			Bins[dropId].items[slot] = nil
			if next(Bins[dropId].items) == nil then
				Bins[dropId].items = {}
			end
		end
	else
		Bins[dropId].items[slot] = nil
		if Bins[dropId].items == nil then
			Bins[dropId].items[slot] = nil
		end
	end
end

function SaveGunRecord(buyer, label, serialNum)
	local Player = BJCore.Functions.GetPlayer(buyer)
	local data = {
		weapon = label,
		serial = serialNum
	}
	BJCore.Functions.ExecuteSql(false, "INSERT INTO `weapon_records` (`citizenid`, `data`) VALUES (@citizenid, @data)", nil, {
		["@citizenid"] = Player.PlayerData.citizenid,
		["@data"] = json.encode(data)
	})
end

BJCore.Commands.Add("inv", "Open your inventory", {}, false, function(source, args)
    local Player = BJCore.Functions.GetPlayer(source)
	TriggerClientEvent("inventory:client:OpenInventory", source, Player.PlayerData.items)
end)

BJCore.Commands.Add("resetinv", "Reset inventory (in case of -None)", {{name="type", help="stash/trunk/glovebox"},{name="id/plate", help="ID of stash or license plate"}}, true, function(source, args)
	local invType = args[1]:lower()
	table.remove(args, 1)
	local invId = table.concat(args, " ")
	if invType ~= nil and invId ~= nil then 
		if invType == "trunk" then
			if Trunks[invId] ~= nil then 
				Trunks[invId].isOpen = false
			end
		elseif invType == "glovebox" then
			if Gloveboxes[invId] ~= nil then 
				Gloveboxes[invId].isOpen = false
			end
		elseif invType == "stash" then
			if Stashes[invId] ~= nil then 
				Stashes[invId].isOpen = false
			end
		else
			TriggerClientEvent('BJCore:Notify', source,  "Not a valid type", "error")
		end
	else
		TriggerClientEvent('BJCore:Notify', source,  "Arguments not filled out correctly", "error")
	end
end, "god")

-- BJCore.Commands.Add("setnui", "Zet nui aan/ui (0/1)", {}, true, function(source, args)
--     if tonumber(args[1]) == 1 then
--         TriggerClientEvent("inventory:client:EnableNui", src)
--     else
--         TriggerClientEvent("inventory:client:DisableNui", src)
--     end
-- end)

-- BJCore.Commands.Add("trunkpos", "Shows trunk position", {}, false, function(source, args)
-- 	TriggerClientEvent("inventory:client:ShowTrunkPos", source)
-- end)

BJCore.Commands.Add("rob", "Rob a player", {}, false, function(source, args)
	TriggerClientEvent("police:client:RobPlayer", source)
end)

BJCore.Commands.Add("giveitem", "Give item to a player", {{name="id", help="Plaer ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}}, true, function(source, args)
	local Player = BJCore.Functions.GetPlayer(tonumber(args[1]))
	local amount = tonumber(args[3])
	local itemData = BJCore.Shared.Items[tostring(args[2]):lower()]
	if Player ~= nil then
		if amount > 0 then
			if itemData ~= nil then
				-- check iteminfo
				local info = {}
				if itemData["name"] == "id_card" then
					info.citizenid = Player.PlayerData.citizenid
					info.firstname = Player.PlayerData.charinfo.firstname
					info.lastname = Player.PlayerData.charinfo.lastname
					info.birthdate = Player.PlayerData.charinfo.birthdate
					info.gender = Player.PlayerData.charinfo.gender
					info.nationality = Player.PlayerData.charinfo.nationality
				elseif itemData["type"] == "weapon" then
					amount = 1
					info.serial = tostring(Config.RandomInt(2) .. Config.RandomStr(3) .. Config.RandomInt(1) .. Config.RandomStr(2) .. Config.RandomInt(3) .. Config.RandomStr(4))
				elseif itemData["name"] == "harness" then
					info.uses = 20
				elseif itemData["name"] == "markedbills" then
					info.worth = math.random(5000, 10000)
				elseif itemData["name"] == "labkey" then
					info.lab = exports["qb-methlab"]:GenerateRandomLab()
				elseif itemData["name"] == "printerdocument" then
					info.url = "https://cdn.discordapp.com/attachments/645995539208470549/707609551733522482/image0.png"
				end

				if Player.Functions.AddItem(itemData["name"], amount, false, info) then
					TriggerClientEvent('BJCore:Notify', source, "You have given " ..GetPlayerName(tonumber(args[1])).." " .. itemData["name"] .. " ("..amount.. ")", "success")
				else
					TriggerClientEvent('BJCore:Notify', source,  "Can't give item", "error")
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Item doesn't exist")
			end
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Amount must be higher than 0")
		end
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online")
	end
end, "admin")

BJCore.Commands.Add("randomitems", "Give yourself random items (for testing)", {}, false, function(source, args)
	local Player = BJCore.Functions.GetPlayer(source)
	local filteredItems = {}
	for k, v in pairs(BJCore.Shared.Items) do
		if BJCore.Shared.Items[k]["type"] ~= "weapon" then
			table.insert(filteredItems, v)
		end
	end
	for i = 1, 10, 1 do
		local randitem = filteredItems[math.random(1, #filteredItems)]
		local amount = math.random(1, 10)
		if randitem["unique"] then
			amount = 1
		end
		if Player.Functions.AddItem(randitem["name"], amount) then
			TriggerClientEvent('inventory:client:ItemBox', source, BJCore.Shared.Items[randitem["name"]], 'add')
            Citizen.Wait(500)
		end
	end
end, "god")

BJCore.Functions.CreateUseableItem("id_card", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
    if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        local pos = GetEntityCoords(GetPlayerPed(source), false)
        TriggerClientEvent("inventory:client:ShowId", -1, pos, Player.PlayerData.citizenid, item.info)
    end
end)

BJCore.Functions.CreateUseableItem("snowball", function(source, item)
	local Player = BJCore.Functions.GetPlayer(source)
	local itemData = Player.Functions.GetItemBySlot(item.slot)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("inventory:client:UseSnowball", source, itemData.amount)
    end
end)

BJCore.Functions.CreateUseableItem("driver_license", function(source, item)
    local Player = BJCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        local pos = GetEntityCoords(GetPlayerPed(source), false)
        TriggerClientEvent("inventory:client:ShowDriverLicense", -1, pos, Player.PlayerData.citizenid, item.info)
    end
end)

Citizen.CreateThread(function()
	while BJCore == nil do Citizen.Wait(250); end
	PawnLimits = Config.PawnLimits
end)

function isPawnShop(name)
	local is = false
	if name == 'Itemsale_pawnshop1' or name == 'Itemsale_pawnshop2' or name == 'Itemsale_pawnshop3' or name == 'Itemsale_pawnshop4' then
		is = true
	end
	return is
end

function canSellPawn(location, item, amount)
	local canSell = 0
	if PawnLimits[location][item] > 0 and amount <= PawnLimits[location][item] then
		PawnLimits[location][item] = PawnLimits[location][item] - amount
		canSell = amount
	elseif PawnLimits[location][item] > 0 then
		canSell = PawnLimits[location][item]
		PawnLimits[location][item] = 0
	end
	return canSell
end

function CronTask(d, h, m)
	PawnLimits = Config.PawnLimits
end

TriggerEvent('cron:runAt', 22, 00, CronTask)

RegisterNetEvent("inventory:server:giveItem")
AddEventHandler("inventory:server:giveItem", function(targetPly, item, amount)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
		local Target = BJCore.Functions.GetPlayer(targetPly)
		if Target ~= nil then
			if Player.Functions.RemoveItem(item.name, amount, item.slot) then
				if Target.Functions.AddItem(item.name, amount, nil, item.info or nil) then
					TriggerClientEvent("inventory:client:CheckWeapon", src, item.name)
                    TriggerClientEvent('inventory:client:ItemBox', Target.PlayerData.source, BJCore.Shared.Items[item.name], "add")
                    TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[item.name], "remove")
				else
                    Player.Functions.AddItem(item.name, amount, item.slot, item.info or nil)
                    TriggerClientEvent('BJCore:Notify', src, "Target player doesn't have enough space to receive this item", 'error')
				end
			end
		end
	end
end)

RegisterNetEvent("inventory:server:destroyItem")
AddEventHandler("inventory:server:destroyItem", function(item, amount)
	local src = source
	local Player = BJCore.Functions.GetPlayer(src)
	if Player ~= nil then
		if Player.Functions.RemoveItem(item.name, amount, item.slot) then
			TriggerClientEvent("inventory:client:CheckWeapon", src, item.name)
            TriggerClientEvent('inventory:client:ItemBox', src, BJCore.Shared.Items[item.name], "remove")
        else
            TriggerClientEvent('BJCore:Notify', src, "Could not destroy "..tostring(amount).." items", 'error')
		end
	end
end)

function GetTrunkItems(id)
	local ret = {}
	if Trunks[id] ~= nil then ret = Trunks[id].items; end
	return ret
end
exports("GetTrunkItems", GetTrunkItems)