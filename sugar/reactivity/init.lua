local PATH = string.sub(..., 1, string.len(...) - string.len("reactivity"))

local Reactivity = {}

---@module "sugar.reactivity.effect"
Reactivity.effect = require(PATH .. "reactivity.effect")

---@module "sugar.reactivity.computed"
Reactivity.computed = require(PATH .. "reactivity.computed")

---@module "sugar.reactivity.signal"
Reactivity.signal = require(PATH .. "reactivity.signal")

return Reactivity

