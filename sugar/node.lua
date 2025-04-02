local Node = {}

function Node:new(props, buildFunction)
    self.props = props
    self.buildFunction = buildFunction

    signal.effectWithId(self, self._build, self)
end

function Node:destroy()
    signal.destroyEffectWithId(self)
    self.rootElement.parentElement:removeChild(self.rootElement)
end

function Node:_build()
    local buildResult = self.buildFunction(self.props)

    -- If buildResult is a Node store the rootElement, if it's nil or Element, store the root as is
    local newRootElement = buildResult and buildResult.rootElement or buildResult

    self.rootElement.parentElement:replaceChild(self.rootElement, newRootElement)
    self.rootElement = newRootElement
end

return Node

