local reaper = reaper

-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

-- local Gui = require("gui")

function Text(context, text, wrap_position)
    reaper.ImGui_PushTextWrapPos(context, wrap_position)
    reaper.ImGui_Text(context, text)
    reaper.ImGui_PopTextWrapPos(context)
end

return Text
