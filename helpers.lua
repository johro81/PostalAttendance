PostalAttendance_Helpers = {
    debug = True,
}

local H = PostalAttendance_Helpers

H.Print = function(msg, arg1)
    if arg1 ~= nil then
        msg = msg .. tostring(arg1)
    end

    ChatFrame1:AddMessage(msg)
end

H.Debug = function(msg)
    if self.debug then
        ChatFrame1:AddMessage(msg)
    end
end 

H.TableContains = function(table, val)
    for k, v in ipairs(table) do
        if v == val then
            return true
        end
    end
    return false
end
