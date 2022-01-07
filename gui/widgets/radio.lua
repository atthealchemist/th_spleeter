local reaper = reaper

-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

local Store = require("gui/store")

function RadioButtonGroup(context, rg_id, rg_label, values, default)
    local items = values
    local default_item_key = default

    local defaultItem = Store.get(rg_id .. "_key") or default_item_key
    Store.set(rg_id .. "_key", defaultItem)

    reaper.ImGui_BeginTabBar(context, rg_id)
    if reaper.ImGui_BeginTabItem(context, rg_label, true,
                                 reaper.ImGui_TabItemFlags_None()) then
        for key, value in pairs(items) do
            local is_selected = Store.get(rg_id .. "_key") == key
            if reaper.ImGui_RadioButton(context, value, is_selected) then
                Store.set(rg_id .. "_key", key)
            end
            reaper.ImGui_SameLine(context)
        end
        reaper.ImGui_NewLine(context)
        reaper.ImGui_EndTabItem(context)
    end
    reaper.ImGui_EndTabBar(context)
end

return RadioButtonGroup
