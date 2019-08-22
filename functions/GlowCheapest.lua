local A, GreyHandling = ...

function GreyHandling.functions.DisplayCheapest(text, item)
	if GreyHandling.options.VERBOSE then
		if item.itemCount == 1 then
			print(
				text, GetContainerItemLink(item.bag, item.slot), "worth", GetCoinTextureString(item.currentPrice),
				"(max ", GetCoinTextureString(item.potentialPrice), ")"
			)
		elseif item.potentialPrice == item.currentPrice then
			print(
				text, "A full stack of", GetContainerItemLink(item.bag, item.slot), "worth",
				GetCoinTextureString(item.potentialPrice)
			)
		else
			print(
				text, GetContainerItemLink(item.bag, item.slot), item.itemCount, "*",
				GetCoinTextureString(item.vendorPrice),	"=", GetCoinTextureString(item.currentPrice),
				"(max ", GetCoinTextureString(item.potentialPrice), ")"
			)
		end
	end
end

function GreyHandling.functions.GetCheapestItem()
	local now = {}
	now.currentPrice = nil
	local later = {}
	later.potentialPrice = nil
	for bagID = 0, NUM_BAG_SLOTS do
		for bagSlot = 1, GetContainerNumSlots(bagID) do
			if IsAddOnLoaded("ArkInventory") then
				local loc_id, bag_id = ArkInventory.BlizzardBagIdToInternalId(bagID)
				local _, item = ArkInventory.API.ItemFrameGet( loc_id, bag_id, bagSlot)
				ActionButton_HideOverlayGlow(item)
			end
			local itemid = GetContainerItemID(bagID, bagSlot)
			local itemLink = GetContainerItemLink(bagID, bagSlot)
			local _, itemCount = GetContainerItemInfo(bagID, bagSlot)
			if itemid then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
					itemEquipLoc, itemIcon, vendorPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID,
					isCraftingReagent = GetItemInfo(itemid)
				if (itemRarity == 0 and vendorPrice > 0) then
					-- or (itemRarity == 1 and
					-- (itemClassID == LE_ITEM_CLASS_WEAPON or itemClassID == LE_ITEM_CLASS_ARMOR))
					local _, itemCount = GetContainerItemInfo(bagID, bagSlot)
                    local currentDurability, maximumDurability = GetContainerItemDurability(bagID, bagSlot)
                    local modifier = 1
                    if currentDurability and maximumDurability then
                        modifier= currentDurability / maximumDurability
                    end
					local currentVendorPrice = vendorPrice * itemCount * modifier
					local potentialVendorPrice = vendorPrice * itemStackCount
					if now.currentPrice == nil or now.currentPrice > currentVendorPrice then
						now.currentPrice = currentVendorPrice
						now.potentialPrice = potentialVendorPrice
						now.itemCount = itemCount
						now.vendorPrice = vendorPrice
						now.bag = bagID
						now.slot = bagSlot
					end
					if later.potentialPrice == nil or
							later.potentialPrice > potentialVendorPrice or
							(later.potentialPrice==potentialVendorPrice and later.currentPrice > currentVendorPrice) then
						later.currentPrice = currentVendorPrice
						later.potentialPrice = potentialVendorPrice
						later.itemCount = itemCount
						later.vendorPrice = vendorPrice
						later.bag = bagID
						later.slot = bagSlot
					end
				end
			end
		end
	end
    return now, later
end

function GreyHandling.functions.GlowCheapestGrey()
    now, later = GreyHandling.functions.GetCheapestItem()
	if now.bag and now.slot then
		if now.bag==later.bag and now.slot==later.slot or now.potentialPrice == later.potentialPrice then
			-- Only one item is the cheapest
			GreyHandling.functions.DisplayCheapest("Cheapest:", now)
			PickupContainerItem(now.bag, now.slot)
			if GreyHandling.options.TALKATIVE then
				local itemLink = GetContainerItemLink(now.bag, now.slot)
				if now.itemCount == 1 then
					msg = format("I can give you %s if you have enough bag places.", itemLink)
				else
					msg = format("I can give you %s*%s if you have enough bag places.", itemLink, now.itemCount)
				end
				SendChatMessage(msg)
			end
			GreyHandling.functions.SetBagItemGlow(now.bag, now.slot, "bags-glow-orange")
			CloseAllBags()
		else
			-- Two items can be considered cheapest
			GreyHandling.functions.DisplayCheapest("Cheapest now:", now)
			GreyHandling.functions.DisplayCheapest("Cheapest later:", later)
			if IsAddOnLoaded("Inventorian") then
				if GreyHandling.options.VERBOSE then
					print("GreyHandling: It seems you're using Inventorian. Please note that the feature for glowing two items is not yet fully supported.")
				end
			else
				GreyHandling.functions.SetBagItemGlow(now.bag, now.slot, "bags-glow-orange")
				GreyHandling.functions.SetBagItemGlow(later.bag, later.slot, "bags-glow-orange")
			end
		end
	else
		print("GreyHandling: There are no grey items to throw away. Maybe you don't need this Hearthstone after all? ;)")
	end
end