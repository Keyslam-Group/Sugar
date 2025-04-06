-- A box element would create a FixedSizeElement with all its children Nodes acting being converted to strings
-- It would also have the following properties:
-- - text (string)
-- - font (Font)
-- - color (Color)
-- - width (number, fitContent(), grow(min, max))
-- - align (left, center, right, justify)
-- - verticalAlign (top, center, bottom)

-- Maybe in the future:
-- - underline
-- - strikethrough
-- - overline
-- - overflow (hidden, wrap, ellipsis)

local Text = {}

function Text:new (props)
  self.props = props
  self.rect = spatialhash.newRect(self) -- This is a hit zone for this Box

  self.font = props.font or defaults.defaultFont
  self.color = props.color or defaults.defaultColor

  -- TODO: Validate that the children are all strings or numbers, or in case of a single child it can also be a colored text table
  -- TODO: Error loudly if not
  self.text = #props == 1 and props[1] or table.concat(props, '')

  -- Calculates the size constraints of the Box
  self.sizeConstraints = {
    minWidth = props.width or self.font:getWidth(self.text),
    maxWidth = props.width or nil,
  }

  local _, wrap = self.font:getWrap(self.text, self.sizeConstraints.minWidth)
  self.sizeConstraints.minHeight = self.font:getHeight() * #wrap
end

function Text:setParent(parent)
    self.parentElement = parent
end

function Text:writeDrawOperations(context, x, y, w, h)
  local actualWidth, wrap = self.font:getWrap(self.text, w)
  local actualHeight = self.font:getHeight() * #wrap

  local actualY = y
  if (self.props.verticalAlign == 'middle') then
    actualY = y + (h - actualHeight) / 2
  elseif (self.props.verticalAlign == 'bottom') then
    actualY = y + h - actualHeight
  end

  local actualX = x
  if (self.props.align == 'center') then
    actualX = x + (w - actualWidth) / 2
  elseif (self.props.align == 'right') then
    actualX = x + w - actualWidth
  elseif (self.props.align == 'justify') then
    actualWidth = w
  end

  local prevZIndex = nil
  if (self.props.zIndex) then
      self.rect:set(self.props.zIndex, context:withinBounds(actualX, actualY, actualWidth, actualHeight))
      prevZIndex = context:setZIndex(self.props.zIndex)
  else
      prevZIndex = context:increaseZIndex()
      self.rect:set(prevZIndex + 1, context:withinBounds(actualX, actualY, actualWidth, actualHeight))
  end

  context:setColor(self.color)
  -- Here we rely on printf to align the text 
  context:printf(self.text, self.font, x, actualY, w, self.props.align)

  context:setColor(defaults.defaultColor)

  context:setZIndex(prevZIndex)
end

function Text:destroy()
  self.rect:destroy()
end

return Text

