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
    --loadChunk()

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

-- Note: using distance to check biome won't work for secret areas
function loadChunk()
    local new_chunk = {}
    
    if x_offset >= BIOME_DIST_UNIT.VOID then
        new_chunk = generateCloudChunk(x_offset, y_offset)

        if x_offset == 384 then
            initKing()
            enableUFO(376 * 8, 40)
            finalBossEnabled = true
        end

    elseif x_offset >= BIOME_DIST_UNIT.CITY then
        new_chunk = generateVoidChunk(x_offset,y_offset, startingAsteroidSize)
        startingAsteroidSize -= 2

    elseif x_offset >= BIOME_DIST_UNIT.SNOW then
        new_chunk = generateCityChunk(x_offset, y_offset)

        if x_offset == BIOME_DIST_UNIT.SNOW + 16 then
            initVulture()
            enableUFO((BIOME_DIST_UNIT.SNOW + 16) * 8, 8)
        end


    else
        new_chunk = generateChunk(x_offset)

        if new_chunk.x == chunk_progress_x * 16 and gameState == gstate.playerSelect then

        else 
            
            local zombie_spawn_point = getRndSurfaceTile(new_chunk.surface_tiles)
            enableActor(zombies, -1, zombie_spawn_point.x * 8, (zombie_spawn_point.y-1) * 8)
        end

        if x_offset == 64 then
            printh(#ufos)
            local ufo = enableUFO(64 * 8, 2 * 8)
            printh(ufo.xpos)
        end

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
            printh("(" .. x .. "," .. y .. ") tile not found")
            return chunk
        end

        -- 2. Return tile from the correct chunk
        return chunk.tiles[x][y]
    end
end

function getSurfaceTileAtXPos(x_pos)

    local chunk = {tile = -1}

    local x = flr(x_pos/8)

    -- 1. Identify which chunk to search for
    --printh(#loaded_chunks)
    for c in all(loaded_chunks) do
        if x >= c.x and x < c.x + chunk_x_size then
            chunk = c
            break;
        end
    end

    local st = chunk.surface_tiles
    --printh(st)
    for index, surface_tile in ipairs(st) do
        --printh(surface_tile.x .. " looking for " .. x)
        if surface_tile.x == x then
            return surface_tile
        end
    end

end


function checkTileCollision(new_x, new_y, x,y, is_player)
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

    -- check Y axis collisions
    local tile_y_1 = getTile(x_unit, new_y_unit)
    local tile_y_2 = getTile(x_unit + 0.999, new_y_unit)
    local tile_y_3 = getTile(x_unit, new_y_unit + 1)
    local tile_y_4 = getTile(x_unit + 0.999, new_y_unit + 1)

    local cornerCount = 0

    -- X
    if (tile_x_1 ~= nil and tile_x_2 ~= nil) and (tile_x_1.sprite ~= TILE.NONE or tile_x_2.sprite ~= TILE.NONE) then
        if is_player == false then -- HACK, for players this stops collisions in beyond the grid in the -y direction
            new_x_unit = flr(new_x_unit) + 1 
        end 
        hit_wall = true
    elseif (tile_x_3 ~= nil and tile_x_4 ~= nil) and (tile_x_3.sprite ~= TILE.NONE or tile_x_4.sprite ~= TILE.NONE) then
        new_x_unit = flr(new_x_unit)
        cornerCount += 1
        hit_wall = true
    end

    -- Y
    if (tile_y_1 ~= nil and tile_y_2 ~= nil) and (tile_y_1.sprite ~= TILE.NONE or tile_y_2.sprite ~= TILE.NONE) then
        if new_y > 0 or is_player == false then -- HACK, this stops collisions in beyond the grid in the -y direction
            new_y_unit = flr(new_y_unit) + 1
        end
        cornerCount += 1
    elseif (tile_y_3 ~= nil and tile_y_4 ~= nil) and (tile_y_3.sprite ~= TILE.NONE or tile_y_4.sprite ~= TILE.NONE) then
        new_y_unit = flr(new_y_unit)
        
        onGround = true
    end

    if cornerCount == 2 then -- yay this fixes the corner bug
        if new_y > y then -- going down
            new_y_unit = new_y_unit - 1
        end

    end

    -- NOTE on HACK: it seems that ignoring tile collisions in the -Y and -X direction allows the player to jump beyond the 
    -- camera position in the -Y direction. I had to add a condition to check if the y position is greater than zero 
    -- so that players would collide with the cloud kingdom roof. If I decide to modify generation to have different heights,
    -- then this check will need to account for that.

    -- convert grid positions to world positions
    new_x = new_x_unit * 8
    new_y = new_y_unit * 8

    return {x = new_x, y = new_y, onGround = onGround, hit_wall = hit_wall} -- this is returning nil for some reason
end