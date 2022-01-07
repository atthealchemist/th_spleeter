local reaper = reaper

-- Set package path to search within directory containing current script.
local path = ({reaper.get_action_context()})[2]:match('^.+[\\//]')
package.path = string.format('%s?.lua;%s?/init.lua', path, path)

local Spleeter = require("utils/spleeter")

local Store = require("gui/store")
local Widgets = require("gui/widgets")

local ReaperAPI = require("api/reaper_api")
-- local Parameters = require("gui/parameters")

local Utils = require("utils")

local Context = reaper.ImGui_CreateContext('spleeter')
Gui = {
    parameters = {
        combo_sample_rate = {
            values = {["11_KHZ"] = "11 kHz", ["16_KHZ"] = "16 kHz"},
            default = "11_KHZ"
        },
        combo_stems = {
            values = {
                ["2"] = "2 (vocals and other)",
                ["3"] = "3 (vocals, bass, other)",
                ["5"] = "5 (vocals, bass, drums, piano, other)"
            },
            default = "2"
        },
        radio_group_place_items = {
            values = {
                ["AS_TAKES"] = "As takes in selected media item",
                ["AS_NEW_TRACKS"] = "As new tracks"
            },
            default = "AS_NEW_TRACKS"
        },
        check_group_place_variants = {
            values = {
                ["VARIANT_VOCALS"] = "Vocals",
                ["VARIANT_DRUMS"] = "Drums",
                ["VARIANT_OTHER"] = "Other",
                ["VARIANT_BASS"] = "Bass",
                ["VARIANT_PIANO"] = "Piano"
            },
            default = {
                ["VARIANT_VOCALS"] = true,
                ["VARIANT_DRUMS"] = false,
                ["VARIANT_OTHER"] = true,
                ["VARIANT_BASS"] = false,
                ["VARIANT_PIANO"] = false
            }
        }
    }
}

function Gui._init()
    local font_size = reaper.GetAppVersion():match('OSX') and 12 or 14
    Font = reaper.ImGui_CreateFont('Arial Unicode', font_size)
    reaper.ImGui_AttachFont(Context, Font)

end

function Gui._set_place_variants_based_on_selected_stems_count()
    local variants = {}
    local variants_default = {}
    local stems = Store.get("combo_stems_key")

    local keys = {}
    if tonumber(stems) >= 2 then
        table.insert(keys, "VARIANT_VOCALS")
        table.insert(keys, "VARIANT_OTHER")
        if tonumber(stems) > 2 then
            table.insert(keys, "VARIANT_DRUMS")
            table.insert(keys, "VARIANT_BASS")
            if tonumber(stems) == 5 then
                table.insert(keys, "VARIANT_PIANO")
            end
        end
    end

    for _, k in ipairs(keys) do
        variants[k] = Gui.parameters.check_group_place_variants.values[k]
        variants_default[k] =
            Gui.parameters.check_group_place_variants.default[k]
    end

    Gui.parameters.check_group_place_variants.values = variants
    Gui.parameters.check_group_place_variants.default = variants_default

end

-- local text = 'The quick brown fox jumps over the lazy dog'

function Gui._run_spleeter()
    local stems = Store.get("combo_stems_key")
    local sample_rate = Store.get("combo_sample_rate_key")
    local place_items_var = Store.get("radio_group_place_items_key")
    local spl = Spleeter:new(stems, sample_rate, SelectedItems,
                             {place_items_mode = place_items_var})
    local res = spl:process()
    Store.set("command_output", tostring(res) .. "\n")
end

function Gui.button_clicked()
    if (#SelectedItems) > 0 then
        reaper.defer(Gui._run_spleeter)
    else
        reaper.ShowMessageBox(
            "You should select at least one media item to process it with Spleeter!",
            "Error", 0)
    end
end

function Gui._draw_window()
    Widgets.Combobox(Context, "combo_sample_rate", "Sample rate",
                     Gui.parameters["combo_sample_rate"].values,
                     Gui.parameters["combo_sample_rate"].default)

    Widgets.Combobox(Context, "combo_stems", "Stems count",
                     Gui.parameters["combo_stems"].values,
                     Gui.parameters["combo_stems"].default)

    Gui._set_place_variants_based_on_selected_stems_count()

    Widgets.CheckboxGroup(Context, "check_group_place_variants",
                          "Place variants",
                          Gui.parameters["check_group_place_variants"].values,
                          Gui.parameters["check_group_place_variants"].default)

    Widgets.RadioButtonGroup(Context, "radio_group_place_items", "Place items",
                             Gui.parameters["radio_group_place_items"].values,
                             Gui.parameters["radio_group_place_items"].default)

    if Store.get("command_output") then
        Widgets.ContentTab(Context, "tab_log_output", "Output",
                           Store.get("command_output"))
    end

    Widgets.ContentTab(Context, "tab_log_options", "Options", Gui._log_options())

    if reaper.ImGui_Button(Context, 'Process tracks') then
        Gui.button_clicked()
    end

end

function Gui._log_options()
    local options = string.format(
                        "Selected items count: %s\nSample rate: %s\nStems count: %s\nPlace spleeted items: %s\n",
                        tostring(Store.get("selected_items_count")),
                        Gui.parameters.combo_sample_rate.values[Store.get(
                            "combo_sample_rate_key")], Gui.parameters
                            .combo_stems.values[Store.get("combo_stems_key")],
                        Gui.parameters.radio_group_place_items.values[Store.get(
                            "radio_group_place_items_key")])

    options = "\n" .. options ..
                  Utils.StringifyTable(
                      Store.get("check_group_place_variants_key"), ", ") .. "\n"
    -- for k, v in pairs(Store.get("check_group_place_variants_key")) do
    --     options = options .. string.format("%s: %s, ", k, v)
    -- end
    return options
end

function Gui._loop()
    SelectedItems = ReaperAPI.get_selected_media_items()
    Store.set("selected_items_count", #(SelectedItems))

    local window_flags = reaper.ImGui_WindowFlags_None()
    reaper.ImGui_SetNextWindowSize(Context, 400, 400, reaper.ImGui_Cond_Once())
    reaper.ImGui_PushFont(Context, Font)

    local visible, open = reaper.ImGui_Begin(Context, 'spleeter', true,
                                             window_flags)
    if visible then
        Gui._draw_window()
        reaper.ImGui_End(Context)
    end
    reaper.ImGui_PopFont(Context)

    if open then
        reaper.defer(Gui._loop)
    else
        reaper.ImGui_DestroyContext(Context)
    end
end

function Gui.draw()
    Gui._init()
    Gui._loop()
end

return Gui
