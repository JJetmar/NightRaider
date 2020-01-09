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

local function ScrollFrame_OnMouseWheel(self, delta)
    local newValue = self:GetVerticalScroll() - (delta * 20);

    if (newValue < 0) then
        newValue = 0;
    elseif (newValue > self:GetVerticalScrollRange()) then
        newValue = self:GetVerticalScrollRange();
    end

    self:SetVerticalScroll(newValue);
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

UIConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UIConfig, "UIPanelScrollFrameTemplate");
UIConfig.ScrollFrame:SetPoint("TOPLEFT", 16, 32 , "TOPLEFT", 8, -8);
UIConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", 0,0, "BOTTOMRIGHT", -3, 60);
UIConfig.ScrollFrame:SetClipsChildren(true);
UIConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

UIConfig.child = CreateFrame("Frame", nil, UIConfig.ScrollFrame);
UIConfig.child:SetSize(475, 450);
UIConfig.ScrollFrame:SetScrollChild(UIConfig.child);

UIConfig.child = CreateFrame("Frame", nil, UIConfig.ScrollFrame);
UIConfig.child:SetSize(475, 450);
UIConfig.ScrollFrame:SetScrollChild(UIConfig.child);



UIConfig.ScrollFrame.ScrollBar:ClearAllPoints();
UIConfig.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UIConfig.ScrollFrame, "TOPRIGHT", -20, -22);
UIConfig.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UIConfig.ScrollFrame, "BOTTOMRIGHT", -15, 22);


UIConfig.editFrame = CreateFrame("EditBox", "TchinEditBox", UIConfig, "InputBoxTemplate");
UIConfig.editFrame:SetSize(UIConfig:GetSize())

UIConfig.editFrame:SetPoint("TOPLEFT", UIConfig.child, 50, -50);

UIConfig.editFrame:SetMovable(false);
UIConfig.editFrame:SetAutoFocus(false);
UIConfig.editFrame:SetMultiLine(1000);
UIConfig.editFrame:SetMaxLetters(32000);

UIConfig.editFrame:Show();
UIConfig.ScrollFrame:SetScrollChild(UIConfig.editFrame)
UIConfig:Hide();