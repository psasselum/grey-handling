local A, GreyHandling = ...

print(format("%s: Launch by hitting left CTRL while holding SHIFT. (%s)", GreyHandling.NAME, GreyHandling.OPTION_COMMAND))
InterfaceOptions_AddCategory(GreyHandling.options.panel);
GameTooltip:HookScript("OnTooltipSetItem", GreyHandling.functions.ToolTipHook)
ItemRefTooltip:HookScript("OnTooltipSetItem", GreyHandling.functions.ToolTipHook)

function GreyHandling.frame:OnEvent(event, key, state)
	if key == "LCTRL" and state == 1 and IsShiftKeyDown() then
		if IsAddOnLoaded("Scrap") and not GreyHandling.alreadyAnnouncedScrap then
			print(format("%s: We're going to use Scrap to determine what is junk.", GreyHandling.NAME))
			GreyHandling.alreadyAnnouncedScrap = true
		end
		OpenAllBags()
		local foundSomething = false
		foundSomething = GreyHandling.functions.displayCheapestJunk(foundSomething)
		foundSomething = GreyHandling.functions.displayMutuallyBeneficialTrades(foundSomething)
		if not foundSomething then
			CloseAllBags()
		end
	end
end
GreyHandling.frame:RegisterEvent("MODIFIER_STATE_CHANGED")
GreyHandling.frame:SetScript("OnEvent", GreyHandling.frame.OnEvent)

function GreyHandling.loot_frame:OnLoot(event, chat_message, player_name, a, b, c, d, e, f, g, h, line_number, player_id, k, l, m, n, o)
	GreyHandling.functions.handleChatMessageLoot(chat_message, player_name, line_number, player_id, k, l, m, n, o)
end

GreyHandling.loot_frame:RegisterEvent("CHAT_MSG_LOOT")
GreyHandling.loot_frame:SetScript("OnEvent", GreyHandling.loot_frame.OnLoot)





