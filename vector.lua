
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
function isInsidePolygon(vertices, xp, yp)
    -- checks the right side
    -- count == odd, inside, count == even, outside

    -- y condition
    -- (yp < y1) ~= (yp < y2) -- must be between the two y points
    -- xp < x1 + ((yp-y1)/(y2-y1)) * (x2-x1)

    local count = 0

    for p = 1, #vertices do

        local p2 = p+1
        if p2 > #vertices then
            p2 = 1
        end

        if ((yp < vertices[p].y) ~= (yp < vertices[p2].y)) and 
        (xp < vertices[p].x + ((yp-vertices[p].y)/(vertices[p2].y-vertices[p].y)) * (vertices[p2].x-vertices[p].x)) then
            count += 1
        end
    end

    return not(count%2 == 0)
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

-- for debug purposes
function drawPolygon(polygon)
    line()
    for i = 1, #polygon do 
        line(polygon[i].x, polygon[i].y, 11)
    end
    line(polygon[1].x, polygon[1].y, 11)
end

function drawRayCast(point, direction, color)

    line()
    line(point.x, point.y, point.x + direction.x * 100, point.y + direction.y * 100, color)

end