PostalAttendance_Roster = {}

local Roster = PostalAttendance_Roster
Roster.event_frame = CreateFrame("Frame", "PostalAttendance_RosterEventFrame")
Roster.roster = {}
Roster.on_update_cb = function() end

--
-- Helper functions
--


local print = PostalAttendance_Helpers.Print


--
-- Member functions
--


function Roster:Update()
    print("PostalAttendance.Roster Update()")
    self.event_frame:RegisterEvent("GUILD_ROSTER_UPDATE")
    GuildRoster()
end


function Roster:Clear()
    self.roster = {}
end


function Roster:Disable()
    self.event_frame:UnregisterEvent("GUILD_ROSTER_UPDATE")
end


function Roster:FindUser(name)
    for i=1, table.getn(self.roster) do
        if self.roster[i].name == name then
            return self.roster[i].user
        end
    end
    return nil
end


function Roster:GetRoster()
    return self.roster
end



function Roster:SetOnUpdate(cb)
    self.on_update_cb = cb
end


--
-- Event handling
--


function Roster:GUILD_ROSTER_UPDATE()
    print("PostalAttendance.Roster GuildRosterUpdate()")
    self:Disable()
    local total_guild_members = GetNumGuildMembers()
    local roster = {}

    for i=1,total_guild_members do
        local name, rank, rankIndex, level, class, zone, note,
              officernote, online, status, classFileName,
              achievementPoints, achievementRank,
              isMobile = GetGuildRosterInfo(i)

        local user = {
            name = name,
            rank = rank,
            rank_index = rankIndex,
            online = online,
            is_mobile = isMobile,
            note = note
        }

        table.insert(roster, user)
    end

    self.roster = roster
    self.on_update_cb()
end

Roster.event_frame:SetScript(
    "OnEvent",
    function() Roster[event](Roster) end)
