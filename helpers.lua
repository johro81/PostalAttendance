PostalAttendance_Helpers = {
    debug = True,
}

local H = PostalAttendance_Helpers

function H:Print(msg)
    ChatFrame1:AddMessage(msg)
end

function H:Debug(msg)
    if self.debug then
        ChatFrame1:AddMessage(msg)
    end
end 
