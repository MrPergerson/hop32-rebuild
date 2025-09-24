local loaded_chunks = {}

local chunk_x_size = 16
local chunk_y_size = 16
local chunk_pos_x_size = chunk_x_size * 8
local chunk_pos_y_size = chunk_y_size * 8

local x_offset = 0
local y_offset = 0
local land_progress = 0

local TILE = {
    NONE = 0,
    GRASS = 2,
    GROUND = 3,
    WALL = 4,
    SAND_1 = 93,
    SAND_2 = 94,
    SAND_3 = 95,
    MOUNTAIN_1 = 96,
    MOUNTAIN_2 = 97,
    MOUNTAIN_3 = 99,
    SNOW_1 = 99,
    SNOW_2 = 100,
    SNOW_3 = 101,
    ORELAND_1 = 102,
    ORELAND_2 = 103,
    ORELAND_3 = 104,
    HELL_1 = 105,
    HELL_2 = 106,
    HELL_3 = 107
}

function initLevelLoad(chunk_progress_x)

    loaded_chunks = {}
    
    x_offset = chunk_progress_x * 16 --initial
    y_offset = 0

    --add(loaded_chunks, loadChunk(1, 1, chunk_x_offset, LANDS))
    --chunk_x_offset += chunk_x_size
    --add(loaded_chunks, loadChunk(1, 2, chunk_x_offset, LANDS))
    --chunk_x_offset += chunk_x_size
    --add(loaded_chunks, loadChunk(0, 0, chunk_x_offset, LANDS))
    --chunk_x_offset += 1 -- right?

    --add(loaded_chunks, generateChunk(chunk_x_offset))
    add(loaded_chunks, generateVoidChunk(x_offset,y_offset))
    --add(loaded_chunks, generateCloudChunk(x_offset, y_offset))
    x_offset += chunk_x_size
    --y_offset -= 2
    --setCameraYPos(y_offset * 8)
    --add(loaded_chunks, generateChunk(chunk_x_offset))
    add(loaded_chunks, generateVoidChunk(x_offset,y_offset))
    --add(loaded_chunks, generateCloudChunk(x_offset, y_offset))

end

function updateChunks(chunk_progress_x)
    --printh(chunk_progress_x)

        x_offset += chunk_x_size
        -- if end
        --y_offset -= 2
        --setCameraYPos(y_offset * 8)
        local new_chunk = {}
        if current_area == AREA.CLOUD_KINGDOM then
            new_chunk = generateCloudChunk(x_offset, y_offset)
        else
            new_chunk = generateVoidChunk(x_offset, y_offset)
        end
        --local new_chunk = generateVoidChunk(x_offset, y_offset)
        --local new_chunk = generateChunk(chunk_x_offset)
        
        
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

-- no longer usable
function loadChunk(index, chunk_index, x_offset, source)

    local chunk = {x = x_offset, y = 0, tiles = {}, surface_tiles = {}}
    chunk.surface_tiles = source[index].chunks[chunk_index].surface_tiles
    local surface_tile_index = 0
    
    for x = x_offset, x_offset + chunk_x_size-1 do 
        chunk.tiles[x] = {}
        
        local surface_tile = chunk.surface_tiles[surface_tile_index]
        surface_tile_index += 1

        
            for y = 0, chunk_y_size-1 do
                
                local sprite = TILE.NONE
                if surface_tile then
                    if y > surface_tile.y then
                        sprite = TILE.GROUND                        
                    end
                end

                chunk.tiles[x][y] = {x = x * 8, y = y * 8, sprite = sprite}
                
            end
       
    end

    return chunk
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
    if getTile(new_x_unit, y_unit).sprite ~= TILE.NONE or getTile(new_x_unit, y_unit + 0.999).sprite ~= TILE.NONE then
        new_x_unit = flr(new_x_unit) + 1
        hit_wall = true
    elseif getTile(new_x_unit + 1, y_unit).sprite ~= TILE.NONE or getTile(new_x_unit + 1, y_unit + 0.999).sprite ~= TILE.NONE then
        new_x_unit = flr(new_x_unit)
        hit_wall = true
    end

    -- check Y axis collisions
    if getTile(x_unit, new_y_unit).sprite ~= TILE.NONE or getTile(x_unit+0.999, new_y_unit).sprite ~= TILE.NONE then
        new_y_unit = flr(new_y_unit) + 1
    elseif getTile(x_unit, new_y_unit + 1).sprite ~= TILE.NONE or getTile(x_unit+0.999, new_y_unit + 1).sprite ~= TILE.NONE then
        new_y_unit = flr(new_y_unit)
        onGround = true
    end

    -- convert grid positions to world positions
    new_x = new_x_unit * 8
    new_y = new_y_unit * 8

    return {x = new_x, y = new_y, onGround = onGround, hit_wall = hit_wall} -- this is returning nil for some reason
end