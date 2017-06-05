PostalAttendance_Core = {}

local Core = PostalAttendance_Core
Core.event_frame = CreateFrame("Frame", "PostalAttendance_CoreEventFrame")
Core.print = PostalAttendance_Helpers.Print
Core.command_list = {
    help = Core.SlashCommandHelp,
    hello = function(...) Core:print("Hello") end,
}


function Core:Init()
    self:print("PostalAttendance init()")
    self.roster = PostalAttendance_Roster
    self.tracker = PostalAttendance_Tracker
    self.tracker:Init()
    self.tracker:SetRoster(self.roster)
end


--
-- Slash command handling
--

function Core:SlashCommandHandler(msg)
    local _, _, cmd, args = string.find(msg, "^(%S+) *(.*)");

    cmd = tostring(cmd)

    if self.command_list[cmd] then
        self.command_list[cmd](args)
    else
        self:SlashCommandHelp()
    end
end


function Core:SlashCommandHelp()
    self:print("Postal Attendance Help!")
end


--
-- Event handling
--

function Core:ADDON_LOADED()
    self:Init()
    self.event_frame:UnregisterEvent("ADDON_LOADED")
end


function Core:OnEvent()
    if event == "ADDON_LOADED" then
        self:ADDON_LOADED()
    end
end


SLASH_POSTALATTENDANCE1 = "/pa";

SlashCmdList["POSTALATTENDANCE"] = function(msg)
    Core:SlashCommandHandler(msg) end

Core.event_frame:RegisterEvent("ADDON_LOADED")
Core.event_frame:SetScript("OnEvent", function() Core:OnEvent() end)
