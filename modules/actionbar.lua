-- This module combines rActionBarStyler, rActionButtonStyler, and RedRange addons.  It is very heavily edited from the originals.
local _, recUI = ...

local _G = _G

recUI.lib.registerEvent("PLAYER_ENTERING_WORLD", "recUIActionBarShowAndGrid", function()
	-- Make textures for action bar 1 show all the time.
	ActionButton_HideGrid = function() end
	for i = 1,12 do
		local button = _G[format("ActionButton%d", i)]
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
		button = _G[format("BonusActionButton%d", i)]
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
	end

	-- Show all bars but the last one on login.	
	SHOW_MULTI_ACTIONBAR_1 = true
	SHOW_MULTI_ACTIONBAR_2 = true
	SHOW_MULTI_ACTIONBAR_3 = true
	SHOW_MULTI_ACTIONBAR_4 = false
	InterfaceOptions_UpdateMultiActionBars()
	
	recUI.lib.unregisterEvent("PLAYER_ENTERING_WORLD", "recUIActionBarShowAndGrid")
end)

---------------------------------------------------
-- CREATE ALL THE HOLDER FRAMES
---------------------------------------------------

-- Frame to hold the ActionBar1 and the BonusActionBar
local bar1Holder = CreateFrame("Frame","Bar1Holder",UIParent)
bar1Holder:SetWidth(172)
bar1Holder:SetHeight(60)
bar1Holder:SetPoint("BOTTOM", UIParent, "BOTTOM", -165, 115)

-- Frame to hold the MultibarBottomLeft
local bar2Holder = CreateFrame("Frame","Bar2Holder",UIParent)
bar2Holder:SetWidth(172)
bar2Holder:SetHeight(60)
bar2Holder:SetPoint("BOTTOM", UIParent, "BOTTOM", 165, 115)

-- Frame to hold the MultibarRight
local bar3Holder = CreateFrame("Frame","Bar3Holder",UIParent)
bar3Holder:SetWidth(172)
bar3Holder:SetHeight(60)
bar3Holder:SetPoint("BOTTOM", UIParent, "BOTTOM", -165, 35)

-- Frame to hold the right bars
local bar45Holder = CreateFrame("Frame","Bar45Holder",UIParent)
bar45Holder:SetWidth(172)
bar45Holder:SetHeight(60)
bar45Holder:SetPoint("BOTTOM", UIParent, "BOTTOM", 165, 35)

-- Frame to hold the pet bars
local petBarHolder = CreateFrame("Frame","PetBarHolder",UIParent)
petBarHolder:SetWidth(120)
petBarHolder:SetHeight(47)
petBarHolder:SetPoint("BOTTOM", UIParent, "BOTTOM", -337, 344)

-- Frame to hold the shapeshift bars
local shiftBarHolder = CreateFrame("Frame","ShapeShiftHolder",UIParent)
shiftBarHolder:SetWidth(355)
shiftBarHolder:SetHeight(50)
shiftBarHolder:SetScale(.6)
shiftBarHolder:SetAlpha(1)
shiftBarHolder:SetPoint("BOTTOMLEFT", bar1Holder, "TOPLEFT")

-- Frame to hold the vehicle button
local vehicleButton = CreateFrame("Frame","VEBHolder",UIParent)
vehicleButton:SetWidth(70)
vehicleButton:SetHeight(70)
vehicleButton:SetPoint("BOTTOM", -150, 277)

---------------------------------------------------
-- CREATE MY OWN VEHICLE EXIT BUTTON
---------------------------------------------------

local veb = CreateFrame("BUTTON", "VehicleExitButton", vehicleButton, "SecureActionButtonTemplate")
veb:SetWidth(32.5)
veb:SetHeight(32.5)
veb:SetPoint("CENTER",0,0)
veb:SetAlpha(0)
veb:RegisterForClicks("AnyUp")
veb:SetNormalTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Up]])
veb:SetPushedTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]])
veb:SetHighlightTexture([[Interface\Vehicles\UI-Vehicles-Button-Exit-Down]])
veb:SetScript("OnClick", function(self) VehicleExit() end)
local function OnVehicle(self, event, unit)
	if(((event=="UNIT_ENTERING_VEHICLE") or (event=="UNIT_ENTERED_VEHICLE")) and unit == "player") then
		veb:SetAlpha(1)
	elseif(((event=="UNIT_EXITING_VEHICLE") or (event=="UNIT_EXITED_VEHICLE")) and unit == "player") then
		veb:SetAlpha(0)
	end
end
recUI.lib.registerEvent("UNIT_ENTERING_VEHICLE", "recUIActionBar", OnVehicle)
recUI.lib.registerEvent("UNIT_ENTERED_VEHICLE", "recUIActionBar", OnVehicle)
recUI.lib.registerEvent("UNIT_EXITING_VEHICLE", "recUIActionBar", OnVehicle)
recUI.lib.registerEvent("UNIT_EXITED_VEHICLE", "recUIActionBar", OnVehicle)

---------------------------------------------------
-- MOVE STUFF INTO POSITION
---------------------------------------------------
local b1
local scale = .6824

ActionButton1:ClearAllPoints()
ActionButton1:SetPoint('TOPLEFT', bar1Holder, 'TOPLEFT', 4.5, -4.5)

for i = 1, 12 do
	b1 = _G[format("ActionButton%d", i)]
	b1:SetParent(bar1Holder)
	b1:SetScale(scale)

	if i > 1 and i ~= 7 then
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", _G[format("ActionButton%d", i-1)], "RIGHT", 5, 0)
	elseif i == 7 then
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT", _G[format("ActionButton%d", i-6)],"BOTTOMLEFT",0,-6.5)
	end
end

BonusActionBarFrame:SetParent(bar1Holder)
BonusActionBarFrame:SetWidth(0.01)
BonusActionBarTexture0:Hide()
BonusActionBarTexture1:Hide()

BonusActionButton1:ClearAllPoints()
BonusActionButton1:SetPoint('TOPLEFT', bar1Holder, 'TOPLEFT', 4.5, -4.5)

BonusActionButton7:ClearAllPoints()
BonusActionButton7:SetPoint('TOPLEFT', BonusActionButton1, 'BOTTOMLEFT', 0, -5)

for i = 1, 12 do
	b1 = _G[format("BonusActionButton%d", i)]
	b1:SetScale(scale)

	if i > 1 and i ~= 7 then
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", _G[format("BonusActionButton%d", i-1)], "RIGHT", 5, 0)
	elseif i == 7 then
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT", _G[format("BonusActionButton%d", i-6)], "BOTTOMLEFT",0,-6.5)
	end
end

MultiBarBottomLeft:SetParent(bar2Holder)
MultiBarBottomLeftButton1:ClearAllPoints()
MultiBarBottomLeftButton1:SetPoint('TOPLEFT', bar2Holder, 'TOPLEFT', 4.5, -4.5)

for i = 1, 12 do
	b1 = _G[format("MultiBarBottomLeftButton%d", i)]
	b1:SetScale(scale)

	if i > 1 and i ~= 7 then
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", _G[format("MultiBarBottomLeftButton%d", i-1)], "RIGHT", 5, 0)
	elseif i == 7 then
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT", _G[format("MultiBarBottomLeftButton%d", i-6)], "BOTTOMLEFT", 0, -6.5)
	end
end

MultiBarBottomRight:SetParent(bar3Holder)
MultiBarBottomRightButton1:ClearAllPoints()
MultiBarBottomRightButton1:SetPoint('TOPLEFT', bar3Holder, 'TOPLEFT', 4.5, -4.5)

for i = 1, 12 do
	b1 = _G["MultiBarBottomRightButton"..i]
	b1:SetScale(scale)

	if i > 1 and i ~= 7 then
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", _G["MultiBarBottomRightButton"..i-1], "RIGHT", 5, 0)
	elseif i == 7 then
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT", _G["MultiBarBottomRightButton"..i-6], "BOTTOMLEFT", 0, -6.5)
	end
end

MultiBarRight:SetParent(bar45Holder)
MultiBarRightButton1:ClearAllPoints()
MultiBarRightButton1:SetPoint('TOPLEFT', bar45Holder, 'TOPLEFT', 4.5, -4.5)

for i = 1, 12 do
	b1 = _G["MultiBarRightButton"..i]
	b1:SetScale(scale)

	if i > 1 and i ~= 7 then
		b1:ClearAllPoints()
		b1:SetPoint("LEFT", _G["MultiBarRightButton"..i-1], "RIGHT", 5, 0)
	elseif i == 7 then
		b1:ClearAllPoints()
		b1:SetPoint("TOPLEFT", _G["MultiBarRightButton"..i-6], "BOTTOMLEFT", 0, -6.5)
	end
end

for i=1, 12 do
	_G["MultiBarLeftButton"..i]:SetScale(scale)
end

MultiBarLeft:SetParent(bar45Holder)
MultiBarLeftButton1:ClearAllPoints()
MultiBarLeftButton1:SetPoint("CENTER", UIParent)

ShapeshiftBarFrame:SetParent(shiftBarHolder)
ShapeshiftBarFrame:SetWidth(0.01)
ShapeshiftButton1:ClearAllPoints()
ShapeshiftButton1:SetPoint("BOTTOMLEFT",shiftBarHolder,"BOTTOMLEFT",10,10)
local function MoveShapeshift()
	ShapeshiftButton1:SetPoint("BOTTOMLEFT",shiftBarHolder,"BOTTOMLEFT",10,10)
end
hooksecurefunc("ShapeshiftBar_Update", MoveShapeshift)

PossessBarFrame:SetParent(shiftBarHolder)
PossessButton1:ClearAllPoints()
PossessButton1:SetPoint("BOTTOMLEFT", shiftBarHolder, "BOTTOMLEFT", 10, 10)

for i = 1, 10 do
	_G["PetActionButton"..i]:SetScale(0.63)
end
PetActionBarFrame:SetParent(petBarHolder)
PetActionBarFrame:SetWidth(0.01)
PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint('TOPLEFT', petBarHolder, 'TOPLEFT', 4.5, -4.5)
PetActionButton6:ClearAllPoints()
PetActionButton6:SetPoint('TOPLEFT', PetActionButton1, 'BOTTOMLEFT' ,0, -5)

---------------------------------------------------
-- ACTIONBUTTONS MUST BE HIDDEN
---------------------------------------------------

-- hide actionbuttons when the bonusbar is visible (rogue stealth and such)
local function showhideactionbuttons(alpha)
   local f = "ActionButton"
   for i=1, 12 do
      _G[f..i]:SetAlpha(alpha)
   end
end
BonusActionBarFrame:HookScript("OnShow", function(self) showhideactionbuttons(0) end)
BonusActionBarFrame:HookScript("OnHide", function(self) showhideactionbuttons(1) end)
if BonusActionBarFrame:IsShown() then
   showhideactionbuttons(0)
end

---------------------------------------------------
-- MAKE THE DEFAULT BARS UNVISIBLE
---------------------------------------------------

local FramesToHide = {
	MainMenuBar,
	VehicleMenuBar,

	--MainMenuBarBackpackButton,
	--CharacterBag0Slot,
	--CharacterBag1Slot,
	--CharacterBag2Slot,
	--CharacterBag3Slot,
	KeyRingButton,

	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	SocialsMicroButton,
	PVPMicroButton,
	LFGMicroButton,
	MainMenuMicroButton,
	HelpMicroButton,
}

local function HideDefaultFrames()
	for _, frame in pairs(FramesToHide) do
		frame:SetScale(0.001)
		frame:SetAlpha(0)
	end
end

HideDefaultFrames()

---------------------------------------
-- CONFIG
---------------------------------------

--COLORS
--color you want to appy to the standard texture (red, green, blue in RGB)
--local color = { r = 0.25, g = 0.25, b = 0.25, }
local color = { r = 1, g = 1, b = 1, }
--want class color? just comment in this:
--local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

--color for equipped border texture (red, green, blue in RGB)
local color_equipped = { r = 0.33, g = 0.59, b = 0.33, }

--color when out of range
local range_color = { r = 0.69, g = 0.31, b = 0.31, }

--color when out of power (mana)
local mana_color = { r = 0.31, g = 0.45, b = 0.63, }

--color when button is usable
--local usable_color = { r = 0.84, g = 0.75, b = 0.65, }
local usable_color = { r = 1, g = 1, b = 1, }

--color when button is unusable (example revenge not active, since you have not blocked yet)
local unusable_color = { r = 0.5, g = 0.5, b = 0.5, }

-- !!!IMPORTANT!!! - read this before editing the value blow
-- !!!do not set this below 0.1 ever!!!
-- you have 120 actionbuttons on screen (most of you have at 80) and each of them will get updated on this timer in seconds
-- default is 1, it is needed for the rangecheck
-- if you dont want it just set the timer to 999 and the cpu usage will be near zero
-- if you set the timer to 0 it will update all your 120 buttons on every single frame
-- so if you have 120FPS it will call the function 14.400 times a second!
-- if the timer is 1 it will call the function 120 times a second (depends on actionbuttons in screen)
local update_timer = TOOLTIP_UPDATE_TIME + 0.1

---------------------------------------
-- CONFIG END
---------------------------------------

-- DO NOT TOUCH ANYTHING BELOW!

---------------------------------------
-- FUNCTIONS
---------------------------------------

--initial style func
local function rActionButtonStyler_AB_style(self)
	local action = self.action
	local name = self:GetName()
	local bu  = _G[name]
	local ic  = _G[format("%sIcon", name)]
	local co  = _G[format("%sCount", name)]
	local bo  = _G[format("%sBorder", name)]
	local ho  = _G[format("%sHotKey", name)]
	local cd  = _G[format("%sCooldown", name)]
	local na  = _G[format("%sName", name)]
	local fl  = _G[format("%sFlash", name)]
	local nt  = _G[format("%sNormalTexture", name)]

	bu:SetBackdrop({
		bgFile = recUI.media.buttonBackdrop,
		edgeFile = nil,
		edgeSize = 0,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	bu:SetBackdropColor(1, 1, 1, 1)

	nt:SetHeight(bu:GetHeight())
	nt:SetWidth(bu:GetWidth())
	nt:SetPoint("CENTER")
	nt:SetDrawLayer("OVERLAY")

	ho:SetFont(recUI.media.font, 14, "OUTLINE")
	co:SetFont(recUI.media.font, 14, "OUTLINE")
	na:SetFont(recUI.media.font, 14, "OUTLINE")
	ho:Hide()
	na:Hide()

	fl:SetTexture(recUI.media.buttonFlash)
	fl:SetDrawLayer("OVERLAY")
	bu:SetHighlightTexture(recUI.media.buttonHighlight)
	bu:SetPushedTexture(recUI.media.buttonHighlight)
	bu:SetCheckedTexture(recUI.media.buttonChecked)
	bu:SetNormalTexture(recUI.media.buttonNormal)

	ic:SetTexCoord(0.1,0.9,0.1,0.9)
	ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 3, -3)
	ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -3, 3)
	ic:SetDrawLayer("BORDER")

	if ( IsEquippedAction(action) ) then
		nt:SetVertexColor(0,1,0,1)
	else
		nt:SetVertexColor(1,1,1,1)
	end
end

--style pet buttons
local function rActionButtonStyler_AB_stylepet()
	for i=1, NUM_PET_ACTION_SLOTS do
		local name = "PetActionButton"..i
		local bu  = _G[name]
		local ic  = _G[name.."Icon"]
		local fl  = _G[name.."Flash"]
		local nt  = _G[name.."NormalTexture2"]

		bu:SetBackdrop({
			bgFile = recUI.media.buttonBackdrop,
			edgeFile = nil,
			edgeSize = 0,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		bu:SetBackdropColor(1, 1, 1, 1)
		fl:SetDrawLayer("OVERLAY")
		nt:SetDrawLayer("OVERLAY")
		ic:SetDrawLayer("BORDER")

		nt:SetHeight(bu:GetHeight())
		nt:SetWidth(bu:GetWidth())
		nt:SetPoint("Center", 0, 0)

		nt:SetVertexColor(color.r,color.g,color.b,1)

		fl:SetTexture(recUI.media.buttonFlash)
		bu:SetHighlightTexture(recUI.media.buttonHighlight)
		bu:SetPushedTexture(recUI.media.buttonPushed)
		bu:SetCheckedTexture(recUI.media.buttonChecked)
		bu:SetNormalTexture(recUI.media.buttonNormal)

		ic:SetTexCoord(0.1,0.9,0.1,0.9)
		ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
		ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	end
end

--style shapeshift buttons
local function rActionButtonStyler_AB_styleshapeshift()
	for i=1, NUM_SHAPESHIFT_SLOTS do
		local name = "ShapeshiftButton"..i
		local bu  = _G[name]
		local ic  = _G[name.."Icon"]
		local fl  = _G[name.."Flash"]
		local nt  = _G[name.."NormalTexture"]

		bu:SetBackdrop({
			bgFile = recUI.media.buttonBackdrop,
			edgeFile = nil,
			edgeSize = 0,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		bu:SetBackdropColor(1, 1, 1, 1)
		fl:SetDrawLayer("OVERLAY")
		nt:SetDrawLayer("OVERLAY")
		ic:SetDrawLayer("BORDER")

		nt:ClearAllPoints()
		nt:SetPoint("TOPLEFT", bu, "TOPLEFT", 0, 0)
		nt:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 0, 0)

		nt:SetVertexColor(color.r,color.g,color.b,1)

		fl:SetTexture(recUI.media.buttonFlash)
		bu:SetHighlightTexture(recUI.media.buttonHover)
		bu:SetPushedTexture(recUI.media.buttonPushed)
		bu:SetCheckedTexture(recUI.media.buttonChecked)
		bu:SetNormalTexture(recUI.media.buttonNormal)

		ic:SetTexCoord(0.1,0.9,0.1,0.9)
		ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
		ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	end
end

--fix the grid display
--the default function has a bug and once you move a button the alpha stays at 0.5, this gets fixed here
local function rActionButtonStyler_AB_fixgrid(button)
	local name = button:GetName()
	local action = button.action
	local nt  = _G[name.."NormalTexture"]
	if ( IsEquippedAction(action) ) then
		nt:SetVertexColor(color_equipped.r,color_equipped.g,color_equipped.b,1)
	else
		nt:SetVertexColor(color.r,color.g,color.b,1)
	end
end

--update the button colors onUpdateUsable
local function rActionButtonStyler_AB_usable(self)
	local name = self:GetName()
	local action = self.action
	local nt  = _G[name.."NormalTexture"]
	local icon = _G[name.."Icon"]
	if ( IsEquippedAction(action) ) then
		nt:SetVertexColor(0, 1, 0, 1)
	else
		nt:SetVertexColor(1, 1, 1, 1)
	end
	local isUsable, notEnoughMana = IsUsableAction(action)
	if (ActionHasRange(action) and IsActionInRange(action) == 0) then
		icon:SetVertexColor(.8, .1, .1, 1)
		return
	elseif (notEnoughMana) then
		icon:SetVertexColor(.1, .3, 1, 1)
		return
	elseif (isUsable) then
		icon:SetVertexColor(1, 1, 1, 1)
		return
	else
		icon:SetVertexColor(.5, .5, .5, 1)
		return
	end
end

--rewrite of the onupdate func
--much less cpu usage needed
local function rActionButtonStyler_AB_onupdate(self,elapsed)
	local t = self.rABS_range
	if (not t) then
		self.rABS_range = 0
		return
	end
	t = t + elapsed
	if (t<update_timer) then
		self.rABS_range = t
		return
	else
		self.rABS_range = 0
		rActionButtonStyler_AB_usable(self)
	end
end

--hotkey func
--is only needed when you want to hide the hotkeys and use the default barmod (Dominos does not need this)
local function rActionButtonStyler_AB_hotkey(self, actionButtonType)
	if (not actionButtonType) then
		actionButtonType = "ACTIONBUTTON";
	end
	local hotkey = _G[self:GetName().."HotKey"]
	local key = GetBindingKey(actionButtonType..self:GetID()) or GetBindingKey("CLICK "..self:GetName()..":LeftButton");
	local text = GetBindingText(key, "KEY_", 1);
	hotkey:SetText(text);
	hotkey:Hide()
end


---------------------------------------
-- CALLS // HOOKS
---------------------------------------

hooksecurefunc("ActionButton_Update",   rActionButtonStyler_AB_style)
hooksecurefunc("ActionButton_UpdateUsable",   rActionButtonStyler_AB_usable)

--rewrite default onUpdateFunc, the new one uses much less CPU power
ActionButton_OnUpdate = rActionButtonStyler_AB_onupdate

--fix grid
hooksecurefunc("ActionButton_ShowGrid",      rActionButtonStyler_AB_fixgrid)
hooksecurefunc("ActionButton_UpdateHotkeys", rActionButtonStyler_AB_hotkey)
hooksecurefunc("ShapeshiftBar_OnLoad",       rActionButtonStyler_AB_styleshapeshift)
hooksecurefunc("ShapeshiftBar_Update",       rActionButtonStyler_AB_styleshapeshift)
hooksecurefunc("ShapeshiftBar_UpdateState",  rActionButtonStyler_AB_styleshapeshift)
hooksecurefunc("PetActionBar_Update",        rActionButtonStyler_AB_stylepet)