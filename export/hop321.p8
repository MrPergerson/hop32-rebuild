pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- === globalvars.lua ===
debug_mode = false
debug_fast_travel = false
debug_player_cannon = false
debug_camera_x = 0 --??
debug_camera_y = 0
keyboard_input = 1 -- 1 or 0
gstate = {
    mainMenu = 0,
    playerSelect = 1,
    game = 2,
    gameover = 3,
    complete = 4
}
gameState = gstate.mainMenu

gMode = {
    tournament = 0,
    freeplay = 1
}
gameMode = gMode.tournament


--camera
camera_x = 0
camera_y = 0
old_camera_y_pos = 0
new_camera_y_pos = 0
new_camera_y_lerp_t = 1
new_camera_y_lerp_r = 0

function setCameraYPos(y_pos)
    old_camera_y_pos = camera_y
    new_camera_y_pos = y_pos
    new_camera_y_lerp_t = 0
end

-- timers
start_timer = 5.9
gamemode_timer = 0
score_timer = 15
gameover_menu_timer = 3

-- players
win_order = {}
playerCount = 0
disabledPlayerCount = 0
keys = {}
key_index = 1 -- used for sorting through keys

function setDisabledPlayerCount(value)

    if value > playerCount then
        value = playerCount
    end

    disabledPlayerCount = value
    --printh("disPC " .. disabledPlayerCount)
end

-- actors
ufos = {}
zombies = {}
players = {}
actors = {}

-- progress
AREA = {
    GREEN_LANDS = 0,
    CLOUD_KINGDOM = 10
}
current_area = -1
chunk_progress_x = 0
chunk_progress_y = 0
finalBossEnabled = false
final_boss_health = 4

TILE = {
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
    HELL_3 = 107,
    CLOUD_1 = 89,
    CLOUD_2 = 90,
    CLOUD_3 = 91,
    CLOUD_4 = 92,
    GLITCH = 88
}

BIOME_DIST_UNIT = {
    GRASS = 48,
    DESERT = 96,
    MOUNTAIN = 144,
    SNOW = 192,
    CITY = 240,
    VOID = 336,
    KINGDOM = 384 
}

-- SFX
sfx_hop = 23
sfx_player_death_to_zombie = 24
-- === helper.lua ===

-- Tables
function contains(table, value)
    for _, v in ipairs(table) do
        if v == value then 
            return true
        end
    end
    return false
end

Queue = {}
Queue.__index = Queue

-- Create a new queue
function Queue.new()
    local self = setmetatable({
        items = {}, -- The table to hold queue items
        head = 1,   -- Index of the first element
        tail = 1    -- Index of the next insertion point
    }, Queue)
    return self
end

function Queue:enqueue_unique(item)
    if not contains(self.items, item) then
        self.items[self.tail] = item
        self.tail = self.tail + 1
    end

end

-- Remove and return the item from the front of the queue
function Queue:dequeue()
    if self:isempty() then
        return nil
    end
    local item = self.items[self.head]
    self.items[self.head] = nil -- Remove reference
    self.head = self.head + 1
    return item
end

-- Check if the queue is empty
function Queue:isempty()
    return self.head == self.tail
end

function timer(interval)
    local last_time = t()  -- Track the last time the function was called
    
    return function()
        local current_time = t()
        -- Check if the interval has passed
        if current_time - last_time >= interval then
            last_time = current_time  -- Update the last time to current time
            return true  -- Indicate that the interval has elapsed
        end
        return false  -- Indicate that the interval has not elapsed
    end
end

function processTimer(time, dt)
    return max(time - dt, 0)
end

function lerp(a, b, t)
    return a + (b - a) * t
end


-- === vector.lua ===
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
-- === playerspriteindex.lua ===
player_sprite_index = { ["a"] = 33,
    ["b"] = 34, 
    ["c"] = 35, 
    ["d"] = 36,  
    ["e"] = 37,  
    ["f"] = 38,  
    ["g"] = 39,
    ["h"] = 40, 
    ["i"] = 41, 
    ["j"] = 42,
    ["k"] = 43,
    ["l"] = 44,
    ["m"] = 45,
    ["n"] = 46,
    ["o"] = 47,
    ["q"] = 48,
    ["r"] = 49,
    ["s"] = 50,
    ["t"] = 51,
    ["u"] = 52,
    ["v"] = 53,
    ["w"] = 54,
    ["x"] = 55,
    ["y"] = 56,
    ["z"] = 57,
    ["1"] = 58,
    ["2"] = 59,
    ["3"] = 60,
    ["4"] = 61,
    ["5"] = 62,
    ["6"] = 63,
    ["7"] = 64,
    ["8"] = 65,
}
-- === proceduralgen.lua ===
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
-- === chunkload.lua ===
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

        if x_offset == BIOME_DIST_UNIT.VOID + 16 then
            initKing()
            enableUFO(376 * 8, 40)
            finalBossEnabled = true
        end

    elseif x_offset >= BIOME_DIST_UNIT.CITY then
        new_chunk = generateVoidChunk(x_offset,y_offset, startingAsteroidSize)
        startingAsteroidSize -= 1

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
           -- printh(#ufos)
            local ufo = enableUFO(64 * 8, 2 * 8)
            --printh(ufo.xpos)
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
-- === actor.lua ===

-- player variables
local playerWonCount = 0
local maxPlayers = 32
local maxFallVelocity = 200

-- movement
local GRAVITY = 15  -- Gravity value
local SPEED = 5
local MIN_SPEED = 50
local MAX_SPEED = 65 -- camera speed is 15
local BOUNCE_FACTOR = -8  -- Factor to bounce back after collision
local jump_acceleration_x = 10
local jump_acceleration_y = 20
local min_jump_height = 1.5
local min_jump_distance = 1.5
local max_jump_height = 12
local max_jump_distance = 8
local jump_x_velocity = 4
local bounceCharge = 0 -- [0-1]
local maxChargeTime = 4 -- seconds
local HOVER_DOWN_SPEED = 30 -- UFO
local debug = false
local players_can_release_others = false

local d_last_time = 0 -- ??


function initActorPool(actor_count, actor_table, actor_data)
    for i = 1, actor_count, 1 do
        actor_table[i] = createActor(actor_data, i)
    end
end


function createActor(actor_data, id)
    local actor = {
        id=id, 
        type = actor_data.type,
        enabled = false,
        inputDisabled = false,
        xpos = -8, 
        ypos = -8, 
        startPosition = 0,
        boundsOffsetX = 0, 
        boundsOffsetY = 0, 
        vx = 0, 
        vy = 0, 
        move_dir = -1,
        width = actor_data.width,
        height = actor_data.height,
        boundsOffsetX = 0,
        boundsOffsetY = 0,
        onGround = false, 
        bounce_charge = 0,
        jump_height = min_jump_height,
        jump_distance = min_jump_distance,
        jump_gravity = 0,
        fall_gravity = 50,
        sprite = actor_data.sprite, 
        sprite2 = actor_data.sprite2,
        disabledCount = 0,
        ai_enabled = false,
        state = 1,
        totalTimeEnabled = 0,
        won = false,
        timer_1 = 0,
        capture_tracker = {},
        tracker_beam = {
            xpos = 0,
            ypos = 0,
            width = 16,
            height = 32,
            boundsOffsetX = 4,
            boundsOffsetY = 28
        }
    }
    --add(keys, keyInput)
    --playerCount = playerCount + 1
    return actor


end

function enableActor(actor_table, id, xpos, ypos)
    local actor = nil

    if id == -1 then -- if id -1, then enable first available inactive
        for key, a in pairs(actor_table) do
            if a.enabled == false then
                actor = a
                break;
            end
        end

        if actor == nil then
            printh("no more actors available")
            return
        end
    else
        actor = actor_table[id]

        if actor == nil then
            printh("can't find actor with id " .. id)
            return
        end
    end

    actor.enabled = true
    actor.ai_enabled = true
    actor.inputDisabled = false
    actor.state = 1
    actor.search_timer = 5 + flr(rnd(5)) -- ufo
    actor.ypos = ypos
    actor.xpos = xpos
    actor.bounce_charge = 0
    return actor
end

function disableActor(actor)
    actor.enabled = false
    actor.ai_enabled = false
    actor.disabledCount = actor.disabledCount + 1 -- player
    actor.totalTimeEnabled = actor.totalTimeEnabled + (time() - actor.totalTimeEnabled)  -- player
    --actor.xpos = -8
    --actor.ypos = -8
    actor.vx = 0
    actor.vy = 0
    --disabledPlayerCount = disabledPlayerCount + 1
    --queue_respawn_bird(player.key)
end


function getNewActorPosition(zombie, dt)
    if zombie.vy >= 0 then
        jump_acceleration_y = zombie.fall_gravity * 8
    else
        jump_acceleration_y = zombie.jump_gravity * 8

    end

    local zombie_new_x = zombie.xpos + zombie.vx * dt + 0.5 * jump_acceleration_x * dt * dt
    local zombie_new_y = zombie.ypos + zombie.vy * dt + 0.5 * jump_acceleration_y * dt * dt
    zombie.vx += jump_acceleration_x * dt
    zombie.vy += jump_acceleration_y * dt
    zombie.vy = min(zombie.vy, maxFallVelocity)

    return {xpos = zombie_new_x, ypos = zombie_new_y}
end

function bounceActor(actor) -- or actor?
    if actor.onGround and not(actor.won) then
        local jump_dist_p1 = actor.jump_distance * .6
        local jump_dist_p2 = actor.jump_distance * .4
        local jump_velocity = (-2 * actor.jump_height * jump_x_velocity) / jump_dist_p1
        actor.jump_gravity = (2 * actor.jump_height * jump_x_velocity * jump_x_velocity)  / (jump_dist_p1 * jump_dist_p1)
        actor.fall_gravity = (2 * actor.jump_height * jump_x_velocity * jump_x_velocity)  / (jump_dist_p2 * jump_dist_p2)
        actor.vx = jump_x_velocity  * 8
        actor.vy = jump_velocity  * 8
        actor.bounce_charge = 0
        sfx(sfx_hop)
        d_last_time = time()
    end
end

-- timer()
-- moveActorTo()
-- autoMoveLeftRight()
-- attractActors(thisActor)

function moveLeftRight(actor, speed)


    actor.vx = actor.move_dir * speed
    

    if actor.xpos < camera_x + 8 then
        actor.move_dir = abs(actor.move_dir)
        actor.xpos = camera_x + 8
    elseif actor.xpos > camera_x + 110 then
        actor.move_dir = -abs(actor.move_dir)
        actor.xpos = camera_x + 110
    end

end

function checkActorOutOfBounds(actor)
    if actor.xpos + 8 < camera_x - 16
    --or actor.xpos > camera_x + 200 -- we don't care about right bounds
    --or actor.ypos < camera_y  
    or actor.ypos > camera_y + 200 then
        --printh(actor.type .. " " .. actor.id .. " out of bounds")
        return true
    end

    return false
end

function drawActors(actor_table)
    for key, actor in pairs(actor_table) do
        --if actor.enabled then
            spr(actor.sprite, actor.xpos, actor.ypos)
        --end 
    end
end

-- actor collision
function check_object_collision(a, b)
    local a_edges = get_edges(a)
    local b_edges = get_edges(b)
    
    -- can we return the edge that collides?
    -- ufo would also have to be ignored after it bounces...

    return a_edges.left < b_edges.right and
           a_edges.right > b_edges.left and
           a_edges.top < b_edges.bottom and
           a_edges.bottom > b_edges.top
end

-- actor collision
function check_object_collision_on_top(a, b)
    local a_edges = get_edges(a)
    local b_edges = get_edges(b)
    

     -- super janky here. I should figure out how to properly do this
     return a_edges.bottom > b_edges.top and a.ypos < b.ypos and a.vy > 0
        
end

function get_edges(obj)
    -- Calculate reference point
    local center_x = obj.xpos + obj.boundsOffsetX
    local center_y = obj.ypos + obj.boundsOffsetY
    
    local half_w = obj.width / 2
    local half_h = obj.height / 2
    
    return {
        left = center_x - half_w,
        right = center_x + half_w,
        top = center_y - half_h,
        bottom = center_y + half_h
    }
end
-- === zombies.lua ===
local SPEED = 5

function initZombiePool(max_zombies)

    zombies = {}

    initActorPool(max_zombies, zombies, {type = "zombie", width = 1, height = 1, sprite = 108, sprite2 = 0})
    
end

function updateZombie(id, dt)

end

function update_zombies(dt)
    for index, zombie in ipairs(zombies) do

        if zombie.enabled and zombie.ai_enabled then

            if checkActorOutOfBounds(zombie) then
                disableActor(zombie)
                break
            end
        
            zombie.vx = zombie.move_dir * SPEED

            local zombie_new_pos = getNewActorPosition(zombie, dt)

            -- Check new positions for collisions
            local checked_position = checkTileCollision(zombie_new_pos.xpos, zombie_new_pos.ypos, zombie.xpos, zombie.ypos, false)
            zombie.onGround = checked_position.onGround

            if zombie.onGround then
                zombie.vx = 0
                zombie.vy = 0

                if checked_position.hit_wall then

                bounceActor(zombie)
                    -- if can't bounce then
                    --zombie.move_dir = -zombie.move_dir
                    --zombie.vx = 0
                end
            end


            -- Apply final position updates, if any
            zombie.xpos = checked_position.x
            --zombie.x = checked_position.x
            zombie.ypos = checked_position.y
                
        end
    end
end
-- === ufo.lua ===

local SPEED = 500
local MIN_SPEED = 50
local MAX_SPEED = 65 -- camera speed is 15
local HOVER_DOWN_SPEED = 30
local VULTURE_DOWN_SPEED = 10
local debug = false
local players_can_release_others = false

function initUFOPool()
    ufos = {}

    initActorPool(1, ufos, {type = "ufo", width = 8, height = 8, sprite = 109, sprite2 = 110})
end

function initKing()
    ufos = {}
    final_boss_health = max(playerCount, 3)
    initActorPool(1, ufos, {type = "king", width = 8, height = 8, sprite = 121, sprite2 = 122})
end

function initVulture()
    ufos = {}

    initActorPool(1, ufos, {type = "vulture", width = 8, height = 8, sprite = 125, sprite2 = 126})

    ufos[1].tracker_beam.width = 8
    ufos[1].tracker_beam.height = 8
    ufos[1].tracker_beam.boundsOffsetX = 4
    ufos[1].tracker_beam.boundsOffsetY = 6

end


function enableUFO(xpos, ypos)

    local ufo = enableActor(ufos, 1, xpos, ypos)
    ufo.boundsOffsetX = 4
    ufo.boundsOffsetY = 4

    resetUFO(ufo, xpos, ypos)

    return ufo

end


function updateUFO(dt)
    local ufo = ufos[1]

    if ufo.enabled and ufo.ai_enabled then
    printh("huh1")
        if ufo.state == 1 then
            
            moveLeftRight(ufo, 50)

            if ufo.type == "king" then
                if ufo.timer_1 == 0 then
                    enableActor(zombies, -1, ufo.xpos, ufo.ypos)
                    ufo.timer_1 = 5
                elseif final_boss_health <= 0 then
                    printh("huh")
                    ufo.state = 4
                end                
            else
                if ufo.timer_1 == 0 and ufo.xpos > camera_x + 70 then
                    ufo.vx = 0
                    ufo.state = 2
                end
            end

            ufo.timer_1 = processTimer(ufo.timer_1, dt)

        elseif ufo.state == 2 then

            if ufo.type == "ufo" then
                local tile = getSurfaceTileAtXPos(ufo.xpos)
                if (tile) then
                    if ufo.ypos < (tile.y - 4) * 8 then
                        ufo.vy = HOVER_DOWN_SPEED
                    else
                        ufo.vy = 0
                        ufo.state = 3
                        ufo.timer_1 = 5
                        sfx(3,1)
                    end
                else
                    ufo.state = 1
                end
            elseif ufo.type == "vulture" then

                moveLeftRight(ufo, 65)

                if ufo.ypos < (7) * 8 then
                    ufo.vy = VULTURE_DOWN_SPEED
                    ufo.tracker_beam.xpos = ufo.xpos
                    ufo.tracker_beam.ypos = ufo.ypos
                else
                    ufo.vy = -VULTURE_DOWN_SPEED
                    ufo.state = 4
                    hideCapturedActors(ufo)
                end

            end

        
        elseif ufo.state == 3 then
            ufo.timer_1 = processTimer(ufo.timer_1, dt)
            ufo.tracker_beam.xpos = ufo.xpos
            ufo.tracker_beam.ypos = ufo.ypos

            if ufo.timer_1 == 0 then
                hideCapturedActors(ufo)
                ufo.state = 4
            end                             
        elseif ufo.state == 4 then
            ufo.ypos -= MAX_SPEED * dt

            if ufo.ypos+8 <= camera_y-32 then 

                // set 0 to 1 for vulture to respawn
                if ufo.type == "vulture" and ufo.disabledCount < 0 then
                    ufo.disabledCount = ufo.disabledCount + 1
                    resetUFO(ufo, camera_x + 8, 8)
                else    
                    disableActor(ufo)
                    --printh("complete")
                end

                
            end                      
        end

        if ufo.type == "vulture" then
            for key, captured in pairs(ufo.capture_tracker) do
                captured.player.xpos = ufo.xpos + 4
                captured.player.ypos = ufo.ypos + 4
            end
        end
        
        if ufo.type == "ufo" then
           attractPlayers(dt)
        end

        local self_new_x = ufo.xpos + ufo.vx * dt
        local self_new_y = ufo.ypos + ufo.vy * dt
        
        ufo.xpos = self_new_x
        ufo.ypos = self_new_y

    end
    
end

function resetUFO(ufo, xpos, ypos)
    ufo.xpos = xpos
    ufo.ypos = ypos
    ufo.vx = 0
    ufo.vy = 0
    ufo.state = 1
    ufo.timer_1 = 5 + flr(rnd(5))
    ufo.capture_tracker = {}
end

function hideCapturedActors(ufo)
    for key, captured in pairs(ufo.capture_tracker) do
        captured.player.xpos = -8
        captured.player.ypos = -8
    end
end

function capturePlayer(player)

    local ufo = ufos[1]

    if ufo.capture_tracker[player.id] == nil then
       
        ufo.capture_tracker[player.id] = {
            player = player,
            t = 0
        }

        disableActor(player)
        setDisabledPlayerCount(disabledPlayerCount + 1)

    end

end

function attractPlayers(dt)

    local ufo = ufos[1]
    --local captured = ufo.capture_tracker[player.id] 

    for key, captured in pairs(ufo.capture_tracker) do
        captured.player.xpos = captured.player.xpos + (ufo.xpos - captured.player.xpos) * min(captured.t,.2)
        captured.player.ypos = captured.player.ypos + ((ufo.ypos+8) - captured.player.ypos) * min(captured.t,.2)

        captured.t += .1 * dt 

        if captured.t >= .2 then
            captured.player.xpos = -8
            captured.player.ypos = -8
        end
    end
end

function drawUFO()

    local ufo = ufos[1]

    if ufo and ufo.enabled then
        
        spr(ufo.sprite, ufo.xpos, ufo.ypos)

        if  ufo.state == 3 or ufo.state == 4 or (ufo.type == "vulture" and ufo.state == 2) then
            
            if ufo.type == "vulture" then
                spr(ufo.sprite2, ufo.xpos, ufo.ypos+4)
            else
                spr(ufo.sprite2, ufo.xpos, ufo.ypos+6)
            end

            if debug_mode then
                local beam_bounds = get_edges(ufo.tracker_beam)

                rect(beam_bounds.left, beam_bounds.top, beam_bounds.right, beam_bounds.bottom, 8)
            end
        end

        if ufo.type == "king" then
            drawHearts(final_boss_health)               
        end

        if debug_mode then

            local ufo_bounds = get_edges(ufo)

            rect(ufo_bounds.left, ufo_bounds.top, ufo_bounds.right, ufo_bounds.bottom, 8)
        end

    end

end

function drawHearts(heart_count)
    local heart_size = 10
    local rows = ceil((heart_count * 10) / 128)
    local hearts_left_to_draw = heart_count

    for i = 1, rows, 1 do

        local xpos = camera_x + 4
        local ypos = camera_y + 4 + (10 *(i-1))
        local offset = 10
        local hearts = 12

        if i == rows then
            hearts = hearts_left_to_draw
            --local xpos = camera_x
        end

        for j = 1, hearts, 1 do
            spr(8, xpos, ypos)
            hearts_left_to_draw -= 1
            xpos += offset
        end
        
    end


    
    -- local xpos = camera_x + 46
    -- local ypos = camera_y + 4
    -- local offset = 12
    -- rectfill(xpos - 2, ypos - 2, xpos - 2 + (offset * 3) , ypos + 9,0 )
    -- rect(xpos - 2, ypos - 2, xpos - 2 + (offset * 3) , ypos + 9, 8 )
    -- for i = 1, final_boss_health, 1 do
    --     spr(8, xpos, ypos)
    --     xpos += offset
    -- end
    
end
-- === respawnbirds.lua ===
-- perserve: Queue

local respawnQueue = Queue.new()
local activeBirdList = {}
respawnTimer = nil
--local flyPosition = camera_y + 24 need to make a global var file
local birdSpeed = .8

function init_respawn_birds()
    respawnQueue = Queue.new()
    activeBirdList = {}
    respawnTimer = nil
end

function queue_respawn_bird(player_key)
    respawnQueue:enqueue_unique({bird = {xpos = -8, ypos = -8, width = 8, height = 16, boundsOffsetX = 0, boundsOffsetY = 4, sprite = 1}, playerKey = player_key})
end

function addRespawnBird()
    local respawn = respawnQueue:dequeue()
    local player = players[respawn.playerKey]
    local bird = respawn.bird
    local initXPos = camera_x + 128
    local initYPos = camera_y + 20 + flr(rnd(10))
    bird.xpos = initXPos
    bird.ypos = initYPos
    player.xpos = initXPos
    player.ypos = initYPos + 8

    add(activeBirdList, respawn)

end

function update_respawns()

    if respawnTimer() and not(respawnQueue:isempty()) then
        addRespawnBird()
    end

    local returnToQueue = nil -- move all birds across the screen
    for _, respawn in ipairs(activeBirdList) do
        local newPos = respawn.bird.xpos - birdSpeed      
        respawn.bird.xpos = newPos
        local p = players[respawn.playerKey];
        p.xpos = newPos

        if newPos < camera_x - 8 then
           returnToQueue = respawn
        end
    end

    if not(returnToQueue == nil) then -- remove first bird to go out of bounds
        respawnQueue:enqueue_unique(returnToQueue)
        del(activeBirdList, returnToQueue)
    end

    

end

function draw_respawn_birds()
    for _, respawn in ipairs(activeBirdList) do
        spr(respawn.bird.sprite, respawn.bird.xpos, respawn.bird.ypos)
    end
end
-- === players.lua ===
poke(0x5F2D, 0x1) -- enable keyboard input

-- game variables
local GRAVITY = 15  -- Gravity value
local BOUNCE_FACTOR = -8  -- Factor to bounce back after collision
local playerWonCount = 0
local maxPlayers = 32
local maxFallVelocity = 200


local jump_acceleration_x = 10
local jump_acceleration_y = 20
local min_jump_height = 1.5
local min_jump_distance = 1.5
local max_jump_height = 12
local max_jump_distance = 8
local jump_x_velocity = 4
local bounceCharge = 0 -- [0-1]
local maxChargeTime = 4 -- seconds

local d_last_time = 0 -- ??

-- start screen variables
local posx = 0 -- not using this
local posy = 0
local xOffset = 0
local row = 1

function initPlayers()
    players = {}
    playerCount = 0
    playerWonCount = 0
    init_respawn_birds()
    setDisabledPlayerCount(0)
    posx = 0
    posy = 16
    xOffset = 0
    row = 1
    initActorPool(32, players, {type = "player", width = 8, height = 8, sprite = 0, sprite2 = 0})
end

function disablePlayer(player)
    queue_respawn_bird(player.id)
    disableActor(player)
    setDisabledPlayerCount(disabledPlayerCount + 1)
end

function enablePlayer(player)
    enableActor(players, player.key, player.xpos, player.ypos)
    setDisabledPlayerCount(disabledPlayerCount - 1)
end

function createPlayer(xpos, ypos, keyInput)
    local spr = nil

    if keyboard_input == 1 then
        local sprites = {32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63}
        spr = sprites[playerCount + 1]
    else
        spr = player_sprite_index[keyInput]
    end

    if spr == nil then
        return nil
    end

    playerCount = playerCount + 1
    local p = players[playerCount]
    p.id = keyInput
    p.sprite = spr
    p.xpos = xpos
    p.ypos = ypos
    players[playerCount] = nil
    players[keyInput] = p     

    enableActor(players, keyInput, xpos, posy)
    add(keys, keyInput)

    return p
end

function addPlayers(startingCamPos_x, startingCamPos_y, dt, ready)

    if ready and stat(30) then 
        local keyInput = stat(31)
        
        if not (keyInput == "\32") and not (keyInput == "\13") and not (keyInput == "\112") and playerCount < 32 then 

            if not players[keyInput] then
                start_timer = 5.9 -- plus .9 so the players see "5"

                local p = createPlayer(posx + startingCamPos_x, posy + startingCamPos_y, keyInput)    
                if p == nil then
                    return
                end
                p.startPosition = posy

                posx = posx + 9
                if (posx >= 100) then
                    
                    if xOffset >= 8 then
                        xOffset = 0
                    else
                        xOffset = xOffset + 2
                    end

                    posx = xOffset

                    posy = posy + 9
                end
            end
            
            players[keyInput].ypos = players[keyInput].startPosition - 2
        end
    
        -- exit player selection and start the game
        if (keyInput == "\32" and playerCount > 0) then            
            return true
        end  
        
    end

    -- bounce affect 
    for key, player in pairs(players) do
            if player.ypos < player.startPosition then
                player.ypos = min(player.startPosition, player.ypos + (20 * dt))
            end
    end

    return false
end

function update_players(game_progress_x, game_progress_y, dt)  
    for key, player in pairs(players) do
        if player.enabled and not(player.inputDisabled) then
            if not(player.vx == 0) then
                jump_acceleration_x = 0
            else
                jump_acceleration_x = 0 -- what's this for ?? 
            end

            local player_new_pos = getNewActorPosition(player, dt)

            -- Check new positions for collisions
            local checked_position = checkTileCollision(player_new_pos.xpos, player_new_pos.ypos, player.xpos, player.ypos, true)
            player.onGround = checked_position.onGround

            if player.onGround then
                player.vx = 0
                player.vy = 0

                player.bounce_charge = min(player.bounce_charge + dt , maxChargeTime)
                local t = player.bounce_charge / maxChargeTime
                player.jump_height = lerp(min_jump_height, max_jump_height, t)
                player.jump_distance = lerp(min_jump_distance, max_jump_distance, t)
            end

            -- Apply final position updates, if any
            player.xpos = min(checked_position.x, game_progress_x+128-player.width)
            player.ypos = checked_position.y

            if checkActorOutOfBounds(player) then
                disablePlayer(player)
                player.xpos = -8
                player.ypos = -8
                break;
            end

            -- Check for respawn bird collisions
            for _, respawn in ipairs(activeBirdList) do
                if check_object_collision(player, respawn.bird) then
                    enableActor(players, respawn.playerKey, player.xpos, player.ypos) -- update this
                    setDisabledPlayerCount(disabledPlayerCount - 1)
                    del(activeBirdList, respawn)
                    break;
                end
            end   
            
            -- Check for zombie collisions
            for _, zombie in ipairs(zombies) do
                if check_object_collision(player, zombie) then
                    disablePlayer(player)
                    player.xpos = -8
                    player.ypos = -8
                    sfx(sfx_player_death_to_zombie)
                    break;
                end
            end

            for _, ufo in ipairs(ufos) do
                if check_object_collision(player, ufo) then
                    --if colliding with top of ufo, bounce
                    if check_object_collision_on_top(player, ufo) then
                        sfx(sfx_hop)
                        if ufo.type == "king" then
                            final_boss_health -= 1
                        end
                        player.ypos = ufo.ypos-8  -- best way to guarantee this code runs once
                        player.vy = -100
                    end       
                end

                if (ufo.state == 3 or (ufo.type == "vulture" and ufo.state == 2)) and check_object_collision(player, ufo.tracker_beam) then
                    capturePlayer(player, dt)
                end
            end


        end


    end
end

-- look up key associated with player and bounce them
function bouncePlayer(key)
    
    local player = players[key]

    if not (player == nil) and not(player.inputDisabled) and player.enabled then
        bounceActor(player)
    elseif (player == nil) and gameMode == gMode.freeplay and playerCount < 32 then
        createPlayer(camera_x + 64, camera_y, key)
        setRespawnTimer()
    end
end

function setRespawnTimer()
        local timeDelay = lerp(10,1,playerCount/32)
        respawnTimer = timer(timeDelay)

end

-- === menu.lua ===


local menu_option = {
    main = 1,
    settings = 2,
    credits = 3
}

local startGameFunction = nil

local menus = {
    [menu_option.main] = {
            [1] = {text = "start", active = false, color = 6, action = function() changeMenu(menu_option.settings) end},
            [2] = {text = "credits", active = false, color = 6, action = function() changeMenu(menu_option.credits) end}
    },
    [menu_option.settings] = { 
        [1] = {text = "play", active = false, color = 6, action = function() startGameFunction() end},
        [2] = {text = "gamemode", active = false, color = 6, action = function() changeGameMode() end},
        [3] = {text = "input mode", active = false, color = 6, action = function() changeInputMode() end},
        [4] = {text = "back", active = false, color = 6, action = function() changeMenu(menu_option.main) end}
    },
    [menu_option.credits] = { 
        [1] = {text = "back", active = false, color = 6, action = function() changeMenu(menu_option.main) end},
    }
}

local active_menu = menu_option.main
local active_option = 1



function initMenu(startGameCallback)
    active_menu = menu_option.main
    changeOption(1)
    startGameFunction = startGameCallback
end

function updateMenu(dt)
    
    if btnp(5) then
        menus[active_menu][active_option].action()
    end

     if btnp(2) then
        local option = active_option - 1
        if option < 1 then
            option = #menus[active_menu]
        end
        changeOption(option)
     end
     
     if btnp(3) then
        local option = active_option + 1
        if option > #menus[active_menu] then
            option = 1
        end
        changeOption(option)
     end

     if gamemode_timer > 0 then
        print(showGameModeText().title, camera_x + 32)
        gamemode_timer = max(0, gamemode_timer - dt)
     end
end

function drawMenu()

    local x_pos = 16
    local y_pos = 60

    if active_menu == menu_option.main then
        print("\^w\^thop32", 46,16, 7)
    elseif active_menu == menu_option.settings then
        x_pos = 16
        print("\^w\^thop32", 46,16, 7)
        if active_option == 2 then
            gmodetext = showGameModeText()
            print(gmodetext.title, x_pos + 44 ,y_pos + 10, 6)
            print(gmodetext.description, x_pos + 44 ,y_pos + 20, 6)
        elseif active_option == 3 then
            gmodetext = showInputModeText()
            print(gmodetext.title, x_pos + 44 ,y_pos + 20, 6)
            print(gmodetext.description, x_pos + 44 ,y_pos + 30, 6)
        end
            

    elseif active_menu == menu_option.credits then

        print("\^w\^tcredits", 46,16, 6)

        print("cole pergerson", x_pos ,y_pos + 10, 6)
        print("james morgan", x_pos ,y_pos + 20, 6)
        print("shahbaz mansahia", x_pos,y_pos + 30, 6)
        print("frank dominguez", x_pos,y_pos + 40, 6)

    end

    
    for i = 1, #menus[active_menu] do
            print(menus[active_menu][i].text, x_pos, y_pos, menus[active_menu][i].color)
            y_pos += 10
    end
end

function changeOption(option, previous_menu)

    local previous_m = active_menu
    if previous_menu ~= nil then
        previous_m = previous_menu
    end

    menus[previous_m][active_option].active = false
    menus[previous_m][active_option].color = 6

    menus[active_menu][option].active = true
    menus[active_menu][option].color = 7
    active_option = option
end


function changeMenu(menu)
    local previous_menu = active_menu
    if menu == menu_option.main then      
       active_menu = menu_option.main     
    elseif menu == menu_option.settings then
        active_menu = menu_option.settings
    elseif menu == menu_option.credits then
        active_menu = menu_option.credits
    end

    changeOption(1, previous_menu)
end

function changeGameMode()
    local nextMode = gameMode + 1
    if nextMode > 1 then
        nextMode = 0
    end

    gameMode = nextMode

    if gameMode == gstate.playerSelect or gameMode == gstate.game then
        gamemode_timer = 3
    end
end

function changeInputMode()
    local nextMode = keyboard_input + 1
    if nextMode > 1 then
        nextMode = 0
    end

    keyboard_input = nextMode
end


function showGameModeText()
    if gameMode == gMode.tournament then
        return {title = "tournament" , description = "players cannot \njoin once the game \nhas started."}
    elseif gameMode == gMode.freeplay then
        return  {title = "freeplay" , description = "players are free \nto join after the game \nhas started."}
    end
end

function showInputModeText()
    if keyboard_input == 0 then
        return {title = "strict" , description = "characters are \nassigned to \nspecific keys."}
    elseif keyboard_input == 1 then
        return  {title = "any key" , description = "characters can be \nassigned to \nany key."}
    elseif keyboard_input == 2 then
        return  {title = "controller" , description = "characters are \nassigned to \ncontroller buttons."}
    end
end


function drawCompleteMenu()

    if gameover_menu_timer > 0 then        
        if gameState == gstate.complete then
            print("\^w\^tyou win!", camera_x + 30, camera_y + 60, 10)
        else
            print("\^w\^tnext time...", camera_x + 20, camera_y + 60, 10)
        end
    else
        
        rectfill(camera_x, camera_y, camera_x + 128, camera_y + 128, 12)
        draw_winners(camera_x, camera_y)
        
    end
    

end

function draw_winners(x, y)
    local indent = ""
    local line_height = 10
    local current_y = y + 16
    
    print("players\n", x + 45, current_y, 10)
    current_y = current_y + line_height
    leftCounter = 0
    for i = 1, #win_order do
        xOffset = leftCounter * 32
        spr(win_order[i][1], x + 12 + xOffset, current_y)
        print(tostr(i)..indent.."\n", x + 4 + xOffset, current_y, 10)
        if leftCounter == 3 then
            current_y = current_y + line_height
        end
        leftCounter = (leftCounter + 1) % 4
        --end
    end
    
    print("\t\tcontinue in " .. flr(score_timer) .. "\n", x, y + 116, 10)
end


-- === main.lua ===
poke(0x5F2D, 0x1) -- enable keyboard input
local delta_time
local last_time
local timeUntilCameraMoves = 1.5
local timeUntilRestart = 2
local timer_1 = 0
local timer_2 = 0 -- input delay when player select starts
local camera_speed = 15
--local camera_pos_y_offset = 128
local new_chunk_threshold = 0
local mouse_x = 0
local mouse_y = 0



local debug_tile_flags = {}

function _init()
    delta_time = 0
    last_time = 0
    timer_1 = 0
    if gameState == gstate.complete or gameState == gstate.gameover then
        gameState = gstate.playerSelect
    else
        gameState = gstate.mainMenu
    end
    switchGameState(gameState)
end

function restart()
    cls()
    _init()
end

function switchGameState(state)

    gameState = state

    if gameState == gstate.mainMenu then
        camera_x = 0
        camera_y = 0
        initMenu(startGameFromMainMenu)
        music(0, 500)
    elseif gameState == gstate.playerSelect then
        chunk_progress_x = 20
        chunk_progress_y = 0
        new_chunk_threshold = (chunk_progress_x + 1) * 128
        camera_x = chunk_progress_x * 16 * 8
        camera_y = chunk_progress_y * 16 * 8
        finalBossEnabled = false
        initUFOPool()
        initZombiePool(5)
        init_respawn_birds()
        initProceduralGen()
        initLevelLoad(chunk_progress_x)
        max_distance = map_x_size * 8 - 128 + 80
        initPlayers()
        win_order = {}
        timer_2 = .4
        menuitem(2, "set gamemode", function ()
            changeGameMode()
        end)
        score_timer = 15
        actors = {
            [1] = players,
            [2] = zombies
        }
            printh("== playerSelect == ")
    elseif gameState == gstate.game then
     
        music(2, 1000)
        setRespawnTimer()
    elseif gameState == gstate.complete or gameState == gstate.gameover then
        
        gameover_menu_timer = 3

        music(0, 2000)

        for key, player in pairs(players) do
            if player.enabled == true then
                add(win_order, {player.sprite, player.disabledCount, player.totalTimeEnabled})
            end
        end

        appendLosersToWinOrder()
    end


    
end

startGameFromMainMenu = function ()
    switchGameState(gstate.playerSelect)
end

function _update()
    local current_time = time()  -- Get the current time
    delta_time = current_time - last_time  -- Calculate delta time
    last_time = current_time  

    if gameState == gstate.mainMenu then
        updateMenu(delta_time)
    elseif gameState == gstate.playerSelect then
        local complete = false

        complete = addPlayers(camera_x, camera_y, delta_time, timer_2 == 0)

        if timer_2 > 0 then
            stat(31)
        end
        timer_2 = max(0, timer_2 - delta_time)        
        
        if playerCount > 0 then 
            start_timer = max(0, start_timer - delta_time)
            if start_timer == 0 then
                complete = true
            end
        end

        if complete then
            switchGameState(gstate.game)
        end
    
    elseif gameState == gstate.game then
        if debug_mode then
            debug_controls()

            if debug_fast_travel then
                debugUpdateQuickTravel()
            elseif debug_player_cannon then
                debugUpdatePlayerCannon()
            end
        else
            if timer_1 < timeUntilCameraMoves then
                timer_1 += delta_time
            else 
                
                camera_x = camera_x + camera_speed * delta_time
                --printh(chunk_progress_x)
            end

            -- set current area to cloud kingdom
            -- maybe use the special conditions function I was thinking about
            if current_area ~= AREA.CLOUD_KINGDOM then 
                current_area = AREA.CLOUD_KINGDOM
            else

                if finalBossEnabled and not(ufos[1].enabled) then
                    switchGameState(gstate.complete)
                end



            end

            if disabledPlayerCount == playerCount then
                switchGameState(gstate.gameover)
                timer_1 = 0
            end

            updateUFO(delta_time)
            update_players(camera_x, camera_y, delta_time)
            update_zombies(delta_time)
            update_respawns()

            -- cool but it looks like the asteroid are falling
            if new_camera_y_lerp_t < 1 then
                new_camera_y_lerp_t = (camera_x - (new_chunk_threshold - 128)) / 128
                camera_y = lerp(old_camera_y_pos, new_camera_y_pos, min(new_camera_y_lerp_t, 1))
            end

        end

        if camera_x >= new_chunk_threshold then
            --printh("update " .. new_chunk_threshold .. " >= " .. max_distance)
            chunk_progress_x += 1
            new_chunk_threshold += 128
            updateChunks(chunk_progress_x)
        end

        


        -- Process key input
        while stat(30) do
            keyInput = stat(31)

            if (keyInput == "れ") then
                toggleDebugMode()
            end

            bouncePlayer(keyInput)       
        end
    elseif gameState == gstate.gameover then

        updateUFO(delta_time)
        update_players(camera_x, camera_y, delta_time)
        update_zombies(delta_time)
        resetGameAfterTimer()
        gameover_menu_timer = processTimer(gameover_menu_timer, delta_time)

    elseif gameState == gstate.complete then
        resetGameAfterTimer()
        gameover_menu_timer = processTimer(gameover_menu_timer, delta_time)
        
    end
end

function _draw()
        cls()
        camera(camera_x, camera_y)
        map(0,0,0,camera_y,128,16)
        map(0,0,1024,camera_y,128,16) 
        map(0,0,2048,camera_y,128,16)
        map(0,0,3072,camera_y,128,16)
        drawChunks()
        drawUFO()
        draw_respawn_birds()
        --draw_zombies()
        drawActors(zombies)
        drawActors(players)
        
    
        if debug_mode then
            debug_draw_asteroid_polys()
            
        end

        -- UI
        if gameState == gstate.mainMenu then
            drawMenu()

        elseif gameState == gstate.playerSelect then

            rectfill(camera_x, 0, camera_x + 128, camera_y + 5, camera_y)

            print("press any button to join", camera_x + 4, camera_y, 7)

            if playerCount > 0 then 
                print("starting in " .. flr(start_timer), camera_x + 4, camera_y+8, 7)
            end

            print("\^w\^thop" .. playerCount, camera_x + 46,camera_y + 56, 7)

        elseif gameState == gstate.game then

        elseif gameState == gstate.complete or gameState == gstate.gameover then
            drawCompleteMenu()
        end

        if gameState == gstate.game or gameState == gstate.playerSelect then
            if gamemode_timer > 0 then
                rectfill(camera_x, 0, camera_x + 128, camera_y + 5, camera_y)
                print("set gamemode to " .. showGameModeText().title, camera_x + 16, camera_y, 7)
                gamemode_timer = max(0, gamemode_timer - delta_time)
            end
        end

        if (debug_mode) then
            rect(camera_x, camera_y, camera_x + 127, camera_y + 127, 7)
            print(camera_x/8 .. "," .. camera_y/8, camera_x+4, camera_y+4)
            print(camera_x/8+16 .. "," .. camera_y/8+16, camera_x + 128 + 4, camera_y + 128 + 4)

            mouse_x = stat(32) + camera_x
            mouse_y = stat(33) + camera_y
            rect(mouse_x, mouse_y, mouse_x + 2, mouse_y + 2)
        end       
end

function resetGameAfterTimer()
    if timer_1 < timeUntilRestart then
        timer_1 += delta_time     
    else
        score_timer -= delta_time

        if score_timer <= 0 then
            restart()
        elseif stat(30) and stat(31) == "\32" then
                restart()
        end
    end
end

function toggleDebugMode()
    debug_mode = not(debug_mode)

    if debug_mode then
        menuitem(2, "toggle fast travel", function() debugToggleQuickTravel() end)
        menuitem(3, "toggle pcannon", function() debugTogglePlayerCannon() end)
    else
        menuitem(2)
        menuitem(3)
    end

end

function debug_controls()
    local speed = 10

    if btn(0) then
        camera_x -= speed
    end

    if btn(1) then
        if debug_fast_travel then
            camera_x += speed
        else
            camera_x = min(camera_x + speed, new_chunk_threshold-1)
        end
    end

    if btn(2) then
       camera_y -= speed
    end

    if btn(3) then
        camera_y += speed
    end

    if stat(34) == 1 then
        printh(flr(mouse_x/8) .. ", " .. flr(mouse_y/8))
    end
end

function debugToggleQuickTravel()
    --debug_mode = true
    debug_fast_travel = not(debug_fast_travel)
end

function debugUpdateQuickTravel()
    for key, player in pairs(players) do
        if player.enabled == false then
            player.xpos = camera_x + 56
            player.ypos = camera_y + 8
        end
    end
end

function debugTogglePlayerCannon()
    debug_player_cannon = not(debug_player_cannon)
end

function debugUpdatePlayerCannon()

    if stat(34) == 1 then
        --printh(flr(mouse_x/8) .. ", " .. flr(mouse_y/8))

        local p = players[keys[key_index]]
        if p.enabled then enablePlayer(p) end
        p.xpos = flr(mouse_x)
        p.ypos = flr(mouse_y)

        p.vx = 100
        p.vy = 100

    end
    
    update_players(camera_x, camera_y, delta_time)

end

function appendLosersToWinOrder()
    local lose_order = {}

    for key, player in pairs(players) do
        if player.enabled == false and type(player.id) ~= "number" then
            add(lose_order, {player.sprite, player.disabledCount, player.totalTimeEnabled})
        end
    end

    local n = #lose_order
    for i = 1, n - 1 do
        for j = 1, n - i do
            local a = lose_order[j]
            local b = lose_order[j + 1]
            -- Compare by disabledCount (ascending)
            -- If disabledCount is the same, compare by totalTimeEnabled (descending)
            if a[2] > b[2] or (a[2] == b[2] and a[3] < b[3]) then
                lose_order[j], lose_order[j + 1] = lose_order[j + 1], lose_order[j]
            end
            
        end
    end

    for i = 1, #lose_order do 
        add(win_order, lose_order[i])    
    end

end



__gfx__
0000000000000000bbbbbbbb5444444411111111001c10000000000000aaaa000000000000000000000000007700770000000000000000000000000000000000
0000000000000000bbbbbbbb444455440010000001c9c100000000000a1111a00880088000000000000000007700770000000000000000000000000000000000
007007000aaaaaa04454444544544445001000001c9a9c100000c000a100071a8888888800000000000000000077007700000000000000000000000000000000
00077000000a0000544544445445444411111111c9aaa9c0000cac00a107001a8888888800000000000000000077007700000000000000000000000000000000
000770000ccaaa0a4444444444444444111111111c9a9c100000c000a1c0701a8888888800000000000000007700770000000000000000000000000000000000
007007000caaaaaa44455444444554440000010001c9c10000000000a110001a0888888000000000000000007700770000000000000000000000000000000000
0000000000a00a00455444544554445400000100001c1000000000000a1111a00088880000000000000000000077007700000000000000000000000000000000
000000000aaaaaa0444444454444444511111111000000000000000000aaaa000008800000000000000000000077007700000000000000000000000000000000
0777700000000000007777000000bb00000000000000000000000000000000000000000000000000cccccccc00000000c1c11111000000006666666600000000
076777700000000006677770000b00b0000000000000000000000000000000000000000000000000c11111cc00000000c1c11111000000008888888800000000
767667670000000006667777000b00b0000000000000000000000000000000000000000000000000c1111cc100000000c1c11111000000009999999900000000
77676676000000cc066607070b0b0b0b000000000000000000000000000000000000000000000000c111cc1100000000c1c1111100000000aaaaaaaa00000000
7676766700000c0006667777b0b000b0000000000000000000000000000000000000000000000000ccccc11100000000c1c1111100000000bbbbbbbb00000000
676767660000c00000677777b0000000000000000000000000000000000000000000000000000000c1c1cc1100000000c1c1111100000000cccccccc00000000
67670000000c000000060606b0000000000000000000000000000000000000000000000000000000c1c11cc100000000c1c11111000000001111111100000000
67000000000c00000007070700000000000000000000000000000000000000000000000000000000c1c111cc00000000c1c11111000000006666666600000000
002bb2000008e0000011110001cccc000bbb66b0000000000000aa008000000800000000000dd000000000000008000000888000000000000000660066666666
00bbbb00008eee00011cccc1001cccc004444440004470000000aa0008000080000cc000000dd00000aaaaa0008aaaa000890880066666600666666065555556
00bbbb00008eeee0011c7c7100aaaaaa44744744004750000000a9900088880000c66c000dddddd00aaaaa0008aaaa800449990006c66c600656656065755756
b03bb30b08eeeee0001c7c71000ffff044044044007770000aaaaa00088888800cccccc00d6dd6d00aaaa0000aaaa00008c9c880065665600656656065755756
0bbbbbb008e1e1e00011ccc1000f5f50444444440009000000aaaa00088558800c6cc6c00dddddd00aaaa0000aaaa00008c8c890066666600666666065555556
003bb30000eeee0e001cc110000ffff0444004440009970000aaaa0008888880cccccccc00d55d000aaaaa000aaaaa8000ccc000067a77600655556065777756
00bbbb000eee0e00001c110000f1111f04444440000100000009000008000080c6c66c6c0d0dd0d000aaaaa000aaaaa000c0c000066666600666666065555556
0bb33bb00e0e0ee00111000000010010004444000010100000099000008008000c0000c0d000000d000000000000000004404400000000000066660066666666
0000330000000000000000000000000000770000885588550000000000000000000000000004300000000000000000000aaaaaa00000000055515555767d6777
033bbb30004000400009990007777770007700008855885500046600006600000044700000044400000c00000000000000aaaa00000466605451555577454777
3bbbbbb3044000400009990007c55c7009970000558855880005460006666660044750000004000000cd00000000000000aaaa000005466055d66d5477424777
bbbbbbb304477400000999000755557000777770558855880004440000066000047770000004400000cd0000000ccc00000aa00000044460556666557745e777
bb5bbb5300444400000090000777777000777700885588550000200000066000040b0000000444000dccc0000cccccc00005500000002266555ddd5577d5d777
3bbbbbb300400400008888800007700000777700885588550042200000066660040bb700004444000ccccc0008cccca000055000004222005456655477d5d777
0bbbbbb000400400000080000070070000009000558855880000100006600000040b0000040400000ccccc000c5cc5c000055000000022005545544577d5d777
033333300000000000cc0cc0000000000009900055885588000101000000000040b0b0000004400000ccc000444444440005500000022222124ef42176667777
000000000004300000000000000000000aaaaaa0000000000000aa008000000800000000000dd000000000000008000000888000000770000000000000000000
0060006000044400000c00000000000000aaaa00004470000000aa0008000080000cc000000dd00000aaaaa0008aaaa000890880007777000000000000000000
066000600004000000cd00000000000000aaaa00044750000000a9900088880000c66c000dddddd00aaaaa0008aaaa8004499900077777700000000000000000
066666000004400000cd0000000ccc00000aa000047770000aaaaa00088888800cccccc00d6dd6d00aaaa0000aaaa00008c9c880070707700000000000000000
00666600000444000dccc0000cccccc000055000040b000000aaaa00088008800c6cc6c00dddddd00aaaa0000aaaa00008c8c890077777700000000000000000
00600600004444000ccccc0008cccca000055000040bb70000aaaa0008888880cccccccc00d00d000aaaaa000aaaaa8000ccc000077777700000000000000000
00600600040400000ccccc000c0cc0c000055000040b00000009000008000080c6c66c6c0d0dd0d000aaaaa000aaaaa000c0c000077777700000000000000000
000000000004400000ccc000444444440005500040b0b00000099000008008000c0000c0d000000d000000000000000004404400070707000000000000000000
00000000000000000000000000000000000000000000000000000000555555550123012377677677777777777777777777777777aaaaaaaa9999999999999999
00000000000000000000000000000000000000000000000000000000555555552201456766777766777777777777777777777777aa9aaaa99999999999999999
0000000000000000000000000000000000000000000000000000000055555555400123ab77677677777777777777777777777777aaaaaaaa9999999977979797
0000000000000000000000000000000000000000000000000000000055555555234567ef77766777777777777777777777777777a9aa9aa99999999977777779
00000000000000000000000000000000000000000000000000000000555555554089ab23776776777777777777777777777777779a9aaa9a9999999977979797
000000000000000000000000000000000000000000000000000000005555555524bdef6776777767777777777777777777777777a9a9a9a99999999999999999
0000000000000000000000000000000000000000000000000000000055555555589a89ab676776767777777777777777777777779a9a9a9a9999999999999999
00000000000000000000000000000000000000000000000000000000555555559cdecdef7776677777777777777777777777777799a999a99999999999999999
77777777555555555555555577777777777777776666666655555555777777777777777780000008800000888008800803333000000000000000000000000000
66666666555555555055550577777777777777776666666655555555757777575555555508888808008800000880088036333300000cc0000000000000001000
6666666655555555550550557777777777777777666666665500005505575055555555558888000808880888088008803633330000cccc000bb33bb000012100
6666666655555555555005557777777767676767666666665500005550550505550000558800088800800000800880083333333300cccc000b3333b000122210
666666665555555555550555777777777676767666666666550000550500505555000055000000008008008000800880033ccccc06666660bb3333bb00012100
56665656555555555550555577777777666666666666666655000055505005005500005508888800880088888808800800c33ccc666aa666b333333b00001000
6565656555555555555555557777777767676767666666665500005500055050550000558888008808008888880880080000cccc06000060b333333b00000000
55565556555555555555555577777777666666666666666600000000000000000000000088008888008008880080088000011111600000060000000000000000
0000000000000000000000000000000001112100000000000000000000000000000000000bb00bb0000000000000007777000000007770000ccccc0000000000
020000000000000000000000001111000112212000112000000000000000000000020000b70bb07b00077700000000000700000000007000c00000c000000000
222000000000c00000000000111221201112212000122112000000000000000000122000b0bbbb0b7777767700077777777777007777777700ccc00c00000000
02000000000ccc00001000001122222011122220001211220002112000000000001220000bb00bb0776677670777777777777770770770770c000c0c00000000
000000000000c00000000000122222001122222000121122012111200000000000010000077bb77076677767777777777777777770077007c0000c0c00000000
0000020000000000000000002222220012222200000012200111112000111100011111001227722107767677777000700070077770777707c00cc00c00000000
00002220000000000000000022000000022000000000000002211220001112000111220012277221000777000000007000700000007777000c0000c000000000
000002000000000000000000000000000000000000000000002222200112220000122000012772100000000000000700000700000070070000cccc0000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1
00000030000000000000003000000000000000000000000000000000000000003000000000000000300000000000000000000000000000300000000000000030
00000000000000000000000000000000003000000000000000000000000000000000003000000030000000003000000000000000000000000000000000003000
00000030000000000000003000000000000000000000000000000000000000003000000000000000300000000000000000000000000000300000000000000030
00000000000000000000000000000000003000000000000000000000000000000000003000000030000000003000000000000000000000000000000000003000
00000030000000000000003000000000000000000000000000000000000000003000000000000000300000000000000000000000000000300000000000000030
00000000000000000000000000000000003000000000000000000000000000000000003000000030000000003000000000000000000000000000000000003000
00000030000000000000003000000000000000000000000000000000000000003000000000000000300000000000000000000000000000300000000000000030
00000000000000000000000000000000003000000000000000000000000000000000000000000030000000003000000000000000000000000000000000000000
00000000000000000000003030000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000030
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000020
00000000200000000000000030000000000000000000000000000000000000000020000000000000000000000000000000000000000000002000000000000000
30000000000000000000000000000000000020000000000000000000000000000000000000000000200000000020000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000002000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000002000000000
00000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000400000000000000000
00000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000040000000000000000000000000000000
00000000000000000000400000000000000000000000000000000000400000000040000000000000000000000000000000000000000000400000000040000000
004000000000000000000000000000d0d0d000000000000000400000000040000000000000000000000000000000000040000000004000000000000000000000
00000000000000000000400000000040000000000020202020202020202020202020202020200000000000000000000020202020202020202020202020202020
2020202020209090b0b0b0b0a0909000000020202020202020202020202020202020209090b0b0b0b020202020202020202020202020202020209090b0b0b0b0
a0909020202020202020202020202020202020209030303030303030303030303030303030302020202090202020209030303030303030303030303030303030
__map__
0000000000000070000000710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070000078000071000000000000007100000000000070000000000070000000000000006f0000000000000000000000006f0000000000000000000000000000000000006f6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007100727300737574007000007874007000000000000000000000000000006f0000000000006f00006f00000000000000000000000000006f0000000000000000000000006f6f00000000710000000000000000000000007100710000000000006f6f0000000000000000007100006f00007000000000000000000070000000
006f00000000006f0000000074740000000000710000000070000078770077006f00000000000000006f0000700000007100007000000000710000006f00000000007000006f00710000006f00700000000070006f00000000006f0000000000000000000000000000006f000000000000000000000000700000000000007000
00000000007000000000006f000000000000000000000000000000000075000071000000006f00000000000000000000000000000000000000000000000000006f0000000000000000006f0000000000000000000000700000000000006f6f0000000000000000000000000000006f0000000000000000000000000070000000
0000007000000000720000007200000072000000000000000000000000000000000000000000000000000000000000706f000000000000000070000000000000000000707100006f6f0000007100000000000000000000710000000000006f000000006f006f00000000000000007171000000006f0000000000000000000000
0000007200720000007000000000720070000072000000000000006f000000000000006f000000000000000000000000000000006f0071006f000000006f00000000007100000000006f000071006f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000
007200007000000000007200000000000000000000000070000000700000006f00006f000000000000710000006f00000000000000000000000000000071000000000000000000000000707100000000006f0000000000006f6f0071000000000000000000000000000000000000000000000071007171000000000000000000
00000000000000000000007200007000000000000000006f000000000000000000706f00000000006f000000006f000070000000000000000000006f00000000006f000000006f7100000000000000000000000000000000000000000000000000000000000000000000006f0000000000000000000070000000710000000070
00000000000072000072000000000000000072000000000000000000000070000000000000006f00000000700000000000000000006f000000006f000000007000700000000000000000000000000000000000006f00000000000000007100006f000000000000006f0000000000000000000000000000000000000000000000
000072000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006f0000000000000000000000000000006f000000000000000000000000716f0000000000000000000070000000006f0000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000070000000000000000000006f00000000000000000000000000007000000000000070000000006f000000000000000070006f000000007000000000000000000000006f00000000710000000000000000000000006f000000700000000000000000000000007000
00000000000000000000000000000000000000007000000000000000710000000071006f007000000000006f00000000007100000000006f0000000000000000000000006f000000000000000000000000006f00710000007000000000006f00006f000000007100000000000000000000000000000000700000000000000000
0000000000000000000000000000000000000000006f000000000000000000006f000000000000000000000000000000000000000000000000000000006f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000006f0000000000000000000000006f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
911e00002353423534235342353424e1224e122453424534245342453424e1224e122353423534235342353424e1224e122153421534215342153424e1224e121f5341f5341f5341f53424e1224e1224e1224e12
951e00000c0350c03524e12130351303524e1224e12170301703024e12150351303524e1210030100301003024e1224e120c0350c03524e120c0350c0350c03024e1224e120c0350c03524e120c0350c03524e12
d71e000024e1224e1224e1224e1224e122d1102d1102d1102b1102b11028110281102a1102a1102b1102b1102b1102b1102a1102a1102a1102811028110281102811028110281102811028110231102311023110
911e00001f5341f5341f5341f53424e1224e121e5341e5341e5341e53424e1224e121f5341f5341f5341f53424e1224e121e5341e5341e5341e53424e1224e121c5341c5341c5341c53424e1224e1224e1224e12
d71e0000211102111021110231102311023110241102411024110241102311023110231102311024e1224e1224e1224e121c1101c1101c1101e1101e1101e1101f1101f1101f1101f1101e1101e1101e1101e110
911e00001c5341c5341c5341c53424e1224e122153421534215342153424e1224e121c5341c5341c5341c53424e1224e121a5341a5341a5341a53424e1224e121853418534185341853424e1224e1224e1224e12
011e000024e1224e1200000000000000024e1524e1524e1524e1524e1524e1524e1524e150ce150c5150c5150c5140c5140c5140c5140c5140c5140c5140c5140c5140c5140c5340c5340c5340c5340c5340c534
970d00000cf300cf30225320700007f30225320af300af300cf300cf30225320700007f30225320af300af300cf300cf30225320700007f30225320af300af300cf300cf30225320700007f30225320af300af30
910d0000166000c6001b5321f600226001b5321b6001f60022600186001b53213000130001b5321c4001d4001e4001f4001b5321b0001b0001b5321f6002260018000180001b53218000180001b5321800000000
910d00000c74300000185321360013645185320c7430c7000c74300000185321360013645185320c743000000c74300700185321360013645185320c743000000c74300000185321360013645185320c7430c700
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
b70d0000274222742224422244221f4221f4221b4221b4221842218422184221842218422184220040200402004020040200402004021640216402164221642218422184221b4221b4221b4221b4221b4221b422
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
b70d00001b4221b4221b4221b4221b4221b4221b42224422234222242221422204221f4221e4221d4221c4221b4221b4221b4221b4221b4221b4221b40200402004020040218422184221a4221a4221b4221b422
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
970d000011030110301b532000000c0301b5320f0300f03011030110301b532050000c0301b5320f0300f03011030110301b5320c0000c0301b5320f0300f03011030110301b5320c0000c0301b5320f0300f030
b70d000020422204221d4221d4221842218422144221442211422114221142211422114221142200402004020040200402004020040200402004020f4220f42211422114220c4020c40211422114220000200000
910d00000000000000205320050000500205320050000500005000050020532185001850020532185001850018500185002053218500185002053218500185001850018500205321850018500205321800000000
970d00000c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a0300c0300c030225320700007030225320a0300a030
001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01050300
00 01020300
00 01040300
02 01050300
00 0a430809
00 0a430809
01 0b0c0809
00 0d0e0809
00 0f420809
00 100c0809
00 110e0809
00 12420809
00 13141509
02 16420809
00 57575757
__label__
00007770777007700770000077707700707000007070777070700000777007700000777077007700000077700000777070007770707077707770000000000000
07707070700070007000000070707070707000007070700070700000070070700000707070707070000070700000707070007070707070007070000000000000
70707700770077707770000077707070777000007700770077700000070070700000777070707070000077700000777070007770777077007700000000000000
77707070700000700070000070707070007000007070700000700000070070700000707070707070000070700000700070007070007070007070000000000000
70007070777077007700000070707070777000007070777077700000070077000000707077707770000070700000700077707070777077707070000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770000777700777777007777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770000777700777777007777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077007700770077007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077007700770077007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007777770077007700777777007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007777770077007700777777007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077007700770000007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077007700770000007700770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077770000770000007777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007700770077770000770000007777770000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000bbbbbbbb00000000bbbbbbbb0000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000bbbbbbbb00000000bbbbbbbb0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000004444444400000000444444440000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000000000000bbbbbbbb00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000bbbbbbbb000000000000000000000000bbbbbbbb00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444444440000000000000000000000004444444400000000000000000000000000000000
000000000000000000000000000000000000000000000000bbbbbbbb0000000000000000000000000000000000000000bbbbbbbb000000000000000000000000
000000000000000000000000000000000000000000000000bbbbbbbb0000000000000000000000000000000000000000bbbbbbbb000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
00000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000000044444444000000000000000000000000
0000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000bbbbbbbb0000000000000000
0000000000000000000000000000000000000000bbbbbbbb00000000000000000000000000000000000000000000000000000000bbbbbbbb0000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
00000000000000000000000000000000000000004444444400000000000000000000000000000000000000000000000000000000444444440000000000000000
6777777667777776677777766777777667777776bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
7666666776666667766666677666666776666667bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
76666667766666677666666776666667766666674444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
67777776677777766777777667777776677777764444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
