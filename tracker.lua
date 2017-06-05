PostalAttendance_Tracker = {}

local Tracker = PostalAttendance_Tracker
Tracker.roster = {}
Tracker.default = {
    raider_ranks = { 1, 2, 3, 4, 5, 6 },
    alt_ranks = { 7, 8 }
}
Tracker.state = {
    roster_update = 0,
    cur_snapshot = 0,
    new_snapshot = 0,
    is_taking_snapshot = false,
    is_running = false,
    last_update = GetTime(),
}
Tracker.print = PostalAttendance_Helpers.Print


function Tracker:ClearAllData()
    PostalAttendanceDB = {}
    self.db = PostalAttendanceDB
end


function Tracker:Init()
    if not PostalAttendanceDB then
        PostalAttendanceDB = {}
    end
    self.db = PostalAttendanceDB

    self.db.raider_ranks = self.db.raider_ranks or self.default.raider_ranks
    self.db.alt_ranks = self.db.alt_ranks or self.default.alt_ranks
    self.db.attendance = self.db.attendance or {}

    if self.db.state then
        Tracker.state = self.db.state
    end
end


function Tracker:ShowRanks()
    self:print("Main raider ranks:")
    for k, v in ipairs(self.db.raider_ranks) do
        self:print(" - [" .. v .. "]: " .. GuildControlGetRankName(v))
    end

    self:print("Main raider alt ranks:")
    for _, v in ipairs(self.db.alt_ranks) do
        self:print(" - [" .. v .. "]: " .. GuildControlGetRankName(v))
    end
end


function Tracker:SetRoster(roster)
    self.roster = roster
    self.roster:SetOnUpdate(function() self:OnRosterUpdate() end)
end


function Tracker:Start(desc)
    self:print("Tracker:Start()")
    local attendance = {
        desc = desc,
        timestamp = nil,
        snapshots = {}
    }

    table.insert(self.db.attendance, attendance)
    self.state.is_running = true
    self.state.last_update = GetTime()
    self:StartTakingSnapshot()
end


function Tracker:StartTakingSnapshot()
    self:print("Tracker:StartTakingSnapshot()")
    self.state.roster_update = 0
    self.state.cur_snapshot = 0

    local snapshot = {
        timestamp = nil,
        users = {}
    }

    local i = getn(Tracker.db.attendance)
    local snapshots = Tracker.db.attendance[i].snapshots
    table.insert(snapshots, snapshot)

    self.state.is_taking_snapshot = true
    self.roster:Update()
end


function Tracker:Stop()
    self:print("Tracker:Stop()")
    self:StopTakingSnapshot()
    self.state.is_running = false
end

function Tracker:StopTakingSnapshot()
    self:print("Tracker:StopTakingSnapshot()")
    self.state.is_taking_snapshot = false
end


function Tracker:OnRosterUpdate()
    self:print("Tracker:OnRosterUpdate()")
    local self = Tracker
    local roster = self.roster:GetRoster()

    local attendance = self.db.attendance[getn(self.db.attendance)]
    local snapshot = attendance.snapshots[getn(attendance.snapshots)]

    for i=1, getn(roster) do
        local user = roster[i]
        if user.online then
            -- Check if user is an alt that can be mapped to a main raider
            if self.db.alt_ranks[user.rank_index] then
                main = self.roster:FindUser(user.note)
                if main == nil then
                    -- self:print("No raider found for alt " .. user.name ..
                    --       ", please check note: [" .. user.note .. "].")
                else
                    user = main
                end
            end

            -- Add main raider to attendance
            if self.db.raider_ranks[user.rank_index] then
                if not snapshot.users[user.name] then
                    table.insert(snapshot.users, user.name)
                end
            end
        end -- if user.online then
    end -- for i=1, getn(roster) do

    self:print("Users gotten attendance: " .. getn(snapshot.users))
end


--
-- Event handling
--


function Tracker:ON_UPDATE()
    if not Tracker.state.is_running then
        return
    end

    local elapsed = GetTime() - self.state.last_update

    if elapsed < 1 then
        return
    end

    self.state.roster_update = self.state.roster_update + elapsed
    self.state.new_snapshot = self.state.new_snapshot + elapsed
    self.state.cur_snapshot = self.state.cur_snapshot + elapsed

    if self.state.is_taking_snapshot then
        if self.state.cur_snapshot >= 300 then
            self:StopTakingSnapshot()
            self.state.cur_snapshot = 0
        elseif self.state.roster_update >= 60 then
            self.roster:Update()
            self.state.roster_update = 0
        end
    elseif self.state.new_snapshot >= 900 then
        self:StartTakingSnapshot()
        self.state.new_snapshot = 0
    end

    self.state.last_update = GetTime()
end

Tracker.timer_frame = CreateFrame("Frame")
Tracker.timer_frame:SetScript(
    "OnUpdate",
    function() Tracker:ON_UPDATE() end)
