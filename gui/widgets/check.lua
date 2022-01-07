local reaper = reaper

-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

local Store = require("gui/store")

function CheckboxGroup(context, cg_id, cg_label, items, default_item_keys)
    local default_items = Store.get(cg_id .. "_key") or default_item_keys
    Store.set(cg_id .. "_key", default_items)

    reaper.ImGui_BeginTabBar(context, cg_id)
    if reaper.ImGui_BeginTabItem(context, cg_label, true,
                                 reaper.ImGui_TabItemFlags_None()) then
        -- for key, value in pairs(items) do
        local check_group_store = Store.get(cg_id .. "_key")
        for key, value in pairs(check_group_store) do
            local is_checked = check_group_store[key] ~= false
            if reaper.ImGui_Checkbox(context, items[key], is_checked) then
                check_group_store[key] = not is_checked
            end
            -- end
            reaper.ImGui_SameLine(context)
        end
        reaper.ImGui_NewLine(context)
        reaper.ImGui_EndTabItem(context)
    end
    reaper.ImGui_EndTabBar(context)
end

return CheckboxGroup
