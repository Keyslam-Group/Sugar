local PATH = string.sub(..., 1, string.len(...) - string.len("reactivity.sink"))

local Class = require(PATH .. "lib.class")

---@class Sugar.Reactivity.Sink
local Sink = Class({
    name = "Sugar.Reactivity.Sink"
})

function Sink:begin()
end

function Sink:finish()
end

return Sink

