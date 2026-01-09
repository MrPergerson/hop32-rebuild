function isInsidePolygon(vertices, xp, yp)
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