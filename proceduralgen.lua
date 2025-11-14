poke(0x5F2D, 0x1) -- enable keyboard input

chunks = {} -- 2 or 3 chunk tables

local TERRAIN_Y_OFFSET = 0

biome_length = 48


chunk_x_size = 16
map_x_size = 0
map_y_size = 32
local map_y_offset = -16
local hole_width = 2
local new_chunk_threshold = 128
local chunk_start_unit = 0
local draw_hole_chance = .5

-- tile ids: air = 0; grass = 2; ground = 3; wall = 4; 

debug_poly_render = {}

groundlevel = 11 -- relative to tiles, not pixels

function initProceduralGen()
    --set_biome_distances()
    map_x_size = BIOME_DIST_UNIT.VOID
end

function generateChunk(x_offset)

    local chunk = {x = x_offset, y = 0,  tiles = {}, surface_tiles = {}}

    -- Fill all cells with ground
    for x = x_offset, x_offset+chunk_x_size-1 do
        chunk.tiles[x] = {}
        for y = 0, map_y_size-1 do -- this creates 31 tiles FYI   
            if x < BIOME_DIST_UNIT.GRASS then
                chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.GROUND}
            elseif x < BIOME_DIST_UNIT.DESERT then
                chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.SAND_1}
            elseif x < BIOME_DIST_UNIT.MOUNTAIN then
                chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.MOUNTAIN_2}
            elseif x < BIOME_DIST_UNIT.SNOW then
                chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.SNOW_2}
            elseif x < BIOME_DIST_UNIT.CITY then
                chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.ORELAND_1}
            elseif x < BIOME_DIST_UNIT.VOID then
                chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.HELL_2}
            else
                chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.GROUND}
            end  
        end
    end

    --printh(#chunk.tiles[x_offset_unit])
    --printh(chunk.x_offset_unit)

    -- generate ground by removing ground tiles.
    -- Q: should I store the surface in an array? Then know which tiles I can spawn or modify on the surface.
    for x = x_offset, x_offset+chunk_x_size-1 do
        for y = 0, map_y_size-1 do      
            local h = get_cell_height_at_(x) + TERRAIN_Y_OFFSET -- Normalize x to [0, 1] (remember to explain why dividing by chunk_x_size fixes sin output)
            --h = 2 * sin( ((x-1) / chunk_x_size) * 2)
            if y - groundlevel < h then
                chunk.tiles[x][y].sprite = TILE.NONE
            end
            
        end
    end

    -- remove bottom
    --[[
        for x = x_offset, x_offset+chunk_x_size-1 do
            for y = 0, map_y_size-1 do      
                local h = biome_desert_height_at_(x) + TERRAIN_Y_OFFSET + 4 -- Normalize x to [0, 1] (remember to explain why dividing by chunk_x_size fixes sin output)
                --h = 2 * sin( ((x-1) / chunk_x_size) * 2)
                if y - groundlevel > h then
                    chunk.tiles[x][y].sprite = TILE.NONE
                end
                
            end
        end
        ]]
        
    
    -- draw a holes randomly
    -- don't draw holes in the last two chunks
    if x_offset > 0 and x_offset < (map_x_size-biome_length) and rnd(1) >= 1-draw_hole_chance then
        local random_x_pos = flr(rnd(chunk_x_size-hole_width))
        local hole_start = x_offset + random_x_pos

        for x = hole_start , hole_start + hole_width, 1 do
            for y = 0, map_y_size-1, 1 do
                chunk.tiles[x][y].sprite = TILE.NONE   
            end
            
        end
    end


    -- get all surface tiles. Update surface sprites if needed
    for x = x_offset, x_offset+chunk_x_size-1 do
        for y = 1, map_y_size-1 do 

            local above_tile = chunk.tiles[x][y-1]
            local target_tile = chunk.tiles[x][y]

            if above_tile.sprite == TILE.NONE and target_tile.sprite ~= TILE.NONE then
                add(chunk.surface_tiles, target_tile)

                if x < BIOME_DIST_UNIT.GRASS then
                    target_tile.sprite = TILE.GRASS
                elseif x < BIOME_DIST_UNIT.DESERT then
                    --target_tile.sprite = TILE.GRASS
                elseif x < BIOME_DIST_UNIT.MOUNTAIN then
                    target_tile.sprite = TILE.MOUNTAIN_1
                elseif x < BIOME_DIST_UNIT.SNOW then
                    --target_tile.sprite = TILE.GRASS
                elseif x < BIOME_DIST_UNIT.CITY then
                    --target_tile.sprite = TILE.GRASS
                elseif x < BIOME_DIST_UNIT.VOID then
                    --target_tile.sprite = TILE.GRASS
                else
                    --target_tile.sprite = TILE.GRASS
                end
            end
            
        end
    end


    return chunk
end

function generateCityChunk(x_offset, y_offset)
    local chunk = {x = x_offset, y = y_offset,  tiles = {}, surface_tiles = {}}

        -- Fill all cells with NONE
    for x = x_offset, x_offset+15 do
        chunk.tiles[x] = {}
        for y = y_offset, y_offset+15 do -- this creates 31 tiles FYI   
            chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.NONE}
        end
    end

    local buildingHeight = 10 -- higher is lower..
    local buildingLength = 0
    local buildingHeightVariance = 0
    local signal = false
    for x = x_offset, x_offset+15 do

        if buildingLength == 4 then
            signal = not(signal)
            buildingLength = 0
        end
        buildingLength += 1 

        buildingHeightVariance = flr(rnd(4))-2

        for y = y_offset, y_offset+15 do
        

            if signal and y == buildingHeight + buildingHeightVariance then
                chunk.tiles[x][y].sprite = TILE.ORELAND_3
            elseif signal and y > buildingHeight-1 + buildingHeightVariance then
                chunk.tiles[x][y].sprite = TILE.ORELAND_1
            end

            if y > 14 then
                chunk.tiles[x][y].sprite = TILE.ORELAND_2
            end
            --[[
                if y < sin( ((x-1) / 8)) + 13 and y > sin( ((x-5) / 8)) + 2  then
                    chunk.tiles[x][y].sprite = TILE.NONE
                end
            ]]     
            
        end
    end


    


    return chunk

end

function generateVoidChunk(x_offset, y_offset, startingSize)
    local chunk = {x = x_offset, y = y_offset,  tiles = {}, surface_tiles = {}}

    -- Fill all cells with NONE
    for x = x_offset, x_offset+15 do
        chunk.tiles[x] = {}
        for y = y_offset, y_offset+15 do -- this creates 31 tiles FYI   
            chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.NONE}
        end
    end

    local asteroidCount = 3
    local next_asteroid_x = 0
    local asteroidSize = startingSize

    for i = 1, asteroidCount do

        local x = next_asteroid_x
        next_asteroid_x = next_asteroid_x + 4 + flr(rnd(2))

        local y = flr(rnd(8)) + 7

        local rnd_offset_x = flr(rnd(2))
        local rnd_offset_y = flr(rnd(2))
        createAsteroid(asteroidSize, x_offset + x + rnd_offset_x , y_offset + y + rnd_offset_y, x_offset, y_offset, chunk.tiles)
       
        if i & 2 == 0 then
            asteroidSize = max(3, asteroidSize - 1)
        end

    end

    return chunk

end

function generateCloudChunk(x_offset, y_offset)
    local chunk = {x = x_offset, y = y_offset,  tiles = {}, surface_tiles = {}}

    -- Fill all cells with NONE
    for x = x_offset, x_offset+15 do
        chunk.tiles[x] = {}
        for y = y_offset, y_offset+15 do -- this creates 31 tiles FYI   
            chunk.tiles[x][y] = {x = x, y = y, sprite = TILE.CLOUD_1}
        end
    end

    for x = x_offset, x_offset+15 do
        for y = y_offset, y_offset+15 do      
            if y < sin( ((x-1) / 8)) + 13 and y > sin( ((x-5) / 8)) + 2  then
                chunk.tiles[x][y].sprite = TILE.NONE
            end
            
        end
    end


    


    return chunk

end

function paintCircle(center_x,center_y, x_offset, y_offset, tiles)

    -- clamp center values inside chunk
    center_x = max(min(center_x, x_offset + 15), x_offset+1)
    center_y = max(min(center_y, y_offset + 15), y_offset+1)

    tiles[center_x][center_y].sprite = TILE.GROUND


    if center_x > x_offset and center_x < x_offset + 16 and
    center_y > y_offset and center_y < y_offset + 16
    then
        
    end

    if center_x + 1 < x_offset + 16 then
        --tiles[center_x + 1][center_y].sprite = TILE.GROUND
    end

    if center_x - 1 > x_offset then
        --tiles[center_x - 1][center_y].sprite = TILE.GROUND
    end

    if center_y + 1 < y_offset + 16 then
        --tiles[center_x][center_y + 1].sprite = TILE.GROUND
    end

    if center_y - 1 > y_offset then
       -- tiles[center_x][center_y - 1].sprite = TILE.GROUND
    end

end

function createAsteroid(size, origin_x, origin_y, x_offset, y_offset, tiles)

    origin_x = min(origin_x, (x_offset + 14) - size)
    origin_y = min(origin_y, (y_offset + 14) - size+1)

    local asteroidPoly = generateSimplePolygon(origin_x * 8, origin_y * 8, size * 8, size * 8)
    add(debug_poly_render, asteroidPoly)

    local tileCount = 0

    for x = 0, size-1, 1 do
        for y = 0, size-1, 1 do

            local tile_x = origin_x + x
            local tile_y = origin_y + y

            local inPolyCount = 0

            if isInsidePolygon(asteroidPoly, tile_x * 8, tile_y * 8) then
                inPolyCount += 1
            end

            if isInsidePolygon(asteroidPoly, (tile_x + 1) * 8, tile_y * 8) then
                inPolyCount += 1
            end

            if isInsidePolygon(asteroidPoly, (tile_x + 1) * 8, (tile_y + 1) * 8) then
                inPolyCount += 1
            end

            if isInsidePolygon(asteroidPoly, tile_x * 8, (tile_y + 1)  * 8) then
                inPolyCount += 1
            end

            if inPolyCount >= 2 then
                tiles[tile_x][tile_y].sprite = TILE.GROUND
                tileCount += 1
            end

        end
    end


    if tileCount == 0 then
       tiles[origin_x][origin_y].sprite = TILE.GROUND
    end



end

function set_biome_distances()

    local cumulative_dist = 0

    BIOME_DIST_UNIT.GRASS = biome_length + cumulative_dist
    cumulative_dist = BIOME_DIST_UNIT.GRASS
    BIOME_DIST_UNIT.DESERT = biome_length + cumulative_dist
    cumulative_dist = BIOME_DIST_UNIT.DESERT
    BIOME_DIST_UNIT.MOUNTAIN = biome_length + cumulative_dist
    cumulative_dist = BIOME_DIST_UNIT.MOUNTAIN
    BIOME_DIST_UNIT.SNOW = biome_length + cumulative_dist
    cumulative_dist = BIOME_DIST_UNIT.SNOW
    BIOME_DIST_UNIT.CITY = biome_length + cumulative_dist
    cumulative_dist = BIOME_DIST_UNIT.CITY
    BIOME_DIST_UNIT.VOID = biome_length + cumulative_dist
    cumulative_dist = BIOME_DIST_UNIT.VOID

    map_x_size = BIOME_DIST_UNIT.VOID
end

function get_cell_height_at_(x)

    if x <= BIOME_DIST_UNIT.GRASS then
        return biome_grass_height_at_(x)
    elseif x <= BIOME_DIST_UNIT.DESERT then
        return biome_desert_height_at_(x)
    elseif x <= BIOME_DIST_UNIT.MOUNTAIN then
        return biome_mountain_height_at_(x)
    elseif x <= BIOME_DIST_UNIT.SNOW then
        return biome_grass_height_at_(x)
    elseif x <= BIOME_DIST_UNIT.CITY then
        return biome_oreland_height_at_(x)
    elseif x <= BIOME_DIST_UNIT.VOID then
        return biome_hell_height_at_(x)
    else
        return biome_grass_height_at_(x)
    end

end

function biome_grass_height_at_(x) -- lower ground level
    return sin( ((x-1) / 16))
end

function biome_desert_height_at_(x)
    return sin( ((x-1) / 8))
end

function biome_mountain_height_at_(x) -- raise ground level?
    return sin( ((x-1) / 16)) + 4 * sin( ((x-1) / 16) * 1.5)
end

function biome_oreland_height_at_(x)
    return sin( ((x-1) / 16)) + 2 * sin( ((x-1) / 20) * 3.5)
end

function biome_hell_height_at_(x)
    return sin( ((x-1) / 8)) + 1.2 * sin( ((x-1) / 16) * 6.5)
end


function draw_holes()
    local hole_width = 3

    -- draw holes at the end of each biome
    for i = biome_length-hole_width, map_x_size-biome_length-hole_width, biome_length do
        for x = i, i + hole_width - 1, 1 do
            for y = 0, map_y_size - 1 do
                chunks[x][y].tile = TILE.NONE   
            end
        end
    end


    --[[
     -- every X tiles.
    local hole_distance = 5
    local last_hole_pos = 0
    for i = 0, (map_x_size-1)-hole_width, 1 do
        if i > last_hole_pos + hole_width + hole_distance then

            for x = i, i + hole_width, 1 do
                for y = 0, map_y_size-1, 1 do
                    printh( x .. " " .. y)
                    levelgen[x][y].tile = TILE.NONE   
                end
                
            end

            last_hole_pos = i
            i += hole_width

        end
    end
    ]]

end

function get_tile(x, y)
    if x < 0 or x >= map_x_size or y < 0 or y >= map_y_size then
        --printh("(" .. x .. "," .. y .. ") tile index is out of bounds")
        -- for some reason, get_tile calls in out of bounds (x 298-303) spike when player reaches the end.
        return {tile = -1}
    else

        local chunk = {tile = -1}

        x = flr(x)
        y = flr(y)

        -- 1. Identify which chunk to search for
        for c in all(chunks) do
            if x >= c.x_offset_unit and x < c.x_offset_unit + chunk_x_size then
                chunk = c
                break;
            end
        end

        if chunk.tile == -1 then
            --printh("(" .. x .. "," .. y .. ") tile not found")
            return chunk
        end

        -- 2. Return tile from the correct chunk
        return chunk.tiles[x][y]
    end
end

function get_tile_at_pos(x, y)   
    return get_tile(flr(x / 8) , flr(y / 8))
end

function get_surface_tile_at_pos(x_pos)
    local x = x_pos / 8
    for y = 1, map_y_size-1 do 

        local above_tile = get_tile(x,y-1)
        local target_tile = get_tile(x,y)

        if above_tile.tile == TILE.NONE and target_tile.tile ~= TILE.NONE then
            return target_tile
        end
        
    end

end

function check_collision(new_x, new_y, x,y, hit_wall_callback)
    -- convert world positions to grid positions
    local new_x_unit = new_x / 8
    local new_y_unit = new_y / 8
    local x_unit = x / 8
    local y_unit = y / 8
    local onGround = false
    local hit_wall = false

    --printh(new_x)
    -- check X axis collisions
    if get_tile(new_x_unit, y_unit).tile ~= TILE.NONE or get_tile(new_x_unit, y_unit + 0.999).tile ~= TILE.NONE then
        new_x_unit = flr(new_x_unit) + 1
        hit_wall = true
    elseif get_tile(new_x_unit + 1, y_unit).tile ~= TILE.NONE or get_tile(new_x_unit + 1, y_unit + 0.999).tile ~= TILE.NONE then
        new_x_unit = flr(new_x_unit)
        hit_wall = true
    end

    -- check Y axis collisions
    if get_tile(x_unit, new_y_unit).tile ~= TILE.NONE or get_tile(x_unit+0.999, new_y_unit).tile ~= TILE.NONE then
        new_y_unit = flr(new_y_unit) + 1
    elseif get_tile(x_unit, new_y_unit + 1).tile ~= TILE.NONE or get_tile(x_unit+0.999, new_y_unit + 1).tile ~= TILE.NONE then
        new_y_unit = flr(new_y_unit)
        onGround = true
    end

    -- convert grid positions to world positions
    new_x = new_x_unit * 8
    new_y = new_y_unit * 8

    return {x = new_x, y = new_y, onGround = onGround, hit_wall = hit_wall} -- this is returning nil for some reason
end

function get_biome_at_unit(x)
    --x = x / 8

    if x < BIOME_DIST_UNIT.GRASS then
        return "GRASS"
    elseif x < BIOME_DIST_UNIT.DESERT then
        return "DESERT"
    elseif x < BIOME_DIST_UNIT.MOUNTAIN then
        return "MOUNTAIN"
    elseif x < BIOME_DIST_UNIT.SNOW then
        return "SNOW"
    elseif x < BIOME_DIST_UNIT.CITY then
        return "ORELAND"
    elseif x < BIOME_DIST_UNIT.VOID then
        return "HELL"
    else
        return "KINGDOM"
    end  
end

function debug_draw_asteroid_polys()

    for index, poly in ipairs(debug_poly_render) do
        drawPolygon(poly)
        
    end

end