Store = {}

function Store.set(key, value) Store[key] = value end

function Store.get(key)
    if Store[key] then return Store[key] end
    return false
end

return Store
