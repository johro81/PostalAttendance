PostalAttendance_Core = {}

local Core = PostalAttendance_Core
Core.event_frame = CreateFrame("Frame", "PostalAttendance_CoreEventFrame")


function Core:Init()
    self.roster = PostalAttendance_Roster
    self.tracker = PostalAttendance_Tracker
    self.tracker:Init()
    self.tracker:SetRoster(self.roster)
end


--
-- Event handling
--

function Core:ADDON_LOADED(name)
    if name ~= "PostalAttendance" then
        return
    end

    Core:Init()
end


function Core:OnEvent(event, arg1)
    if event == "ADDON_LOADED" then
        Core:ADDON_LOADED(arg1)
    end
end

Core.event_frame:RegisterEvent("ADDON_LOADED")
Core.event_frame:SetScript("OnEvent", Core.OnEvent)
