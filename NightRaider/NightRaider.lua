local addon = LibStub("AceAddon-3.0"):NewAddon("NightRaider", "AceConsole-3.0")
local menuFrame = CreateFrame("Frame", nil, UIParent, "UIDropDownMenuTemplate")

local addonVersion = "1.1.0"

local DEBUG = true
local MOCK = true

local DEBUGGER_PREFIX = "Debugger:"

local NightRaider = {
    -- Attributes
    autoSort = false,
    player = nil,
    hasPermission = nil,
    raidMembers = {},
    memberRaidIndex = {},
    membersInGroup = {},
    groupOfMembers = {},
    insertedMembersInfo = {},
    groupSize = {},
    lastMembersSize = 0,
    Initialize = function(self)
        self.playerName = UnitName("player")
        self:InitializeGUI()
        self:InitializeRaidChangeWatcher()
    end,
    GUI = CreateFrame("Frame", "MainWindow", UIParent, "BasicFrameTemplateWithInset"),
    raidChangeWatcher = CreateFrame("Frame"),

    -- Functions
    InitializeGUI = function(self)
        self.GUI.title = self.GUI:CreateFontString(nil, "OVERLAY")
        self.GUI.title:SetFontObject("GameFontHighlight")
        self.GUI.title:SetPoint("CENTER", self.GUI.TitleBg, "CENTER")
        self.GUI.title:SetText("NightRaider v" .. addonVersion)
        self.GUI:SetSize(600, 300)
        self.GUI:SetFrameLevel(600)
        self.GUI:SetPoint("CENTER", UIParent, "CENTER")
        self.GUI:SetMovable(true)
        self.GUI:EnableMouse(true)
        self.GUI:RegisterForDrag("LeftButton")
        self.GUI:SetScript("OnDragStart", self.GUI.StartMoving)
        self.GUI:SetScript("OnDragStop", self.GUI.StopMovingOrSizing)
        self.GUI:SetBackdrop({
            edgeSize = 16
        })
        self.GUI:SetBackdropBorderColor(0, .44, .87, 0.5)

        self.GUI.ScrollFrame = CreateFrame("ScrollFrame", nil, self.GUI, "UIPanelScrollFrameTemplate")
        self.GUI.ScrollFrame.TextBox = CreateFrame("EditBox", nil, self.GUI.ScrollFrame)
        self.GUI.ScrollFrame:SetBackdrop({
            edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
            edgeSize = 14,
        })
        self.GUI.ScrollFrame:SetPoint("TOPLEFT", self.GUI, "TOPLEFT", 15, -35)
        self.GUI.ScrollFrame:SetHeight(250)
        self.GUI.ScrollFrame:SetWidth(383)
        self.GUI.ScrollFrame.TextBox:SetPoint("TOPLEFT", self.GUI.ScrollFrame, "TOPLEFT", 150, -20)
        self.GUI.ScrollFrame.TextBox:SetPoint("BOTTOMRIGHT", self.GUI.ScrollFrame, "BOTTOMRIGHT", -15, 15)
        self.GUI.ScrollFrame.TextBox:SetScript("onescapepressed", function()
            self.GUI.ScrollFrame.TextBox:ClearFocus()
        end)
        self.GUI.ScrollFrame.TextBox:SetFont("Fonts\\FRIZQT__.TTF", 14)
        self.GUI.ScrollFrame.TextBox:SetMultiLine(true)
        self.GUI.ScrollFrame.TextBox:SetTextInsets(10, 30 ,10 ,10)
        self.GUI.ScrollFrame.TextBox:SetHeight(250)
        self.GUI.ScrollFrame.TextBox:SetWidth(383)
        self.GUI.ScrollFrame.TextBox:SetText("")
        self.GUI.ScrollFrame.TextBox:SetAutoFocus(false)
        self.GUI.ScrollFrame:SetScrollChild(self.GUI.ScrollFrame.TextBox)

        self.GUI.ScrollFrame.TextBox.Focus = CreateFrame("Button", nil, self.GUI, "GameMenuButtonTemplate")
        self.GUI.ScrollFrame.TextBox.Focus:SetPoint("TOPLEFT", self.GUI.ScrollFrame, "TOPLEFT", 0, 0)
        self.GUI.ScrollFrame.TextBox.Focus:SetHeight(250)
        self.GUI.ScrollFrame.TextBox.Focus:SetWidth(383)
        self.GUI.ScrollFrame.TextBox.Focus:SetAlpha(0)
        self.GUI.ScrollFrame.TextBox.Focus:SetScript("OnClick", function()
            self.GUI.ScrollFrame.TextBox:SetFocus()
        end)

        self.GUI.InviteToGroupsBtn = CreateFrame("Button", nil, self.GUI, "GameMenuButtonTemplate")
        self.GUI.InviteToGroupsBtn:SetPoint("TOPLEFT", self.GUI.ScrollFrame, "TOPRIGHT", 30, 0)
        self.GUI.InviteToGroupsBtn:SetSize(155, 30)
        self.GUI.InviteToGroupsBtn:SetText("Invite members")
        self.GUI.InviteToGroupsBtn:SetNormalFontObject("GameFontNormal")
        self.GUI.InviteToGroupsBtn:SetHighlightFontObject("GameFontHighlight")

        self.GUI.SortMembersButton = CreateFrame("Button", nil, self.GUI, "GameMenuButtonTemplate")
        self.GUI.SortMembersButton:SetPoint("TOPLEFT", self.GUI.InviteToGroupsBtn, "BOTTOMLEFT", 0, -5)
        self.GUI.SortMembersButton:SetSize(155, 30)
        self.GUI.SortMembersButton:SetText("Sort to groups")
        self.GUI.SortMembersButton:SetNormalFontObject("GameFontNormal")
        self.GUI.SortMembersButton:SetHighlightFontObject("GameFontHighlight")
        self.GUI.SortMembersButton:SetScript("OnClick", function()
            self:SortLoadedMembers()
        end)

        self.GUI.IncludeNotGroupedCheck = CreateFrame("CheckButton", "includeNotGrouped", self.GUI, "ChatConfigCheckButtonTemplate")
        self.GUI.IncludeNotGroupedCheck:SetPoint("TOPLEFT", self.GUI.SortMembersButton, "BOTTOMLEFT", 0, -5)
        self.GUI.IncludeNotGroupedCheck.tooltip = "Include people without specified group"
        includeNotGroupedText:SetText(" Include not grouped")
        self.GUI.InviteToGroupsBtn:SetScript("OnClick", function()
            self:InviteAndSortLoadedMembers()
        end)

        self.GUI.AutoSortCheck = CreateFrame("CheckButton", "autoSort", self.GUI, "ChatConfigCheckButtonTemplate")
        self.GUI.AutoSortCheck:SetPoint("TOPLEFT", self.GUI.IncludeNotGroupedCheck, "BOTTOMLEFT", 0, -5)
        self.GUI.AutoSortCheck.tooltip = "Automatic sorting to groups when new members join to party/raid."
        self.GUI.AutoSortCheck:SetChecked(true)
        autoSortText:SetText(" Sort new members")

        -- Set Targets
        self.GUI.SetTargetsButton = CreateFrame("Button", nil, self.GUI, "GameMenuButtonTemplate")
        self.GUI.SetTargetsButton:SetPoint("BOTTOMLEFT", self.GUI.ScrollFrame, "BOTTOMRIGHT", 30, -2)
        self.GUI.SetTargetsButton:SetSize(155, 30)
        self.GUI.SetTargetsButton:SetText("Set targets")
        self.GUI.SetTargetsButton:SetNormalFontObject("GameFontNormal")
        self.GUI.SetTargetsButton:SetHighlightFontObject("GameFontHighlight")
        self.GUI.SetTargetsButton:SetScript("OnClick", function()
            self:ShowSetTargetsMenu();
        end)

        -- Do not show Window after login.
        self.GUI:Hide()
        self:UpdateRaidInfo()
    end,

    ShowSetTargetsMenu = function(_, button)
        local sources = {
            { name = "Classes" },
            { name = "Groups" },
            { name = "Roles" },
        }

        local targets = {
            classes = {
                options = {
                    Warriors = WARRIOR,
                    Paladins = PALADIN,
                    Hunters = HUNTER,
                    Rogues = ROGUE,
                    Priests = PRIEST,
                    Shamans = SHAMAN,
                    Mages = MAGE,
                    Warlocks = WARLOCK,
                    Druids = DRUID
                },
                onSelect = function() end
            },
            symbols = {
                onSelect = function()
                    local symbols = {
                        Skull = "{rt8}",
                        Cross = "{rt7}",
                        Square = "{rt6}",
                        Moon = "{rt5}",
                        Triangle = "{rt4}",
                        Diamond = "{rt3}",
                        Circle = "{rt2}",
                        Star = "{rt1}"
                    }
                end
            }
        }

        local menu = {
            { text = "Source", isTitle = true, notCheckable = 1},
            { text = "Classes", func = function() NightRaider:InviteAndSortLoadedMembers() end, notCheckable = 1, hasArrow = true,
                menuList = {
                    { text = "Mages", func = function() print("You've chosen option 3"); end, colorCode	= "|c" .. ({ GetClassColor("MAGE") })[4], hasArrow = true, notCheckable = 1,
                        menuList = {
                            { text = "Target", isTitle = true, notCheckable = 1},
                            { text = "Groups", func = function() print("You've chosen option 3"); end, notCheckable = 1 },
                            { text = "Symbols", func = function() print("You've chosen option 3"); end, notCheckable = 1 }
                        }
                    }
                }
            },
            { text = "Groups", func = function() NightRaider:InviteAndSortLoadedMembers() end, notCheckable = 1, hasArrow = true,
                menuList = {
                    { text = "Mages", func = function() print("You've chosen option 3"); end, colorCode	= "|cff0000ff", hasArrow = true}
                }
            },
            { text = "Roles", func = function() NightRaider:InviteAndSortLoadedMembers() end, notCheckable = 1, hasArrow = true,
                menuList = {
                    { text = "Mages", func = function() print("You've chosen option 3"); end, colorCode	= "|cff0000ff", hasArrow = true}
                }
            }
        }

        EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU")
    end,

    InviteLoadedMembers = function(self)
        self.insertedMembersInfo = self:LoadInsertedValidMembersInfo()
        self:UpdateRaidInfo()

        local invite = {};

    end,

    SortLoadedMembers = function(self)
        self.insertedMembersInfo = self:LoadInsertedValidMembersInfo()
        self:UpdateRaidInfo()

        -- Sort members to groups
        for member, group in pairs(self.insertedMembersInfo) do
            -- If member is not part of this raid yet
            if self.memberRaidIndex[member] then
                self:SwitchMemberToTargetGroup(member, group)
            end
        end
    end,

    InviteAndSortLoadedMembers = function(self)
        self.insertedMembersInfo = self:LoadInsertedValidMembersInfo()
        self:UpdateRaidInfo()

        local invite = {};

        -- Sort members to groups
        for member, group in pairs(self.insertedMembersInfo) do
            -- If member is not part of this raid yet
            if not self.memberRaidIndex[member] then
                if group ~= 0 or self.GUI.IncludeNotGroupedCheck:GetChecked() then
                    table.insert(invite, member)
                end
            end
        end

        -- Invite members
        for _, member in ipairs(invite) do
            if DEBUG or MOCK then
                print(DEBUGGER_PREFIX, "Inviting " .. member)
            end
            if not MOCK then
                InviteUnit(member)
            end
        end
    end,

    InitializeRaidChangeWatcher = function(self)
        self.raidChangeWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
        self.raidChangeWatcher:SetScript("OnEvent", function()
            if self.lastMembersSize == GetNumGroupMembers() then
                return -- Do nothing
            end
            self.lastMembersSize = GetNumGroupMembers() -- Update members counter

            if DEBUG then
                print(DEBUGGER_PREFIX, "Watcher triggered")
            end
            if self.GUI.AutoSortCheck:GetChecked() then
                if DEBUG then
                    print(DEBUGGER_PREFIX, "Watcher executed")
                end

                -- Set of previous members
                local previousMembers = {}
                for member in pairs(self.memberRaidIndex) do
                    previousMembers[member] = true
                end

                if DEBUG then
                    print("Previous: ")
                    for member in pairs(previousMembers) do
                        print(member)
                    end
                end

                self:UpdateRaidInfo()

                -- Set of current members
                local currentMembers = {}
                for member in pairs(self.memberRaidIndex) do
                    currentMembers[member] = true
                end

                if DEBUG then
                    print("Current: ")
                    for member in pairs(previousMembers)
                    do
                        print(member)
                    end
                end

                -- Check member changes differences
                local membersJoined = {}
                -- local membersLeft = {}

                for member in pairs(currentMembers) do
                    if not previousMembers[member] then
                        membersJoined[member] = true
                        if DEBUG then
                            print("Member joined ", member)
                        end
                    end
                end

                -- Member left raid
                -- for member in pairs(previousMembers) do
                --    if not currentMembers[member] then
                --        membersLeft[member] = true
                --    end
                -- end

                -- Members joined raid
                for member in pairs(membersJoined) do
                    if DEBUG then
                        print(DEBUGGER_PREFIX, "New member joined", member)
                    end
                    if self.insertedMembersInfo[member] then
                        ConvertToRaid()
                        self:SwitchMemberToTargetGroup(member, self.insertedMembersInfo[member])
                    else
                        if DEBUG then
                            print(DEBUGGER_PREFIX, "Group for new member " .. member .. " was not recognized.")
                        end
                    end
                end
            else
                if DEBUG then
                    print(DEBUGGER_PREFIX, "Watcher is not allowed...")
                end
            end
        end)
    end,

    UpdateRaidInfo = function(self)
        -- Initialization
        self.hasPermission = false
        self.raidMembers = {}
        self.memberRaidIndex = {}
        self.groupSize = {}
        self.membersInGroup = {}
        self.groupOfMembers = {}
        for i = 1, 8 do
            self.groupSize[i] = 0
            self.membersInGroup[i] = {}
        end

        -- Iterate over all Raid members
        for i = 1, GetNumGroupMembers() do
            local memberNameUnformatted, raidRank, groupId = GetRaidRosterInfo(i)
            if memberNameUnformatted then
                local memberName = memberNameUnformatted:lower()

                table.insert(self.raidMembers, memberName)
                table.insert(self.membersInGroup[groupId], memberName)
                self.groupSize[groupId] = self.groupSize[groupId] + 1
                self.groupOfMembers[memberName] = groupId
                self.memberRaidIndex[memberName] = i

                -- Get current player raid permissions
                if self.playerName == memberName then
                    self.hasPermission = raidRank > 0
                end
            end
        end

        -- If player is not in group then set the permission
        if GetNumGroupMembers() == 0 then
            self.hasPermission = true
        end
    end,

    SwitchMemberToTargetGroup = function(self, sourceMemberName, targetGroupId)
        -- Check if member is already in target subGroup
        if self.groupOfMembers[sourceMemberName] == targetGroupId then
            if DEBUG then
                print(DEBUGGER_PREFIX, sourceMemberName .. " already in target group " .. targetGroupId)
            end
            return -- Do nothing
        end

        if targetGroupId == 0 then
            if DEBUG then
                print(DEBUGGER_PREFIX, sourceMemberName .. " not moving because no group has been specified.")
            end
            return -- Do nothing
        end

        if self.groupSize[targetGroupId] == 5 then
            -- Find first members that is in wrong group
            for _, targetMemberName in ipairs(self.membersInGroup[targetGroupId]) do
                if self.insertedMembersInfo[targetMemberName] ~= targetGroupId then
                    if DEBUG or MOCK then
                        print(DEBUGGER_PREFIX, "Swaping " .. sourceMemberName .. " with " .. targetMemberName .. " to group " .. targetGroupId)
                    end
                    if not MOCK then
                        -- Switch position of source and target member
                        SwapRaidSubgroup(self.memberRaidIndex[sourceMemberName], self.memberRaidIndex[targetMemberName])
                        self.groupOfMembers[targetMemberName] = self.groupOfMembers[sourceMemberName]
                        self.groupOfMembers[sourceMemberName] = targetGroupId
                        break
                    end
                end
            end
        else
            -- If the target group is not full yet
            if DEBUG or MOCK then
                print(DEBUGGER_PREFIX, "Moving " .. sourceMemberName .. " to group " .. targetGroupId)
            end
            if not MOCK then
                SetRaidSubgroup(self.memberRaidIndex[sourceMemberName], targetGroupId)
                self.groupSize[self.groupOfMembers[sourceMemberName]] = self.groupSize[self.groupOfMembers[sourceMemberName]] - 1
                self.groupSize[targetGroupId] = self.groupSize[targetGroupId] + 1
                self.groupOfMembers[sourceMemberName] = targetGroupId
            end
        end
    end,

    LoadInsertedValidMembersInfo = function(self)
        local result = {}

        if DEBUG then
            print(DEBUGGER_PREFIX, "Loaded " .. self.GUI.ScrollFrame.TextBox:GetText())
        end

        for memberName, group in self.GUI.ScrollFrame.TextBox:GetText():gmatch("[{};,:\" \r\n]*([^=};:\", \r\n]+)[;=, \":\r\n]*(%d*)") do
            group = tonumber(group) or 0

            -- Set all undefined groups to 0
            if group < 0 or group > 8 then
                group = 0
            end

            if group ~= 0 or self.GUI.IncludeNotGroupedCheck:GetChecked() then
                if DEBUG then
                    print(DEBUGGER_PREFIX, "Loaded member " .. memberName .. " in group " .. group)
                end
                result[memberName:lower()] = group
            end
        end

        return result
    end
}

local nightRaiderLDB = LibStub("LibDataBroker-1.1"):NewDataObject("NightRaider", {
    type = "data source",
    text = "NightRaider",
    icon = "Interface\\Icons\\Inv_misc_head_dragon_01",
    OnClick = function(_, button)
        if button == "LeftButton" then
            NightRaider.GUI:SetShown(not NightRaider.GUI:IsShown())
        end

        if button == "RightButton" then
            local menu = {
                { text = "Actions", isTitle = true, notCheckable = 1},
                { text = "Invite/sort members", func = function() NightRaider:InviteAndSortLoadedMembers() end, notCheckable = 1 }
            }

            EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU")
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("NightRaider ".. addonVersion)
        tooltip:AddLine("|cffffff00Left-click|r opens window.")
        tooltip:AddLine("|cffffff00Right-click|r shows actions.")
    end,
})

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("NightRaiderDB", {
        profile = {
            minimap = {
                hide = false,
            }
        },
    })
    local icon = LibStub("LibDBIcon-1.0")

    icon:Register("NightRaider", nightRaiderLDB, self.db.profile.minimap)
    self:RegisterChatCommand("nr", "CommandTheNightRaider")

    NightRaider:Initialize()
end

function addon:CommandTheNightRaider()
    NightRaider.GUI:SetShown(not NightRaider.GUI:IsShown())
end