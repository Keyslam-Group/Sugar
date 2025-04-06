local Reactivity = require("sugar.reactivity")

local Signal = Reactivity.signal
local Computed = Reactivity.computed
local Effect = Reactivity.effect

local counter = Signal(0)

local doubled = Computed(function()
    return counter() * 2
end)

local isEven = Computed(function()
    return counter() % 2 == 0
end)

local effect = Effect(function(message)
    print(string.format(
        "Counter: %d, Doubled: %d, Is Even: %s, Message: '%s'",
        counter(),
        doubled(),
        isEven() and "Yes" or "No",
        message
    ))
end, "My message")

counter:set(1)
counter:set(2)
counter:set(3)
counter:set(4)
counter:set(5)
counter:set(6)

effect:destroy()