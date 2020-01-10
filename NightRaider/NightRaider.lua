local addon = LibStub("AceAddon-3.0"):NewAddon("NightRaider", "AceConsole-3.0")

local UIConfig = CreateFrame("Frame", "MainWindow", UIParent, "BasicFrameTemplateWithInset");

local nightRaiderLDB = LibStub("LibDataBroker-1.1"):NewDataObject("NightRaider", {
    type = "data source",
    text = "NightRaider",
    icon = "Interface\\Icons\\Inv_misc_head_dragon_01",
    OnClick = function(_, button)
        if button == "LeftButton" then
            UIConfig:SetShown(not UIConfig:IsShown())
        end

        if button == "RightButton" then
            print("RightButton");
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("NightRaider")
        tt:AddLine("|cffffff00Click|r to open the NightRaider.")
    end,
})
local icon = LibStub("LibDBIcon-1.0")
 
function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("NightRaiderDB", {
        profile = {
            minimap = {
                hide = false,
            },
            mainWindow = {
                hide = true
            }
        },
    })
    icon:Register("NightRaider!", nightRaiderLDB, self.db.profile.minimap)
    self:RegisterChatCommand("NightRaider", "CommandTheNightRaider")
end
 
function addon:CommandTheNightRaider()
    self.db.profile.minimap.hide = not self.db.profile.minimap.hide
    if self.db.profile.minimap.hide then
        icon:Hide("NightRaider!")
    else
        icon:Show("NightRaider!")
    end
end


UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY")
UIConfig.title:SetFontObject("GameFontHighlight");
UIConfig.title:SetPoint("CENTER", UIConfig.TitleBg, "CENTER");
UIConfig.title:SetText("NightRaider - Options");

UIConfig:SetSize(600, 460);
UIConfig:SetPoint("CENTER", UIParent, "CENTER");
UIConfig:SetMovable(true)
UIConfig:EnableMouse(true)
UIConfig:RegisterForDrag("LeftButton")
UIConfig:SetScript("OnDragStart", UIConfig.StartMoving)
UIConfig:SetScript("OnDragStop", UIConfig.StopMovingOrSizing)
UIConfig:SetBackdrop({
    edgeSize = 16,
    insets = { left = 8, right = 6, top = 8, bottom = 8 },
})
UIConfig:SetBackdropBorderColor(0, .44, .87, 0.5) --
--[[
UIConfig.rankListFrame = CreateFrame("ScrollFrame", "MyMultiLineEditBox",
    UIConfig, "InputBoxScriptTemplate")
UIConfig.rankListFrame:SetWidth(570)
UIConfig.rankListFrame:SetHeight(400)
UIConfig.rankListFrame:SetPoint("CENTER");]]--
--UIConfig.rankListFrame.EditBox:SetFontObject("ChatFontNormal")
--UIConfig.rankListFrame.EditBox:SetAllPoints(true)
--UIConfig.rankListFrame.EditBox:SetMultiLine(true)

--UIConfig.rankListFrame.EditBox:SetMaxLetters(101024)
--UIConfig.rankListFrame:SetScript("OnEscapePressed", UIConfig.rankListFrame.ClearFocus)
--UIConfig.rankListFrame.EditBox:SetScript("OnVerticalScroll", function(_) print("lol") end);

local a = CreateFrame("ScrollFrame", "a", UIConfig, "UIPanelScrollFrameTemplate")
a:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
    edgeSize = 14,
    insets = {left = 3, right = 3, top = 3, bottom = 3},
})
a:SetPoint("TOPLEFT", UIConfig, "TOPLEFT", 15, -35)
a:SetHeight(380)
a:SetWidth(550)

b = CreateFrame("EditBox", "b", a)
b:SetScript("onescapepressed", function(self) b:ClearFocus() end)
b:SetFont("Fonts\\FRIZQT__.TTF", 14)
b:SetMultiLine(true)
b:SetAutoFocus(true)
b:SetHeight(545)
b:SetWidth(545)
b:Show()
a:SetScrollChild(b)
a:Show()
--UIConfig:Hide();