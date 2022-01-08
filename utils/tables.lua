TableUtils = {}

function TableUtils.Stringify(list, separator)
    local str = ""
    if type(list) == "string" then return list end
    for k, v in pairs(list) do
        str = str .. tostring(k) .. ": " .. tostring(v) .. separator
    end
    str = str .. "\n";
    return str
end

function TableUtils.Sum(list)
    return TableUtils.Reduce(list, function(a, b) return a + b end)
end

function TableUtils.Reduce(list, func, init)
    local accumulator = init
    for index, value in ipairs(list) do
        if index == 1 and not init then
            accumulator = value
        else
            accumulator = func(accumulator, value)
        end
    end
    return accumulator
end

return TableUtils
