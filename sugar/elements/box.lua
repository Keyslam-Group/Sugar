-- A box element would create a FlexElement with all its children Nodes acting as child Elements
-- It would also have the following properties:
-- - padding (number for each sides)
-- - margin (number for each sides)
-- - background (color, Texture or function)
-- - blendMode (string)
-- - border (color)
-- - borderRadius (all corners)
-- - borderWidth (number)
-- - width (number, fitContent(), grow(min, max))
-- - height (number, fitContent(), grow(min, max))
-- - aspectRatio (number)
-- - direction (row or column)
-- - justify (start, center, end, space-between, space-around, space-evenly)
-- - align (start, center, end)
-- - gap (number, space between elements)
-- - zIndex (number)

local Box = {}

function Box:new (props)
    self.props = props
    self.rect = spatialhash.newRect(self) -- This is a hit zone for this Box

    -- Calculates the size constraints of the Box
    self.sizeConstraints = flex.getSizeConstraints(props, props) -- props, children
end

function Box:setParent(parent)
    self.parentElement = parent
end

function Box:writeDrawOperations(context, x, y, w, h)
    -- The received w, h may exceed or not respect the size constraints, so we need to size it properly
    -- If the size is off we may want to align the element again, changing the x, y coordinates
    local nx, ny, nw, nh = flex.size(self.sizeConstraints, x, y, w, h)

    local prevZIndex = nil
    if (self.props.zIndex) then
        self.rect:set(nx, ny, nw, nh, self.props.zIndex)
        prevZIndex = context:setZIndex(self.props.zIndex)
    else
        prevZIndex = context:increaseZIndex()
        self.rect:set(nx, ny, nw, nh, prevZIndex + 1)
    end

    if (isCallable(self.props.background)) then
        self.props.background(context, nx, ny, nw, nh)
    else
        context:setColor(self.props.background or context.defaultBackground)
        context:rectangle('fill', nx, ny, nw, nh, self.props.borderRadius, self.props.borderRadius)
    end

    if self.props.borderWidth > 0 then
        context:setLineWidth(self.props.borderWidth)
        context:setColor(self.props.borderColor or context.defaultBorderColor)
        context:rectangle('line', nx, ny, nw, nh, self.props.borderRadius, self.props.borderRadius)
    end

    context:setColor(color.defaultColor)

    -- This operation receives the props, like padding, gap, direction, justify, align, etc.
    -- It also receives the size constraints of the Box, where flex.getSizeConstraints() stored some information about the children
    -- It also receives an array of children, and the current x, y, w, h of the Box
    -- It returns the child, and the x, y, w, h of the child after being sized.
    -- This size may exceed the size constraints of the children so the child will need to call flex.size() again
    -- This size may overflow the Box, that's fine, we always respect the constraints of children.
    for child, cx, cy, cw, ch in flex.sizeChildren(self.sizeConstraints, self.props, self.props, nx, ny, nw, nh) do
        child:writeDrawOperations(context, cx, cy, cw, ch)
    end

    context:setZIndex(prevZIndex)
end

function Box:destroy()
    self.rect:destroy()

    for k, v in ipairs(self.props) do
        if isNode(v) then
            v:destroy()
        end
    end
end

return Box