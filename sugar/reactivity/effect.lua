local PATH = string.sub(..., 1, string.len(...) - string.len("reactivity.effect"))

local Class = require(PATH .. "lib.class")

local Sink = require(PATH .. "reactivity.sink")

---@class Sugar.Reactivity.Effect : Sugar.Reactivity.Sink
---@overload fun(fn, ...): Sugar.Reactivity.Effect
local Effect = Class({
    name = "Sugar.Reactivity.Effect",
    implements = { Sink }
})

function Effect:new(fn, ...)
    self.fn = fn
    self.args = { ... }

    self:run()
end

function Effect:run()
    self:begin()
    self.fn(unpack(self.args))
    self:finish()
end

function Effect:destroy()
end

return Effect
