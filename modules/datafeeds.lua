local _, recUI = ...
local lib = recUI.lib
local media = recUI.media

local format = string.format
local strfind = string.find
local strupper = string.upper
local tonumber = tonumber

-- Feed creation functions
local function createFeedFrame(name, from, to, x, y, w, h)
	local f = CreateFrame("Frame", name, UIParent)
	f:SetHeight(h)
	f:SetWidth(w)
	f:SetPoint(from, UIParent, to, x, y)
	f.Feeds = {}
	return f
end

local function createFeed(name, p, from, to, x, y)
	local feed = p:CreateFontString(name, "BORDER")
	feed:SetFont(media.font, 9, nil)
	feed:SetJustifyH("CENTER")
	feed:SetPoint(from, p, to, x, y+1)
	--feed:SetTextColor(0.27, 0.64, 0.78)
	feed:SetTextColor(1,1,1)
	return feed
end

-- Create feed frames
local feedFrames = {
	one = createFeedFrame("Feeds_1", "BOTTOM", "BOTTOM", 0, 15, 1312, 11),
}

local function update()
	for frame, _ in pairs(feedFrames) do
		local frame_width = feedFrames[frame]:GetWidth()
		local num_feeds = 0
		local feed_width = 0
		for feed, _ in pairs(feedFrames[frame].Feeds) do
			num_feeds = num_feeds + 1
			feed_width = feed_width + feedFrames[frame].Feeds[feed]:GetWidth()
		end
		local free_width = frame_width - feed_width
		local width_between = free_width/(num_feeds + 1)
		local width_position = width_between
		for feed, _ in pairs(feedFrames[frame].Feeds) do
			feedFrames[frame].Feeds[feed]:ClearAllPoints()
			feedFrames[frame].Feeds[feed]:SetPoint("LEFT", feedFrames[frame], "LEFT", width_position, 0)
			width_position = width_position + width_between + feedFrames[frame].Feeds[feed]:GetWidth()
		end
	end
end

feedFrames.one.Feeds.Bagspace = createFeed("Feeds_Bagspace", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Bagspace

local function GetBagSlots(index)
	local j, link
	local totalslots = GetContainerNumSlots(index)
	local filledslots = 0
	for j = 1, totalslots do
		link = GetContainerItemLink(index, j)
		if (link) then
			filledslots = filledslots + 1
		end
	end
	return filledslots, totalslots
end

local r,g,b
local function MakeDisplay(full, total, special)
	local leftText = ""
	local rightText = ""

	leftText = total - full

	rightText = format("/%s", total)

	local output = format("%s%s", leftText, rightText)

	if special then
		output = format("A: %s", output) --"|cFFFF00FF"..output.."|r"
	else
		output = format("B: %s", output)
	end
	return output
end

local bagData = {}
local function DataFeedBagUpdate()
	local i, j, totalSlots, fullSlots = nil, nil, 0, 0
	local displayString = ""
	local bagType
	for i = 0, NUM_BAG_FRAMES do
		if not(bagData[i]) then
			bagData[i] = {}
		else
			bagData[i].type = nil
			bagData[i].full = 0
			bagData[i].total = 0
		end
		bagType = GetItemFamily(GetBagName(i))
		if bagType then
			if (bagType > 0 and bagType < 1025) then
				-- Is specialty bag
				bagData[i].type = bagType
			end
		end
		bagData[i].full, bagData[i].total = GetBagSlots(i)
	end
	local displayString = ""
	for k,v in pairs(bagData) do
		if v.type then
			displayString = format("%s%s ", MakeDisplay(v.full, v.total, true), displayString)
		else
			totalSlots = totalSlots + v.total
			fullSlots = fullSlots + v.full
		end
	end
	if totalSlots > 0 then
		displayString = format("%s%s", displayString, MakeDisplay(fullSlots, totalSlots, false))
	end
	out:SetText(displayString)
	update()
end

lib.registerEvent("BAG_UPDATE", "recUIModuleDataFeedBag", DataFeedBagUpdate)
DataFeedBagUpdate()

feedFrames.one.Feeds.Clock = createFeed("Feeds_Clock", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Clock

local h, ap
local t = 1

local function DataFeedClockUpdate()
	h = tonumber(date("%H"))
	if floor(h/12) == 1 then ap = "p" else ap = "a" end
	h = mod(h, 12)
	if h == 0 then h = 12 end
	out:SetText(format("%d:%02d%s", h, tonumber(date("%M")), ap))
	update()
end

local function GetInvites()
	if CalendarGetNumPendingInvites() > 0 then
		out:SetTextColor(0, 1, 0)
	else
		out:SetTextColor(0.27, 0.64, 0.78)
	end
end

lib.registerEvent("CALENDAR_UPDATE_PENDING_INVITES", "recUIModuleDataFeedsClock", GetInvites)
lib.scheduleUpdate("recUIModuleDataFeedsClock", 1, DataFeedClockUpdate)

out.b = CreateFrame("Button", out)
out.b:SetAllPoints(out)
out.b:SetScript("OnClick", function()
	Calendar_LoadUI()
	CalendarFrame:SetScale(0.80)
	if CalendarFrame:IsShown() then
		Calendar_Hide()
		GetInvites()
	else
		Calendar_Show()
	end
end)

feedFrames.one.Feeds.Durability = createFeed("Feeds_Durability", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Durability

local slots = { "Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand", "Ranged" }

local function DurabilityUpdate()
	local num_items, perc = 0, 100
	for _,v in pairs(slots) do
		local current_durability, max_durability = GetInventoryItemDurability(GetInventorySlotInfo(format("%sSlot", v)))
		if current_durability and max_durability then

			local dmg = floor((current_durability / max_durability) * 100)
			if current_durability < max_durability then
				--Average
				--percentData = percentData + percentDamaged

				--Lowest
				if dmg > 0 and dmg < perc then perc = dmg end

				num_items = num_items + 1
			end
		end
	end

	--Average
	--perc = perc / num_items
	--if num_items == 0 then perc = 100 end

	--Lowest
	if perc == 0 and num_items < 1 then perc = 100 end

	out:SetText(format("%0.0f%%", perc))
	-- out:SetTextColor(lib.gradient(perc, 0, 100))
	update()
end

lib.registerEvent("MERCHANT_CLOSED", "recUIModuleDataFeedsDurability", DurabilityUpdate)
lib.registerEvent("UNIT_DIED", "recUIModuleDataFeedsDurability", DurabilityUpdate)
lib.registerEvent("PLAYER_REGEN_ENABLED", "recUIModuleDataFeedsDurability", DurabilityUpdate)
lib.registerEvent("PLAYER_ENTERING_WORLD", "recUIModuleDataFeedsDurability", DurabilityUpdate)
DurabilityUpdate()

-- Cancel loading this feed if player is level 80.
local player_level = UnitLevel("player")
if player_level ~= 80 then
	local UnitXP = UnitXP
	local UnitXPMax = UnitXPMax
	feedFrames.one.Feeds.Experience = createFeed("Feeds_Experience", feedFrames.one, "LEFT",	"LEFT", 0, 0)
	local out = feedFrames.one.Feeds.Experience
	out:SetText("---")

	local lastxp, a, b = 0
	local function ExperienceUpdate(retval, self, event, ...)
		if event == "CHAT_MSG_COMBAT_XP_GAIN" then
			_, _, lastxp = strfind(select(1, ...), ".*gain (.*) experience.*")
			lastxp = tonumber(lastxp)
			return
		end

		local petxp, petmaxxp

		local xp = UnitXP("player")
		local maxxp = UnitXPMax("player")
		if UnitGUID("pet") then
			petxp, petmaxxp = GetPetExperience()
		end

		local xpstring
		if not petmaxxp or petmaxxp == 0 then
			-- Cur/Max
			--xpstring = format("P:%s/%s", xp, maxxp)

			-- Perc
			xpstring = format("P:%.1f%%", ((xp/maxxp)*100))
		else
			-- Cur/Max - pet/pet
			--xpstring = format("P:%s/%s p:%s/%s", xp, maxxp, petxp, petmaxxp)

			-- Perc
			xpstring = format("P:%.1f%% p:%.0f%%", ((xp/maxxp)*100), ((petxp/petmaxxp)*100))
		end

		out:SetText(xpstring)

		if retval then
			local ktg = (maxxp - xp)/(lastxp or 0)
			if not lastxp or lastxp < 1 then ktg = "Unknown" else ktg = format("%.1f", ktg) end
			return format("Player: %s/%s (%.1f%%)", xp, maxxp, ((xp/maxxp)*100)), (petmaxxp and petmaxxp > 0) and format("Pet: %s/%s (%.0f%%)", petxp, petmaxxp, ((petxp/petmaxxp)*100)) or nil, format("Kills to go: %s", ktg)
		end
		update()
	end

	local function ShowTooltip(self, ...)
		if not IsShiftKeyDown() then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local playerxp, petxp, ktg = ExperienceUpdate(true)
		GameTooltip:AddLine(playerxp)
		if petxp then GameTooltip:AddLine(petxp) end
		if ktg then GameTooltip:AddLine(ktg) end
		GameTooltip:Show()
	end

	lib.registerEvent("PLAYER_ENTERING_WORLD", "recUIDataFeedsExperience", ExperienceUpdate)
	lib.registerEvent("CHAT_MSG_COMBAT_XP_GAIN", "recUIDataFeedsExperience", ExperienceUpdate)
	lib.registerEvent("UNIT_PET", "recUIDataFeedsExperience", ExperienceUpdate)
	lib.registerEvent("UNIT_EXPERIENCE", "recUIDataFeedsExperience", ExperienceUpdate)
	lib.registerEvent("UNIT_LEVEL", "recUIDataFeedsExperience", ExperienceUpdate)
	lib.registerEvent("PLAYER_XP_UPDATE", "recUIDataFeedsExperience", ExperienceUpdate)

	out.b = CreateFrame("Button", out)
	out.b:SetAllPoints(out)
	out.b:SetScript("OnEnter", ShowTooltip)
	out.b:SetScript("OnLeave", function(...) GameTooltip:Hide() end)
	ExperienceUpdate()
end

feedFrames.one.Feeds.Framerate = createFeed("Feeds_Framerate", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Framerate

local framerate
local function FramerateUpdate()
	framerate = floor((tonumber(GetFramerate()) or 0))
	out:SetText(format("%sfps", framerate))
	-- out:SetTextColor(lib.gradient(framerate, 0, 60))
	update()
end

lib.scheduleUpdate("recUIDataFeedsFramerate", 2, FramerateUpdate)
FramerateUpdate()

feedFrames.one.Feeds.Latency = createFeed("Feeds_Latency", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Latency

local lat, clat = 0, 0
local function LatencyUpdate()
	clat = select(3, GetNetStats())
	if type(clat) == "number" then lat = clat end
	out:SetText(format("%sms", lat))
	--out:SetTextColor(lib.gradient(lat, 0, 500, true))
	update()
end

lib.scheduleUpdate("recUIDataFeedsLatency", 60, LatencyUpdate)
LatencyUpdate()

local s_lfg						= "LFG"
local m_queued					= "queued"
local m_listed					= "listed"
local m_proposal				= "proposal"
local unknown_time				= "Unknown"
local m_rolecheck				= "rolecheck"
local s_lfgraid					= "LFR (%s)"
local role_format				= "|cFF%s%s|r"
local GetLFGMode				= GetLFGMode
local tank, heal, dps			= "T", "H", "D"
local CreateFrame				= CreateFrame
local s_lfgsearch				= "LFG (%s)"
local SecondsToTime				= SecondsToTime
local MiniMapLFGFrame			= MiniMapLFGFrame
local red, green				= "FF0000", "00FF00"
local GetLFGQueueStats			= GetLFGQueueStats
local ToggleDropDownMenu		= ToggleDropDownMenu
local ToggleLFRParentFrame		= ToggleLFRParentFrame
local ToggleLFDParentFrame		= ToggleLFDParentFrame
local LFDDungeonReadyPopup		= LFDDungeonReadyPopup
local MiniMapLFGFrameDropDown	= MiniMapLFGFrameDropDown
local StaticPopupSpecial_Show	= StaticPopupSpecial_Show
local lfg_roles_format			= "|cFF00FF00LFG:|r %s%s%s%s%s %s"
--local ID						= Lib_DungeonID

feedFrames.one.Feeds.LFG = createFeed("Feeds_LFG", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.LFG

local function LFGUpdate()
	MiniMapLFGFrame:UnregisterAllEvents()
	MiniMapLFGFrame:Hide()
	MiniMapLFGFrame.Show = function() end
	local data_present, _, tanks_needed, healers_needed, dps_needed, _, _, _, _, _, _, wait_time = GetLFGQueueStats()
	local mode, _ = GetLFGMode()

	if mode then
		out:SetTextColor(0, 1, 0)
	else
		out:SetTextColor(1, 0, 0)
	end

	local dungeon_names = ""
	--[[for k,v in pairs(LFGQueuedForList) do
		if k > 0 and ID:GetDungeonNameByID(k) then
			-- This uses Lib_DungeonID, because sometimes LFGGetDungeonInfoByID() returns nil
			-- when it should contain a table of data about the dungeon instead.
			dungeon_names = format("%s%s", ID:GetDungeonAbbreviationByID(k), (dungeon_names ~= "" and format(", %s", dungeon_names) or ""))
		end
	end	--]]

	if mode == m_listed then
		out:SetText(format(s_lfgraid, dungeon_names ~= "" and dungeon_names or "Raid"))
		return
	elseif mode == m_queued and not data_present then
		out:SetText(format(s_lfgsearch, dungeon_names ~= "" and dungeon_names or "Searching"))
		return
	elseif not data_present then
		out:SetText(s_lfg)
		return
	end

	--if not data_present or not mode == m_queued or not mode == m_listed or not mode == m_rolecheck then
		--if mode and not mode == m_queued or not mode == m_listed or not mode == m_rolecheck then
			--out:SetText(s_lfgsearch)
		--else
			--out:SetText(s_lfg)
		--end
		--return
	--end

	out:SetText(
		format(lfg_roles_format,
			format(role_format, tanks_needed == 0 and green or red, tank),
			format(role_format, healers_needed == 0 and green or red, heal),
			format(role_format, dps_needed == 3 and red or green, dps),
			format(role_format, dps_needed >= 2 and red or green, dps),
			format(role_format, dps_needed >= 1 and red or green, dps),
			(wait_time ~= -1 and SecondsToTime(wait_time, false, false, 1) or unknown_time)
		)
	)

	update()
end

out.b = CreateFrame("Button", out)
out.b:SetAllPoints(out)

lib.registerEvent("PLAYER_ENTERING_WORLD", "recUIDataFeedsLFG", LFGUpdate)
lib.registerEvent("LFG_QUEUE_STATUS_UPDATE", "recUIDataFeedsLFG", LFGUpdate)
lib.registerEvent("LFG_UPDATE", "recUIDataFeedsLFG", LFGUpdate)
lib.registerEvent("UPDATE_LFG_LIST", "recUIDataFeedsLFG", LFGUpdate)
lib.registerEvent("LFG_ROLE_CHECK_UPDATE", "recUIDataFeedsLFG", LFGUpdate)
lib.registerEvent("LFG_PROPOSAL_UPDATE", "recUIDataFeedsLFG", LFGUpdate)
lib.registerEvent("PARTY_MEMBERS_CHANGED", "recUIDataFeedsLFG", LFGUpdate)
out.b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
out.b:SetScript("OnClick", function(self, button, ...)
	-- Toggle the LFD/R window on left click.
	local mode, _ = GetLFGMode()
	if button == "LeftButton" then
		if mode == m_listed then
			ToggleLFRParentFrame()
		else
			ToggleLFDParentFrame()
		end
	elseif button == "RightButton" then
		if mode == m_proposal then
			if not LFDDungeonReadyPopup:IsShown() then
				StaticPopupSpecial_Show(LFDDungeonReadyPopup)
				return
			end
		end

		-- This should work fine, regardless of where the frame is at - I believe the dropdown is forced onto the screen
		-- by default - but, the drop down is intended to show up and to the right of the frame.  Ideally, this should be
		-- modified to auto-change based on the location of the lfg frame relative to the screen, but I have not had any
		-- issues having it set this way.
		MiniMapLFGFrameDropDown.point = "BOTTOMLEFT"
		MiniMapLFGFrameDropDown.relativePoint = "TOPRIGHT"
		ToggleDropDownMenu(1, nil, MiniMapLFGFrameDropDown, out.b, 0, 0)
	end
end)

LFGUpdate()

--feedFrames.one.Feeds.Mail = createFeed("Feeds_Mail", feedFrames.one, "LEFT",	"LEFT", 0, 0)
--local out = feedFrames.one.Feeds.Mail
--out:SetText("Mail")

local mailFeed = CreateFrame("Frame", "MailFeedFrame", Minimap)
mailFeed:SetSize(16, 16)
mailFeed:SetPoint("BOTTOMLEFT", 5, 0)
mailFeed:EnableMouse(true)

mailFeed.icon = mailFeed:CreateTexture(nil, "OVERLAY")
mailFeed.icon:SetAllPoints()
mailFeed.icon:SetTexture([[Interface\Addons\recUI\media\texture\mail]])
mailFeed.icon:SetVertexColor(1,.3,.3,1)

local has
local function MailUpdate()
	if HasNewMail() then
		if not has then
			PlaySoundFile("Interface\AddOns\recUI\media\sound\Mail.mp3")
			has = true
		end
		mailFeed.icon:SetVertexColor(.3,1,.3,1)
	else
		has = false
		mailFeed.icon:SetVertexColor(1,.3,.3,1)
	end
end

lib.registerEvent("UPDATE_PENDING_MAIL", "recUIDataFeedsMail", MailUpdate)
lib.registerEvent("MAIL_CLOSED", "recUIDataFeedsMail", MailUpdate)

mailFeed:SetScript("OnEnter", function(self)
	--if IsShiftKeyDown() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(has and "New Mail!" or "No Mail!")
		GameTooltip:Show()
	--end
end)
mailFeed:SetScript("OnLeave", function() GameTooltip:Hide() end)
MailUpdate()

feedFrames.one.Feeds.Memory = createFeed("Feeds_Memory", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Memory

local function PrettyMemory(n)
	if n > 1024 then
		return format("%.2f mb", n / 1024)
	else
		return format("%.2f kb", n)
	end
end

local function MemoryUpdate()
	UpdateAddOnMemoryUsage()
	local usage = 0
	for i=1,GetNumAddOns() do
		if IsAddOnLoaded(i) then
			usage = usage + GetAddOnMemoryUsage(i)
		end
	end
	out:SetText(PrettyMemory(usage))
	-- out:SetTextColor(lib.gradient(usage, 0, 15360, true))
	update()
end

local function OnClick()
	GameTooltip:Hide()
	collectgarbage("collect")
	MemoryUpdate()
end

local function MemSort(x,y)
	return x.mem > y.mem
end

local MemoryTable = {}
local function OnEnter()
	if not IsShiftKeyDown() then return end
	GameTooltip:SetOwner(out.b,"ANCHOR_RIGHT")

	UpdateAddOnMemoryUsage()
	local total = 0

	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			local memused = GetAddOnMemoryUsage(i)
			total = total + memused
			table.insert(MemoryTable, {addon = GetAddOnInfo(i), mem = memused})
		end
	end

	table.sort(MemoryTable, MemSort)
	local txt = "%d. %s"

	for k, v in pairs(MemoryTable) do
		GameTooltip:AddDoubleLine(format(txt, k, v.addon), PrettyMemory(v.mem), 0, 1, 1, 0, 1, 0)
	end

	for i = 1, #MemoryTable do
		MemoryTable[i] = nil
	end

	GameTooltip:AddDoubleLine("Total Usage", PrettyMemory(total), 1, 1, 1, 0, 1, 0)
	GameTooltip:Show()
end

out.b = CreateFrame("Button", out)
out.b:SetAllPoints(out)
out.b:SetScript("OnClick", OnClick)
out.b:SetScript("OnEnter", OnEnter)
out.b:SetScript("OnLeave", function() GameTooltip:Hide() end)

lib.scheduleUpdate("recUIDataFeedsMemory", 10, MemoryUpdate)
MemoryUpdate()

feedFrames.one.Feeds.Money = createFeed("Feeds_Money", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Money
out:SetText("---")

local function MoneyUpdate()
	local gold, silver, copper
	copper = GetMoney()

	gold = floor(copper / 10000)
	silver = mod(floor(copper / 100), 100)
	copper = mod(copper, 100)

	out:SetText(format("|cFFFFD700%dg|r |cFFC7C7CF%ds|r |cFFEDA55F%dc|r", gold or 0, silver or 0, copper or 0))
	update()
end
lib.registerEvent("PLAYER_ENTERING_WORLD", "recUIDataFeedMoney", MoneyUpdate)
lib.registerEvent("PLAYER_MONEY", "recUIDataFeedMoney", MoneyUpdate)
MoneyUpdate()


feedFrames.one.Feeds.PvP = createFeed("Feeds_PvP", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.PvP

local function PvPUpdate()
	out:SetText("PvP")
	if MiniMapBattlefieldFrame.tooltip and strfind(MiniMapBattlefieldFrame.tooltip, "You are in the queue") then
		out:SetTextColor(0, 1, 0)
	else
		out:SetTextColor(1, 0, 0)
	end
	update()
end

--"You are in the queue for Battleground Name\nAverage wait time: < 1 minute (Last 10 players)\nTime in queue: |4Sec:Sec\nYou are in the queue........\n|cffffffff<Right Click> for PvP Options|r"

local event = CreateFrame("Frame")
lib.registerEvent("PLAYER_ENTERING_WORLD", "recUIDataFeedPvP", PvPUpdate)
lib.registerEvent("PLAYER_ENTERING_WORLD", "recUIDataFeedPvP", PvPUpdate)
lib.registerEvent("BATTLEFIELDS_SHOW", "recUIDataFeedPvP", PvPUpdate)
lib.registerEvent("BATTLEFIELDS_CLOSED", "recUIDataFeedPvP", PvPUpdate)
lib.registerEvent("UPDATE_BATTLEFIELD_STATUS", "recUIDataFeedPvP", PvPUpdate)
lib.registerEvent("PARTY_LEADER_CHANGED", "recUIDataFeedPvP", PvPUpdate)
lib.registerEvent("ZONE_CHANGED", "recUIDataFeedPvP", PvPUpdate)
lib.registerEvent("ZONE_CHANGED_NEW_AREA", "recUIDataFeedPvP", PvPUpdate)

out.b = CreateFrame("Button", out)
out.b:SetAllPoints(out)
out.b:SetScript("OnEnter", function(self)
	if not IsShiftKeyDown() then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local tip = MiniMapBattlefieldFrame.tooltip or "Not Queued"
	GameTooltip:AddLine(tip)
	GameTooltip:Show()
end)
out.b:SetScript("OnLeave", function() GameTooltip:Hide() end)
out.b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
out.b:SetScript("OnClick", function(self, button, ...)
	if button == "LeftButton" and IsShiftKeyDown() then
		ToggleBattlefieldMinimap()
	elseif button == "LeftButton" and not(IsShiftKeyDown())then
		tinsert(UISpecialFrames, "PVPParentFrame")
		PVPParentFrame:Show()
	elseif button == "RightButton" and not(IsShiftKeyDown()) then
		ToggleDropDownMenu(1, nil, MiniMapBattlefieldDropDown, self, 0, -5)
	elseif button == "RightButton" and IsShiftKeyDown() then
		ToggleWorldStateScoreFrame();
	end
end)

PvPUpdate()

feedFrames.one.Feeds.Reputation = createFeed("Feeds_Reputation", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Reputation

local function ReputationUpdate(retval)
	if(not GetWatchedFactionInfo()) then
		out:SetText("...")
		return
	end

	local name, id, min, max, value = GetWatchedFactionInfo()
	local standing = GetText(format("FACTION_STANDING_LABEL%d", id))

	out:SetText(format("%s: %d / %d (%s)", name, (value - min), (max - min), standing))

	--[[if retval then
		return format("%s: %d / %d (%s)", name, (value - min), (max - min), standing)
	end--]]
	update()
end

--[[local function ShowTooltip(self)
	if not IsShiftKeyDown() then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(Update(true))
	GameTooltip:Show()
end--]]

out.b = CreateFrame("Button", out)
out.b:SetAllPoints(out)
--[[out.b:SetScript("OnEnter", ShowTooltip)
out.b:SetScript("OnLeave", function() GameTooltip:Hide() end)--]]
out.b:SetScript("OnClick", function()
	ToggleCharacter("ReputationFrame")
end)

lib.registerEvent("UPDATE_FACTION", "recUIDataFeedReputation", ReputationUpdate)
lib.registerEvent("PLAYER_ENTERING_WORLD", "recUIDataFeedReputation", ReputationUpdate)

ReputationUpdate()


feedFrames.one.Feeds.Guild = createFeed("Feeds_Guild", feedFrames.one, "LEFT",	"LEFT", 0, 0)
local out = feedFrames.one.Feeds.Guild
	out.b = CreateFrame("Button", out)
	out.b:SetAllPoints(out)
local num_friends = 0
local num_online_friends = 0
local num_guild_members = 0
local num_online_guild_members = 0

local function on_enter()
	if not IsShiftKeyDown() then return end

	num_guild_members = GetNumGuildMembers()
	GameTooltip:SetOwner(out.b,"ANCHOR_RIGHT")
	GameTooltip:AddLine("|cFFFFFFFFOnline Guild Members|r")

	for member_index = 1, num_guild_members do
       	local member_name, member_rank, member_rank_index, member_level, member_class_print, member_zone, member_note, member_officer_note, member_is_online, member_status, member_class = GetGuildRosterInfo(member_index)
       	if member_is_online then
			local class_output = format("|cFF%02x%02x%02x%s|r", RAID_CLASS_COLORS[member_class].r*255, RAID_CLASS_COLORS[member_class].g*255, RAID_CLASS_COLORS[member_class].b*255, member_class_print)

			GameTooltip:AddDoubleLine(
				format("|cFF%02x%02x%02x%s %s %s|r",
					RAID_CLASS_COLORS[member_class].r*255,
					RAID_CLASS_COLORS[member_class].g*255,
					RAID_CLASS_COLORS[member_class].b*255,
					member_level, member_status, member_name),
				format("|cFFFFFFFF%s|r", member_zone)
			)
		end
	end

	num_friends = GetNumFriends()
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cFFFFFFFFOnline Friends|r")

	for i = 1, num_friends do
		local friend_name, friend_level, friend_class, friend_area, friend_is_online, friend_status, friend_note = GetFriendInfo(i)
		if friend_is_online then
			friend_class = strupper(friend_class)
			if friend_class:find(" ") then
				friend_class = "DEATHKNIGHT"
			end
			GameTooltip:AddDoubleLine(
				format("|cFF%02x%02x%02x%s %s %s|r",
					RAID_CLASS_COLORS[strupper(friend_class)].r*255,
					RAID_CLASS_COLORS[strupper(friend_class)].g*255,
					RAID_CLASS_COLORS[strupper(friend_class)].b*255, friend_level, friend_status, friend_name),
				format("|cFFFFFFFF%s|r", friend_area)
			)
		end
	end
	GameTooltip:Show()
end

local function on_click()
	if GuildFrame:IsShown() then
		FriendsFrame:Hide()
	else
		FriendsFrame:Show()
		FriendsFrameTab3:Click()
	end
end

lib.scheduleUpdate("recUIDataFeedGuild", 15, function()
	if IsInGuild("player") then
		GuildRoster()
	end
end)

local guild_text, friend_text
local function DFGEvent(self, event)
	if event == "GUILD_ROSTER_UPDATE" then
		if IsInGuild("player") then
        		num_online_guild_members = 0
        		num_guild_members = GetNumGuildMembers()
        		for member_index = 1, num_guild_members do
    				local member_class, _, _, _, member_is_online = select(5, GetGuildRosterInfo(member_index))
			    	if member_is_online then
        		        	num_online_guild_members = num_online_guild_members + 1
    				end
        		end
		end
	end
	--elseif event == "FRIENDLIST_UPDATE" then
		num_online_friends = 0
		num_friends = GetNumFriends()
		if num_friends > 0 then
			for i = 1, num_friends do
				local friend_is_online = select(5,GetFriendInfo(i))
				if friend_is_online then
					num_online_friends = num_online_friends + 1
				end
			end
		end
	--end

	-- Remove yourself from the count.
	num_online_guild_members = num_online_guild_members - 1

	guild_text = num_online_guild_members > 0 and format("%s:%d", num_online_friends > 0 and "G" or "Guild", num_online_guild_members) or nil
	friend_text = num_online_friends > 0 and format("%s:%d", num_online_guild_members > 0 and "F" or "Friends", num_online_friends) or nil
	out:SetText( (guild_text or friend_text) and format("%s%s%s", guild_text and guild_text or "", guild_text and friend_text and " " or "", friend_text and friend_text or "") or "Lonely")
	if guild_text or friend_text then
		out:SetTextColor(0, 1, 0)
	else
		out:SetTextColor(1, 0, 0)
	end
	update()
end

lib.registerEvent("GUILD_ROSTER_UPDATE", "recUIDataFeedGuild", DFGEvent)
lib.registerEvent("FRIENDLIST_UPDATE", "recUIDataFeedGuild", DFGEvent)
out.b:SetScript("OnClick", on_click)
out.b:SetScript("OnEnter", on_enter)
out.b:SetScript("OnLeave", function() GameTooltip:Hide() end)
DFGEvent()