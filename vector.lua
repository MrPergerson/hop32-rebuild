
-- Example: Triangle
local triangle = {
    {x = 2, y = 2},
    {x = 8, y = 2},
    {x = 5, y = 8}
}



-- Checks a given point if it inside polygon
-- edges: tabble of edges to check
-- xp: x point we want to check
-- yp: y point we want to check
function isInsidePolygon(edges, xp, yp)
    -- checks the right side
    -- count == odd, inside, count == even, outside

    -- y condition
    -- (yp < y1) ~= (yp < y2) -- must be between the two y points
    -- xp < x1 + ((yp-y1)/(y2-y1)) * (x2-x1)

    local count = 0

    -- need to implement the polygon table

end

-- creates polygon with 4 vertices that expand to the max height and width
function generateSimplePolygon(x,y,width, height)

    local x_edge_1 = x + rnd(width)
    local x_edge_2 = x + rnd(width)
    local y_edge_1 = y + rnd(height)
    local y_edge_2 = y + rnd(height)

    return {
        {x = x_edge_1, y = y},
        {x = x + width, y = y_edge_2},
        {x = x_edge_2, y = y + height},
        {x = x, y = y_edge_1}
    }

end

function generateRandomPolygon(vertices, x,y, width, height)
    -- not necessary right now
end

function drawPolygon(polygon)
    line()
    for i = 1, #polygon do 
        line(polygon[i].x, polygon[i].y, 8)
    end
    line(polygon[1].x, polygon[1].y, 8)
end