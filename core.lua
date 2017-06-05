PostalAttendance_Core = {}

local Core = PostalAttendance_Core
Core.event_frame = CreateFrame("Frame", "PostalAttendance_CoreEventFrame")
Core.command_list = {}


--
-- Helper functions
--


local print = PostalAttendance_Helpers.Print


--
-- Member functions
--


function Core:PopulateCommandList()
    self.command_list = {
        help = Core.SlashCommandHelp,
        tracker_start = function(...) self.tracker:Start() end,
        tracker_stop = function(...) self.tracker:Stop() end,
        show_ranks = function(...) self.tracker:ShowRanks() end,
    }
end


function Core:Init()
    print("PostalAttendance init()")
    self.roster = PostalAttendance_Roster
    self.tracker = PostalAttendance_Tracker
    self.tracker:Init()
    self.tracker:SetRoster(self.roster)
    self:PopulateCommandList()
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
    print("Postal Attendance Help!")
end


--
-- Event handling
--


function Core:ADDON_LOADED()
    if arg1 ~= "PostalAttendance" then
        return
    end

    self:Init()
    self.event_frame:UnregisterEvent("ADDON_LOADED")
end


SLASH_POSTALATTENDANCE1 = "/pa";

SlashCmdList["POSTALATTENDANCE"] = function(msg)
    Core:SlashCommandHandler(msg) end

Core.event_frame:RegisterEvent("ADDON_LOADED")
Core.event_frame:SetScript("OnEvent", function() Core[event](Core) end)
