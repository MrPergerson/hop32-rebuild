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
local rnd_terrain_seed = 0

-- tile ids: air = 0; grass = 2; ground = 3; wall = 4; 

debug_poly_render = {}
groundlevel = 11 -- relative to tiles, not pixels

function initProceduralGen()
    --set_biome_distances()
    map_x_size = BIOME_DIST_UNIT.VOID
    rnd_terrain_seed = flr(rnd(128))
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

    for x = x_offset, x_offset+chunk_x_size-1 do
        for y = 0, map_y_size-1 do      
            local h = get_cell_height_at_(x) + TERRAIN_Y_OFFSET -- Normalize x to [0, 1] (remember to explain why dividing by chunk_x_size fixes sin output)
            --h = 2 * sin( ((x-1) / chunk_x_size) * 2)
            if y - groundlevel < h then
                chunk.tiles[x][y].sprite = TILE.NONE
            end
            
        end
    end

    if x_offset == chunk_progress_x * 16 and gameState == gstate.playerSelect then
            -- do nothing 
    else 
        -- draw a holes randomly
        -- don't draw holes in the last two chunks
        if x_offset > 0 and x_offset < (map_x_size-biome_length) and rnd(1) >= 1-draw_hole_chance then
            local random_x_pos = flr(rnd(chunk_x_size-hole_width-1))
            local hole_start = x_offset + random_x_pos + 1

            for x = hole_start , hole_start + hole_width, 1 do
                for y = 0, map_y_size-1, 1 do
                    chunk.tiles[x][y].sprite = TILE.NONE   
                end
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
                    --do nothing
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
    local signal = true

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
            
        end
    end

    for x = x_offset, x_offset+15 do
        for y = y_offset+1, y_offset+15 do

            local above_tile = chunk.tiles[x][y-1]
            local target_tile = chunk.tiles[x][y]

            if above_tile.sprite == TILE.NONE and target_tile.sprite ~= TILE.NONE then
                add(chunk.surface_tiles, target_tile)
            end
            
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

    getSurfaceTiles(chunk, x_offset, y_offset, 88)

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


    getSurfaceTiles(chunk, x_offset, y_offset, -1)


    return chunk

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
                tiles[tile_x][tile_y].sprite = 88
                tileCount += 1
            end

        end
    end


    if tileCount == 0 then
       tiles[origin_x][origin_y].sprite = 88

       if origin_x + 1 == x_offset + 15 + size - 1 then
        tiles[origin_x-1][origin_y].sprite = 88
       else
        tiles[origin_x+1][origin_y].sprite = 88
       end
       
       
       tiles[origin_x][origin_y+1].sprite = 88

    end



end

function get_cell_height_at_(x)

    if x <= BIOME_DIST_UNIT.GRASS then
        return sin( ((x-1 + rnd_terrain_seed) / 16)) 
    elseif x <= BIOME_DIST_UNIT.DESERT then
        return sin( ((x-1 + rnd_terrain_seed) / 8))
    elseif x <= BIOME_DIST_UNIT.MOUNTAIN then
        return sin( ((x-1 + rnd_terrain_seed) / 16)) + 4 * sin( ((x-1 + rnd_terrain_seed) / 16) * 1.5)
    elseif x <= BIOME_DIST_UNIT.SNOW then
        return sin( ((x-1 + rnd_terrain_seed) / 16)) 
    else
        return sin( ((x-1 + rnd_terrain_seed) / 16)) 
    end

end

function getSurfaceTiles(chunk, x_offset, y_offset, surface_sprite)
    -- get all surface tiles. Update surface sprites if needed
    for x = x_offset, x_offset+15 do
        for y = y_offset+1, y_offset+15 do

            local above_tile = chunk.tiles[x][y-1]
            local target_tile = chunk.tiles[x][y]

            if above_tile.sprite == TILE.NONE and target_tile.sprite ~= TILE.NONE then
                if surface_sprite > 0 then
                    target_tile.sprite = surface_sprite               
                end
                add(chunk.surface_tiles, target_tile)
            end
            
        end
    end
end

function getRndSurfaceTile(tiles)
    return tiles[flr(rnd(#tiles))+1]
end

function get_surface_tile_at_pos(x_pos)
    local x = flr(x_pos / 8)
    for y = 1, 15 do 

        local above_tile = getTile(x,y-1)
        local target_tile = getTile(x,y)

        --printh("get surface " + target_tile.tile)

        if above_tile.tile == TILE.NONE and target_tile.tile ~= TILE.NONE then
            return target_tile
        end
        
    end

end

function debug_draw_asteroid_polys()

    for index, poly in ipairs(debug_poly_render) do
        drawPolygon(poly)
        
    end

end