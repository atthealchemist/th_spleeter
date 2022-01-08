local reaper = reaper
-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

local Shell = require("utils/shell")
local ReaperAPI = require("api/reaper_api")
local Utils = require("utils")

Spleeter = {
    stems = 2, -- 2, 4,or  5
    sample_rate = '11_KHZ', -- or 16 kHz
    mediaItems = {},
    output_path = "output",
    options = {place_items_mode = ""},
    mapping = {place_items = {["AS_TAKES"] = {3}, ["AS_NEW_TRACKS"] = {1, 128}}}
}

function Spleeter:new(stems, sample_rate, mediaItems, options)
    self:setStems(stems)
    self:setSampleRate(sample_rate)
    self:setMediaItems(mediaItems)
    self:setOptions(options)

    return self
end

function Spleeter:setOptions(options)
    self.options = {
        place_items_mode = self.mapping.place_items[options.place_items_mode]
    }
end

function Spleeter:setStems(stems)
    stems = tonumber(stems)
    if stems < 2 or stems > 5 or stems == 3 then
        reaper.ShowMessageBox("Stems count should be 2, 4, or 5!", "Error", 0)
    end
    self.stems = stems
end

function Spleeter:setSampleRate(sample_rate)
    if sample_rate == "default" or sample_rate == "11_KHZ" then
        self.sample_rate = ""
    elseif sample_rate == "16_KHZ" then
        self.sample_rate = "-16kHz"
    else
        reaper.ShowMessageBox(
            "Spleeter supports 11KHz (default) and 16 KHz sample rates!",
            "Error", 0)
    end
end

function Spleeter:setMediaItems(items)
    local _items = {}
    for i, item in ipairs(items) do
        local fp = ReaperAPI.get_media_item_file_path(item)
        if fp then _items[i] = {fp, item} end
    end
    self.mediaItems = _items
end

function Spleeter:process()
    local projectFp = reaper.GetProjectPath()
    local spleeter_cmd = string.format(
                             "/usr/bin/python3.9 -m spleeter separate -o \"%s\" -p spleeter:%dstems ",
                             projectFp .. "/" .. Spleeter.output_path,
                             Spleeter.stems)

    for _, val in ipairs(self.mediaItems) do
        local filepath, mi = val[1], val[2]
        local filename = Utils.strings.GetFileNameWithoutExtension(filepath)
        local command = spleeter_cmd .. " " .. "\"" .. filepath .. "\""
        reaper.ShowConsoleMsg("Command to process: " .. command .. "\n")
        local err, result = Shell.execute(command)
        if err then
            if string.match(err, "ERROR") then
                reaper.ShowMessageBox(err, "Spleeter error!", 0)
                return false
            elseif string.match(err, "successfully") then
                reaper.ShowMessageBox(err, "Spleeter info", 0)
            end
        end
        reaper.ShowConsoleMsg("Result: " .. result .. "\n")
        if result then
            local variants = Store.get("check_group_place_variants_key")
            for k, v in pairs(variants) do
                if v == true then
                    local variant = string.lower(k:gsub("VARIANT_", ""))
                    if variant == "other" then
                        variant = "accompaniment"
                    end
                    -- reaper.ShowConsoleMsg("New FN: " .. filename .. "\n")
                    local newFilePath = string.format("%s/%s/%s/%s", projectFp,
                                                      self.output_path,
                                                      filename,
                                                      variant .. ".wav")
                    -- reaper.ShowConsoleMsg("New FP: " .. newFilePath .. "\n")
                    ReaperAPI.replace_media_item(mi, newFilePath,
                                                 self.options.place_items_mode)
                end
            end
        end
        return result
    end
end

return Spleeter
