local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

-- Texture credit: 胡里胡涂
local _G = getfenv(0)
local tinsert, pairs, type = table.insert, pairs, type
local buttonList = {}

function Bar:MicroButton_SetupTexture(icon, texture)
	local r, g, b = DB.r, DB.g, DB.b
	if not C.db["Skins"]["ClassLine"] then r, g, b = 0, 0, 0 end

	icon:SetOutside(nil, 3, 3)
	icon:SetTexture(DB.MicroTex..texture)
	icon:SetVertexColor(r, g, b)
end

local function ResetButtonParent(button, parent)
	if parent ~= button.__owner then
		button:SetParent(button.__owner)
	end
end

local function ResetButtonAnchor(button)
	button:ClearAllPoints()
	button:SetAllPoints()
end

function Bar:MicroButton_Create(parent, data)
	local texture, method, tooltip = unpack(data)

	local bu = CreateFrame("Frame", nil, parent)
	tinsert(buttonList, bu)
	bu:SetSize(22, 22)

	local icon = bu:CreateTexture(nil, "ARTWORK")
	Bar:MicroButton_SetupTexture(icon, texture)

	if type(method) == "string" then
		local button = _G[method]
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetParent(bu)
		button.__owner = bu
		hooksecurefunc(button, "SetParent", ResetButtonParent)
		ResetButtonAnchor(button)
		hooksecurefunc(button, "SetPoint", ResetButtonAnchor)
		button:UnregisterAllEvents()
		button:SetNormalTexture(0)
		button:SetPushedTexture(0)
		button:SetDisabledTexture(0)
		if tooltip then B.AddTooltip(button, "ANCHOR_RIGHT", tooltip) end

		local hl = button:GetHighlightTexture()
		Bar:MicroButton_SetupTexture(hl, texture)
		if not C.db["Skins"]["ClassLine"] then hl:SetVertexColor(1, 1, 1) end

		local flash = button.FlashBorder
		if flash then
			Bar:MicroButton_SetupTexture(flash, texture)
			if not C.db["Skins"]["ClassLine"] then flash:SetVertexColor(1, 1, 1) end
		end
		if button.FlashContent then button.FlashContent:SetTexture(nil) end
	else
		bu:SetScript("OnMouseUp", method)
		B.AddTooltip(bu, "ANCHOR_RIGHT", tooltip)

		local hl = bu:CreateTexture(nil, "HIGHLIGHT")
		hl:SetBlendMode("ADD")
		Bar:MicroButton_SetupTexture(hl, texture)
		if not C.db["Skins"]["ClassLine"] then hl:SetVertexColor(1, 1, 1) end
	end
end

function Bar:MicroMenu_Lines(parent)
	if not C.db["Skins"]["MenuLine"] then return end

	local cr, cg, cb = 0, 0, 0
	if C.db["Skins"]["ClassLine"] then cr, cg, cb = DB.r, DB.g, DB.b end

	local width, height = 200, 20
	local anchors = {
		["LEFT"] = {.5, 0},
		["RIGHT"] = {0, .5}
	}
	for anchor, v in pairs(anchors) do
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetPoint(anchor, parent, "CENTER", 0, 0)
		frame:SetSize(width, height)
		frame:SetFrameStrata("BACKGROUND")

		local tex = B.SetGradient(frame, "H", 0, 0, 0, v[1], v[2], width, height)
		tex:SetPoint("CENTER")
		local bottomLine = B.SetGradient(frame, "H", cr, cg, cb, v[1], v[2], width-25, C.mult)
		bottomLine:SetPoint("TOP"..anchor, frame, "BOTTOM"..anchor, 0, 0)
		local topLine = B.SetGradient(frame, "H", cr, cg, cb, v[1], v[2], width+25, C.mult)
		topLine:SetPoint("BOTTOM"..anchor, frame, "TOP"..anchor, 0, 0)
	end
end

function Bar:MicroMenu()
	if not C.db["Actionbar"]["MicroMenu"] then return end

	local menubar = CreateFrame("Frame", nil, UIParent)
	menubar:SetSize(323, 22)
	B.Mover(menubar, L["Menubar"], "Menubar", C.Skins.MicroMenuPos)
	Bar:MicroMenu_Lines(menubar)

	-- Generate Buttons
	local buttonInfo = {
		{"player", "CharacterMicroButton"},
		{"spellbook", "SpellbookMicroButton"},
		{"talents", "TalentMicroButton"},
		{"achievements", "AchievementMicroButton"},
		{"quests", "QuestLogMicroButton"},
		{"guild", "GuildMicroButton"},
		{"LFG", "LFDMicroButton"},
		{"encounter", "EJMicroButton"},
		{"collections", "CollectionsMicroButton"},
		{"store", "StoreMicroButton"},
		{"help", "MainMenuMicroButton", MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")},
		{"bags", function() ToggleAllBags() end, MicroButtonTooltipText(BAGSLOT, "OPENALLBAGS")},
	}
	for _, info in pairs(buttonInfo) do
		Bar:MicroButton_Create(menubar, info)
	end

	-- Order Positions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i-1], "RIGHT", 5, 0)
		end
	end

	-- Default elements
	if MainMenuMicroButton.MainMenuBarPerformanceBar then
		B.HideObject(MainMenuMicroButton.MainMenuBarPerformanceBar)
	end
	B.HideObject(HelpOpenWebTicketButton)
	MainMenuMicroButton:SetScript("OnUpdate", nil)

	MicroButtonAndBagsBar:Hide()
	MicroButtonAndBagsBar:UnregisterAllEvents()
	if C.db["Map"]["DisableMinimap"] then
		QueueStatusButton:SetParent(Minimap)
		QueueStatusButton:ClearAllPoints()
		QueueStatusButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 30, -10)
		QueueStatusButton:SetFrameLevel(5)
		QueueStatusButton:SetScale(.9)
	end
end