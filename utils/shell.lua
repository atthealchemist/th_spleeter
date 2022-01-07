local reaper = reaper
-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

Shell = {}

function Shell.execute(command)
    local _cmd = string.format([[%s]], command)
    local _error = ""
    local _result = ""
    reaper.ShowConsoleMsg("Executing command: " .. _cmd .. "\n")
    local handle = io.popen(_cmd, "r")
    _result = handle:read("*a")
    handle:close()
    if (#_result) > 1 then _error = _result end
    return _error, _result
end

return Shell
