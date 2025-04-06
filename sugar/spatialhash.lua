local Rect = {}

function Rect:new(spatialHash)

end

function Rect:set(zIndex, x, y, w, h)

end

function Rect:destroy()

end


local SpatialHash = {}

function SpatialHash:new()

end

function SpatialHash:destroy()

end

function SpatialHash:newRect()

end

function SpatialHash:getRectsAt(x, y)

end

function SpatialHash:getRectsInArea(x, y, w, h)

end

return SpatialHash