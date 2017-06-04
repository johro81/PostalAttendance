PostalAttendance_Core = {}

local Core = PostalAttendance_Core
Core.event_frame = CreateFrame("Frame", "PostalAttendance_CoreEventFrame")
Core.print = PostalAttendance_Helpers.Print


function Core:Init()
    self:print("PostalAttendance init()")
    self.roster = PostalAttendance_Roster
    self.tracker = PostalAttendance_Tracker
    self.tracker:Init()
    self.tracker:SetRoster(self.roster)
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


Core.event_frame:RegisterEvent("ADDON_LOADED")
Core.event_frame:SetScript("OnEvent", function() Core:OnEvent(Core) end)
