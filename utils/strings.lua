StringUtils = {}

function StringUtils.GetFileNameWithoutExtension(filepath)
    local name = string.gsub(filepath, "(.*/)(.*)", "%2")
    return string.sub(name, 0, #name - 4)
end

return StringUtils
