Parameters = {}

function Parameters.add(id, values, default)
    Parameters[id] = {values = values, default = default}
end

function Parameters.get(id) return Parameters[id] end

-- id
-- possible_values
-- default_value
-- store

return Parameters
