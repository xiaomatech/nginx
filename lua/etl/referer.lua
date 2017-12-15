local str_format = string.format
local str_gmatch = string.gmatch
local table_insert = table.insert

local cjson_safe = require "cjson.safe"
local cjson_encode = cjson_safe.encode

function string:split(delimiter)
    local result = {}
    local _delimiter = str_format("([^'%s']+)", delimiter)
    for w in str_gmatch(self, _delimiter) do
        table_insert(result, w)
    end
    return result
end