local reaper = reaper

-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

local Gui = require("gui")

local function main()
    -- Calls gui window
    reaper.defer(Gui.draw)
end

main()
