local addon = LibStub("AceAddon-3.0"):NewAddon("NightRaider", "AceConsole-3.0")
local nightRaiderLDB = LibStub("LibDataBroker-1.1"):NewDataObject("NightRaider", {
    type = "data source",
    text = "NightRaider!",
    icon = "Interface\\Icons\\Inv_misc_head_dragon_01",
    OnClick = function()
        UIConfig:Show()
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

local UIConfig = CreateFrame("Frame", "MainWindow", UIParent, "BasicFrameTemplateWithInset");
        
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

local eb = CreateFrame("EditBox", "myInput", UIConfig)
eb:SetSize(UIConfig:GetSize())
eb:SetMultiLine(true)
eb:SetAutoFocus(false)
eb:SetFontObject("ChatFontNormal")
eb:SetScript("OnEscapePressed", function() f:Hide() end)