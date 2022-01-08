local reaper = reaper

-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)


function ContentTab(context, t_id, t_label, t_content)
    reaper.ImGui_BeginTabBar(context, t_id)
    if reaper.ImGui_BeginTabItem(context, t_label, true,
                                 reaper.ImGui_TabItemFlags_None()) then
        Widgets.Text(context, t_content, 500)
        reaper.ImGui_EndTabItem(context)
    end
    reaper.ImGui_EndTabBar(context)
end

return ContentTab
