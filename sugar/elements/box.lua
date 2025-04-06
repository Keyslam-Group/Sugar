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
    self.sizeConstraints = flex.getSizeConstraints(self.props, self.props) -- props, children
end

-- Function called when a parent adopts the element
function Box:setParent(parent)
    self.parentElement = parent
end

-- One of our children has changed or been replaced by something else, resize accordingly
function Box:replaceChild(oldChild, newChild)
    for i, child in ipairs(self.props) do
        if child == oldChild then
            self.props[i] = newChild
            break
        end
    end

    local oldSizeConstraints = self.sizeConstraints
    self.sizeConstraints = flex.getSizeConstraints(self.props, self.props) -- props, children

    if not flex.sizeConstraintsAreEqual(self.sizeConstraints, oldSizeConstraints) then
        -- We are telling the parent that the size of this Element has changed
        self.parentElement:replaceChild(self, self)
    end
end

local forEachChild = function (child, x, y, w, h)
    child:writeDrawOperations(context, cx, cy, cw, ch)
end

-- Function called by the parent to draw this element
function Box:writeDrawOperations(context, x, y, w, h)
    -- The received w, h may exceed or not respect the size constraints, so we need to size it properly
    -- If the size is off we may want to align the element again, changing the x, y coordinates
    local nx, ny, nw, nh = flex.size(self.sizeConstraints, x, y, w, h)

    local prevZIndex = nil
    if self.props.zIndex then
        self.rect:set(self.props.zIndex, context:withinBounds(nx, ny, nw, nh))
        prevZIndex = context:setZIndex(self.props.zIndex)
    else
        prevZIndex = context:increaseZIndex()
        self.rect:set(prevZIndex + 1, context:withinBounds(nx, ny, nw, nh))
    end

    if t.isCallable(self.props.background) then
        self.props.background(context, nx, ny, nw, nh)
    else
        context:setColor(self.props.background or defaults.defaultBackground)
        context:rectangle('fill', nx, ny, nw, nh, self.props.borderRadius, self.props.borderRadius)
    end

    if self.props.borderWidth > 0 then
        context:setLineWidth(self.props.borderWidth)
        context:setColor(self.props.borderColor or defaults.defaultBorderColor)
        context:rectangle('line', nx, ny, nw, nh, self.props.borderRadius, self.props.borderRadius)
    end

    context:setColor(defaults.defaultColor)

    flex.sizeChildren(nx, ny, nw, nh, self.sizeConstraints, self.props, self.props, forEachChild)

    context:setZIndex(prevZIndex)
end

-- Function called when a child dies
function Box:removeChild(child)
    self:replaceChild(child, nil)
end

-- Function called when parent kills child
function Box:destroy()
    self.rect:destroy()

    for k, v in ipairs(self.props) do
        if t.isNode(v) then
            v:destroy()
        end
    end
end

return Box