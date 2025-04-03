local Node = {}

function Node:new(props, buildFunction)
    self.props = props
    self.buildFunction = buildFunction

    local this = self

    self.effect = signal.effect(function ()
        local buildResult = buildFunction(props)

        -- If buildResult is a Node store the rootElement, if it's nil or Element, store the root as is
        local newRootElement = buildResult and buildResult.rootElement or buildResult

        this.rootElement.parentElement:replaceChild(this.rootElement, newRootElement)
        this.rootElement:destroy()
        this.rootElement = newRootElement
    end)
end

function Node:destroy()
    self.effect:destroy()
    self.rootElement.parentElement:removeChild(self.rootElement)
    self.rootElement = nil
end

return Node

