# Elements

Elements are not a new class or type of object, they are Nodes that behave in a particular way.

We do need to tell Nodes that are Elements apart since they need to be sized, rendered and receive events.

This is done through duck typing, if it quacks like a duck we know it's a duck.

To do this we need to define what properties an Element has.

## Element properties that don't exist in Nodes

### setParent(parent)

Set this element's parent.

### parentElement

Whenever an Element is sized it stores the `parentElement` as a property.

### sizeConstraints

Size constraints for this element.

Required fields:

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

### writeDrawOperations(context, x, y, w, h)

Context is a wrapper for love.graphics operations targeting a canvas, operations are sorted by zIndex which can be set through the context.

This function should render the object and call writeDrawOperations on children if applicable

### removeChild(child)

### replaceChild(child, newChild)

## Node properties that don't exist in Elements

### rootElement

### builderEffect

### ???

## Telling them apart

The easiest way to tell if a Node is an Element, is by checking for the existence of `rootElement` if that exists it's a Node, if it doesn't, it's an Element.

This assumption is taken into account on the library design, Elements that don't follow the rules defined here, are not defined properly
