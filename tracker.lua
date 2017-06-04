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

    self:print("Main raider ranks:")
    for _k, v in ipairs(self.db.raider_ranks) do
        self:print(" - [" .. v .. "]: " .. GuildControlGetRankName(v))
    end

    self:print("Main raider alt ranks:")
    for _, v in ipairs(self.db.alt_ranks) do
        self:print(" - [" .. v .. "]: " .. GuildControlGetRankName(v))
    end
end


function Tracker:SetRoster(roster)
    self.roster = roster
    self.roster:SetOnUpdate(self.OnRosterUpdate)
end


function Tracker:Start(desc)
    self:print("Tracker:Start()")
    local attendance = {
        desc = desc,
        timestamp = GetServerTime(),
        snapshots = {}
    }

    table.insert(self.db.attendance, attendance)
    self.state.is_running = true
    self:StartTakingSnapshot()
end


function Tracker:StartTakingSnapshot()
    self:print("Tracker:StartTakingSnapshot()")
    self.state.roster_update = 0
    self.state.cur_snapshot = 0

    local snapshot = {
        timestamp = GetServerTime(),
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
            if tContains(self.db.alt_ranks, user.rank_index) then
                main = self.roster:FindUser(user.note)
                if main == nil then
                    -- self:print("No raider found for alt " .. user.name ..
                    --       ", please check note: [" .. user.note .. "].")
                else
                    user = main
                end
            end

            -- Add main raider to attendance
            if tContains(self.db.raider_ranks, user.rank_index) then
                if not tContains(snapshot.users, user.name) then
                    table.insert(snapshot.users, user.name)
                end
            end
        end -- if user.online then
    end -- for i=1, getn(roster) do

    self:print("Users gotten attendance: " .. getn(snapshot.users))
end


function Tracker:TimerOnUpdate(elapsed)
    if not Tracker.state.is_running then
        return
    end

    Tracker.state.roster_update = Tracker.state.roster_update + elapsed
    Tracker.state.new_snapshot = Tracker.state.new_snapshot + elapsed
    Tracker.state.cur_snapshot = Tracker.state.cur_snapshot + elapsed

    if Tracker.state.is_taking_snapshot then
        if Tracker.state.cur_snapshot >= 300 then
            Tracker:StopTakingSnapshot()
            Tracker.state.cur_snapshot = 0
        elseif Tracker.state.roster_update >= 60 then
            Tracker.roster:Update()
            Tracker.state.roster_update = 0
        end
    elseif Tracker.state.new_snapshot >= 900 then
        Tracker:StartTakingSnapshot()
        Tracker.state.new_snapshot = 0
    end
end

Tracker.timer_frame = CreateFrame("Frame")
Tracker.timer_frame:SetScript("OnUpdate", Tracker.TimerOnUpdate)