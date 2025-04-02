# Idea

Here I'll explain some ideas I have regarding this UI library and its DX

## Main DX

The proposed API looks something like:

```lua

local s = require 'sugar'

local value = s.signal(1)

ShowCount = s.Component(function (props)
    return s.Text(
        props.signal()
    )
end)

IncrementCounter = s.Component(function (props)
    return s.Box{
        backgroundColor = 'red',
        color = 'white',

        s.Text 'Increment',

        onClick = function ()
            props.signal:set(props.signal() + 1)
        end
    }
end)

Counter = s.Component(function (props)
    local value = props.signal or s.signal(1)

    return s.Box{
        direction = 'row',

        s.Text 'Count',
        ShowCount { signal = value },
        IncrementCounter { signal = value }
    }
end)

App = s.Component(function (props)
    return s.Box{
        backgroundColor = 'black', -- We could have a list of predefined colors or tokens
        borderColor = '#aa0000', -- Maybe hex as well?
        color = {1, 1, 1},        -- Or tables

        -- Children
        s.Box {
            direction = 'row',

            s.Text('Hello'),
            s.Text{ color='white', 'World'}
        }

        Counter()
    }
end)

local UI = s.Root(App())

```

## Components and Nodes

So the magic happens mainly on `s.Component` which creates a new Node constructor.

Nodes make up a tree with each node having references to their children, and each Node also acts a Signal sink.

s.Component takes a builder function, and returns the constructor.

The constructor sets up the Node, then creates a new Signal effect where the Node is updated with the new context returned by the render function. The node is then returned.

```lua
function s.Component (builderFunc)
    -- This is pseudo code, this would probably be an object with a __call metamethod
    -- We would probably have a NodeType and other things that identify this type of Components
    return function (props)
        local Node = s.newNode(props) -- props stored for memoization

        Node:effect(builderFunc, props) -- reactivity of the builderFunc

        return Node
    end
end
```

`Node:effect` is basically a wrapper around `signal.effect` which allows it to listen for signals and get updated whenever a sunk signal is updated.

When the effect executes, the contents of the Node get updated with the values returned by the builder function (we will explain this bit later).

Our effect will also build a reactivity tree where we know which effects get executed and destroyed based on signals changing (more on this later).

The builder function does not take any part on layout or painting to screen.
To do that we need to build a tree, but not out of Nodes, instead we build one out of Elements.

## Elements

Elements are similar to Nodes but they perform Layout calculations and Paint operations. These are exposed as builtin components like `s.Box`, `s.Text` etc.

The other difference between Nodes and Elements is that Elements are not reactive since they don't listen or modify signals directly.

This means that we can build a tree out of them that is completely detached from the reactivity tree we built with Effect.

To do this we have one rule which states that a Node can only return:

- nil, in which case they don't have a rootElement
- an Element, in which case that's their rootElement
- a Node, in which case the rootElement of that Node is also the rootElement of this node

This means that Nodes can have at most one rootElement.

```lua
MyBox = s.Component(function ()

    local elem = s.Box{ width = 300, height = 200 }

    return elem

end)

local node = MyBox()

print(node.rootElement.width)   -- 300
print(node.rootElement.height)  -- 200
```

Elements loop through their children, for Nodes we grab their rootElements, for Elements we grab the Element itself.

These children can also have children of their own, and this allows us to build a tree structure.

At any point in time, a Node can re-execute due to effects and destroy its rootElement and replace it with a new one.

These new Element replaces the old Element in the Element tree, this can cause layouts to recompute and things to re-paint on screen.

But we only need to recompute layouts if the Element changed size and we only need to re-paint things up to the parent Context of the top-most updated Element.

### Layout

When we first create an Element, the Element defines a set of Constraints for itself.

The Constraints basically specify the Element's minWidth, minHeight, maxWidth, maxHeight, growthFactor and an optional aspectRatio.

These Constraints come from the Element's props, for example:

```lua
s.Box{
    minWidth = 100,
    maxWidth = 400,
    height = 500
}
```

The constraints for this Element are:

```lua
{
    minWidth = 100,
    maxWidth = 400,
    minHeight = 500,
    maxHeight = 500,
    aspectRatio = nil,
    growthFactor = 1,
}
```

Constraints can also come from the children of a given element, whenever an Element its created, it iterates over each child Element and asks for their Constraints.

The Constraints of the children can help calculate the Element's constraints, but props will always override the values calculated.

## Sizing

Once we know the constraints of each element we then need to size them, this operation starts at the rootElement of the root Node.

The Element is given the screen size as width and height as available space, and respecting its own constraints it gives a size to itself.

From there it will calculate how much of the available size it will give to each child element trying to respect their sizing constraints.

The child Elements are then sized and they propagate, sizing each node.

## Paint Operations

While the sizing operation happens, each Element will write their Paint operations to a list in the currently active Context.

When an Element is destroyed or resized we also destroy all the Paint operations associated with it from the list, and notify the Context that it's currently dirty.

Whenever a Context repaints it also notifies its parent Context (if any) that it needs to be re-paint.

## Painting

Painting is just sorting by z-index (auto incrementing property that can be manually set with an attribute), then performing the operations in order drawing to a Canvas that belongs to the Context.

Whenever we wanna draw that Context we just draw the Canvas. We never perform paint operations directly to screen.
