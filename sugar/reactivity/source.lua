local PATH = string.sub(..., 1, string.len(...) - string.len("reactivity.source"))

local Class = require(PATH .. "lib.class")

---@class Sugar.Reactivity.Source
---@field protected value any
local Source = Class({
    name = "Sugar.Reactivity.Source"
})

function Source:get()
    return self.value
end

function Source:__call()
    return self:get()
end

return Source

