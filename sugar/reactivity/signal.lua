local PATH = string.sub(..., 1, string.len(...) - string.len("reactivity.signal"))

local Class = require(PATH .. "lib.class")

local Source = require(PATH .. "reactivity.source")

---@class Sugar.Reactivity.Signal : Sugar.Reactivity.Source
---@overload fun(fn, ...): Sugar.Reactivity.Signal
local Signal = Class({
    name = "Sugar.Reactivity.Signal",
    implements = { Source }
})

function Signal:new(value)
    self.value = value
end

function Signal:set(value)
    self.value = value
end

function Signal:update(fn)
    local value = fn(self.value)
    self:set(value)
end

return Signal
