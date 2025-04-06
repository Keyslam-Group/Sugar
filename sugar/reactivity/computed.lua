local PATH = string.sub(..., 1, string.len(...) - string.len("reactivity.computed"))

local Class = require(PATH .. "lib.class")

local Source = require(PATH .. "reactivity.source")
local Sink = require(PATH .. "reactivity.sink")

---@class Sugar.Reactivity.Computed : Sugar.Reactivity.Source, Sugar.Reactivity.Sink
---@overload fun(fn, ...): Sugar.Reactivity.Computed
local Computed = Class({
    name = "Sugar.Reactivity.Computed",
    implements = { Source, Sink }
})

function Computed:new(fn)
    self.fn = fn

    self.isValueDirty = true
    self.value = nil
end

function Computed:recomputeValue()
    self:begin()
    self.value = self.fn()
    self:finish()

    self.isValueDirty = false
end

function Computed:get()
    if self.isValueDirty then
        self:recomputeValue()
    end

    return Source.get(self)
end

return Computed
