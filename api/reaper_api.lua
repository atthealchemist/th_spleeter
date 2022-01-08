local reaper = reaper

-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

local Utils = require("utils")

ReaperAPI = {project = 0}

function ReaperAPI.get_selected_media_items()
    local items = {}
    local mediasCount = reaper.CountSelectedMediaItems(ReaperAPI.project)
    for i = 1, mediasCount do
        items[i] = reaper.GetSelectedMediaItem(ReaperAPI.project, i - 1)
    end
    return items
end

function ReaperAPI.get_media_item_file_path(item)
    local mi_take = reaper.GetMediaItemTake(item, 0)
    local mi_take_src = reaper.GetMediaItemTake_Source(mi_take)
    local file_path = reaper.GetMediaSourceFileName(mi_take_src)
    return file_path
end

function ReaperAPI.get_start_and_end_of_media_item(item)
    local start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local _duration = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local _end = start + _duration
    return start, _end
end

function ReaperAPI._insert_media(item_file, modes)
    local mode = Utils.tables.Sum(modes)
    reaper.InsertMedia(item_file, mode)
end

function ReaperAPI.replace_media_item(item_to_replace, new_item_file, mode)
    local start, _end = ReaperAPI.get_start_and_end_of_media_item(
                            item_to_replace)
    reaper.ShowConsoleMsg(
        "Item start: " .. start .. "\t|| Item end: " .. _end .. "\n")
    reaper.ShowConsoleMsg("Item mode: " .. mode .. "\n")
    local default_pitch_shift = 0
    reaper.InsertMediaSection(new_item_file, mode, start, _end,
                              default_pitch_shift)
end

return ReaperAPI
