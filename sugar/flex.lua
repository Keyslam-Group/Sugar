local flex = {}

function flex.getSizeConstraints(props, children)

end

function flex.sizeConstraintsAreEqual(a, b)

end

function flex.size(sizeConstraints, props, x, y, w, h)

end

function flex.sizeChildren(sizeConstraints, props, children, x, y, availableWidth, availableHeight, forEachChild, ...)
  local startChildIndex, endChildIndex = getStartAndEndChildIndex(props, children)

  local step = endChildIndex > startChildIndex and 1 or -1

  local cx, cy = initialCoordinates(sizeConstraints, props, x, y, availableWidth, availableHeight)

  for i = startChildIndex, endChildIndex, step do
    local child = children[i]
    local cw, ch = getChildSize(sizeConstraints, props, child, availableWidth, availableHeight)

    forEachChild(child, cx, cy, cw, ch, ...)

    cx, cy = incrementCoordinates(sizeConstraints, props, cx, cy, cw, ch)
  end
end

function getStartAndEndChildIndex(props, children)
  local startChildIndex = 1
  local endChildIndex = #children

  --TODO: When laying items, we may want to start from the last item and go backwards, depending on justify

  if props.reverseOrder then
    startChildIndex, endChildIndex = endChildIndex, startChildIndex
  end

  return startChildIndex, endChildIndex
end

function initialCoordinates(sizeConstraints, props, x, y, availableWidth, availableHeight)


end

function incrementCoordinates(sizeConstraints, props, cx, cy, cw, ch)

end

function getChildSize(sizeConstraints, props, child, availableWidth, availableHeight)

end

return flex