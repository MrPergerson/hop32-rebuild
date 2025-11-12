local loaded_chunks = {}

local chunk_x_size = 16
local chunk_y_size = 16
local chunk_pos_x_size = chunk_x_size * 8
local chunk_pos_y_size = chunk_y_size * 8

local x_offset = 0
local y_offset = 0
local land_progress = 0

local startingAsteroidSize = 8

function initLevelLoad(chunk_progress_x)

    loaded_chunks = {}

    startingAsteroidSize = 8
    debug_poly_render = {}
    
    x_offset = chunk_progress_x * 16 --initial
    y_offset = 0

    loadChunk()
    loadChunk()
    loadChunk()

end

function updateChunks(chunk_progress_x)
    --printh(chunk_progress_x)        
        local new_chunk = loadChunk(x_offset, 0)
        
        add(loaded_chunks, new_chunk)
        new_chunk_threshold += 1

        local chunk_to_remove = new_chunk
        for chunk in all(loaded_chunks) do
            if chunk.x < chunk_to_remove.x then
                chunk_to_remove = chunk
            end
        end

        del(loaded_chunks, chunk_to_remove)
        -- call back?

    
end

-- using distance to check biome won't work for secret areas
function loadChunk()
    --printh(x_offset .. " >= " .. BIOME_DIST_UNIT.HELL)
    local new_chunk = {}
    -- if current_area == AREA.CLOUD_KINGDOM then
    if x_offset >= BIOME_DIST_UNIT.HELL + 80 then -- HACK to increase void area
                                                -- stop with the auto distance and set it manually
                                                -- whoops I need to fix the done length now
        new_chunk = generateCloudChunk(x_offset, y_offset)
    elseif x_offset >= BIOME_DIST_UNIT.ORELAND then
        new_chunk = generateVoidChunk(x_offset,y_offset, startingAsteroidSize)
        startingAsteroidSize -= 2
    elseif x_offset >= BIOME_DIST_UNIT.SNOW then
        new_chunk = generateCityChunk(x_offset, y_offset)
    else
        new_chunk = generateChunk(x_offset)
    end
    
    add(loaded_chunks, new_chunk)
    x_offset += chunk_x_size

    --y_offset -= 2
    --setCameraYPos(y_offset * 8)

    return new_chunk
end


function drawChunks()
    for chunk in all(loaded_chunks) do
        for x = chunk.x, chunk.x + chunk_x_size-1 do
            for y = chunk.y, chunk.y + chunk_y_size-1 do     

                local tile = chunk.tiles[x][y]
                if tile.sprite > 0 then -- no error was returned
                    spr(tile.sprite, tile.x * 8, tile.y * 8)
                    --Debug
                    if (debug_mode) then
                        rect(tile.x * 8, tile.y * 8, tile.x * 8 + 8, tile.y * 8 + 8, 9)                      
                    end
                else
                    if (debug_mode) then
                        rect(tile.x * 8, tile.y * 8, tile.x * 8 + 8, tile.y * 8 + 8, 2)
                    end
                end
            end
        end
    end

end

function getTile(x,y)
    local rearChunk = loaded_chunks[1]
    local forwardChunk = loaded_chunks[#loaded_chunks]

    if x < rearChunk.x or x >= forwardChunk.x + chunk_x_size or 
    y < rearChunk.y or y >= rearChunk.y + map_y_size then
        --printh("(" .. x .. "," .. y .. ") tile index is out of bounds")
        -- for some reason, get_tile calls in out of bounds (x 298-303) spike when player reaches the end.
        return {tile = -1}
    else

        local chunk = {tile = -1}

        x = flr(x)
        y = flr(y)

        -- 1. Identify which chunk to search for
        for c in all(loaded_chunks) do
            if x >= c.x and x < c.x + chunk_x_size then
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

function checkTileCollision(new_x, new_y, x,y)
    -- convert world positions to grid positions
    local new_x_unit = new_x / 8
    local new_y_unit = new_y / 8
    local x_unit = x / 8
    local y_unit = y / 8
    local onGround = false
    local hit_wall = false

    --printh(new_x)
    -- check X axis collisions
    local tile_x_1 = getTile(new_x_unit, y_unit)
    local tile_x_2 = getTile(new_x_unit, y_unit + 0.999)
    local tile_x_3 = getTile(new_x_unit + 1, y_unit)
    local tile_x_4 = getTile(new_x_unit + 1, y_unit + 0.999)

    if (tile_x_1 ~= nil and tile_x_2 ~= nil) and (tile_x_1.sprite ~= TILE.NONE or tile_x_2.sprite ~= TILE.NONE) then
    --if getTile(new_x_unit, y_unit).sprite ~= TILE.NONE or getTile(new_x_unit, y_unit + 0.999).sprite ~= TILE.NONE then
        new_x_unit = flr(new_x_unit) + 1
        hit_wall = true
    elseif (tile_x_3 ~= nil and tile_x_4 ~= nil) and (tile_x_3.sprite ~= TILE.NONE or tile_x_4.sprite ~= TILE.NONE) then
    --elseif getTile(new_x_unit + 1, y_unit).sprite ~= TILE.NONE or getTile(new_x_unit + 1, y_unit + 0.999).sprite ~= TILE.NONE then
        new_x_unit = flr(new_x_unit)
        hit_wall = true
    end

    -- check Y axis collisions
    local tile_y_1 = getTile(x_unit, new_y_unit)
    local tile_y_2 = getTile(x_unit + 0.999, new_y_unit)
    local tile_y_3 = getTile(x_unit, new_y_unit + 1)
    local tile_y_4 = getTile(x_unit + 0.999, new_y_unit + 1)

    if (tile_y_1 ~= nil and tile_y_2 ~= nil) and (tile_y_1.sprite ~= TILE.NONE or tile_y_2.sprite ~= TILE.NONE) then
    --if getTile(x_unit, new_y_unit).sprite ~= TILE.NONE or getTile(x_unit+0.999, new_y_unit).sprite ~= TILE.NONE then
        new_y_unit = flr(new_y_unit) + 1
    elseif (tile_y_3 ~= nil and tile_y_4 ~= nil) and (tile_y_3.sprite ~= TILE.NONE or tile_y_4.sprite ~= TILE.NONE) then
    --elseif getTile(x_unit, new_y_unit + 1).sprite ~= TILE.NONE or getTile(x_unit+0.999, new_y_unit + 1).sprite ~= TILE.NONE then
        new_y_unit = flr(new_y_unit)
        onGround = true
    end

    -- convert grid positions to world positions
    new_x = new_x_unit * 8
    new_y = new_y_unit * 8

    return {x = new_x, y = new_y, onGround = onGround, hit_wall = hit_wall} -- this is returning nil for some reason
end