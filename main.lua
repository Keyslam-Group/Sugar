require("lldebugger").start()

function love.errorhandler(msg)
    error(msg, 2)
end

require("examples.signals")