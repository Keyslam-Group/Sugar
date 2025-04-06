local Node = {}

function Node:new(props, buildFunction)
    self.props = props
    self.buildFunction = buildFunction

    local this = self

    self.effect = signal.effect(function ()
        local buildResult = buildFunction(props)

        -- If buildResult is a Node store the rootElement, if it's nil or Element, store the root as is
        local newRootElement = t.isNode(buildResult) and buildResult.rootElement or buildResult

        if this.rootElement then
            if this.rootElement.parentElement then
                this.rootElement.parentElement:replaceChild(this.rootElement, newRootElement)
            end

            this.rootElement:destroy()
        end

        this.rootElement = newRootElement
    end)
end

function Node:destroy()
    self.effect:destroy()
    
    if self.rootElement then
        if self.rootElement.parentElement then
            self.rootElement.parentElement:removeChild(self.rootElement)
        end

        self.rootElement:destroy()
    end
    
    self.rootElement = nil
end

return Node

