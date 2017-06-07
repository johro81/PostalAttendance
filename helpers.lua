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

H.GetServerTime = function()
  local server_h, server_m = GetGameTime()
  local local_h, local_m = strsplit(':', date("%H:%M"))

  local server_s = server_h * 3600 + server_m * 60
  local local_s = tonumber(local_h) * 3600 + tonumber(local_m * 60)
  local delta_s = sever_s - local_s

  return time() + delta_s
end
