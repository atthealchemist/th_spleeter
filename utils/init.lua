Utils = {}

function Utils.StringifyTable(list, separator)
    local str = ""
    if type(list) == "string" then return list end
    for k, v in pairs(list) do
        str = str .. tostring(k) .. ": " .. tostring(v) .. separator
    end
    str = str .. "\n";
    return str
end

function Utils.GetFileNameWithoutExtension(filepath)
    local name = string.gsub(filepath, "(.*/)(.*)", "%2")
    return string.sub(name, 0, #name - 4)
end

return Utils

