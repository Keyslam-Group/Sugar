-- This module is responsible for painting the UI.

local paint = {}
local Context = {}

function paint.newContext(width, height)
    return setmetatable({
        width = width,
        height = height,
        canvas = love.graphics.newCanvas(width, height),
        drawOperations = {},
        currentZIndex = 0,
    }, {
        __index = function(self, func)
            if Context[func] then
                return Context[func]
            end

            return Context._registerFunction(func)
        end,
    })
end

function Context.setZIndex(self, zIndex)
    self.currentZIndex = zIndex
end

function Context.increaseZIndex(self)
    self.currentZIndex = self.currentZIndex + 1
end

function Context._error(self, ...)
    error("Trying to call undefined method of context:" .. ...)
end

function Context._registerFunction(func)
    if love.graphics[func] then
        Context[func] = function(self, ...)
            table.insert(self.drawOperations, {
                func = func,
                zIndex = self.currentZIndex,
                args = { ... },
            })
        end
    else
        Context[func] = function(self, ...)
            error("Trying to call undefined method of context:" .. func)
        end
    end

    return Context[func]
end

function paint.paintContext(context)
    love.graphics.setCanvas(context.canvas)
    love.graphics.clear()

    table.sort(context.drawOperations, function(a, b)
        return a.zIndex < b.zIndex -- this may be flipped
    end)

    for _, drawOperation in ipairs(context.drawOperations) do
        love.graphics[drawOperation.func](unpack(drawOperation.args))
    end

    love.graphics.setCanvas()
    return context.canvas
end


return paint
