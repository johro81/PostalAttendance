PostalAttendance_Roster = {}

local Roster = PostalAttendance_Roster
Roster.event_frame = CreateFrame("Frame", "PostalAttendance_RosterEventFrame")
Roster.roster = {}
Roster.on_update_cb = function() end


function Roster:Update()
    self.event_frame:RegisterEvent("GUILD_ROSTER_UPDATE")
    GuildRoster()
end


function Roster:Clear()
    self.roster = {}
end


function Roster:Disable()
    self.event_frame:UnregisterEvent("GUILD_ROSTER_UPDATE")
end


function Roster:GetRoster()
    return self.roster
end


function Roster:GuildRosterUpdate()
    self:Disable()
    local total_guild_members = GetNumGuildMembers()
    local roster = {}

    for i=1,total_guild_members,1
    do
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



function Roster:SetOnUpdateCallBack(cb)
    self.on_update_cb = cb
end


function Roster:OnEvent(event, arg1)
    if event == "GUILD_ROSTER_UPDATE" then
        Roster:GuildRosterUpdate(arg1)
    end
end

Roster.event_frame:RegisterEvent("GUILD_ROSTER_UPDATE")
Roster.event_frame:SetScript("OnEvent", Roster.OnEvent)
