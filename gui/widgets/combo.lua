local reaper = reaper

-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

local Store = require("gui/store")

function Combobox(context, combo_id, combo_label, values, default)
    local items = values
    local default_item_key = default

    local previewItemKey = Store.get(combo_id .. "_key")
    local previewItem = nil
    if not previewItemKey then
        previewItem = items[default_item_key]
        Store.set(combo_id .. "_key", default_item_key)
    else
        previewItem = items[previewItemKey]
    end

    if reaper.ImGui_BeginCombo(context, combo_label, previewItem) then
        for key, item in pairs(items) do
            local is_selected = Store.get(combo_id .. "_key") == key
            if reaper.ImGui_Selectable(context, item, is_selected) then
                Store.set(combo_id .. "_key", key)
            end
            -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
            if is_selected then
                reaper.ImGui_SetItemDefaultFocus(context)
            end
        end
        reaper.ImGui_EndCombo(context)
    end
end

return Combobox
