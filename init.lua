local PATH = (...):gsub('%.init$', '')

---@module "sugar"
local Sugar = require(PATH .. ".sugar")

return Sugar
