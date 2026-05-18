debug_mode = false
debug_fast_travel = false
debug_player_cannon = false
debug_camera_x = 0 --??
debug_camera_y = 0
keyboard_input = 0 -- 0=any key, 1=strict, 2=gamepad
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
camera_push_cells = 7   
camera_ease_speed = 1.5 
camera_min_speed  = 8    

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
revive_order = {}
game_start_time = 0
game_elapsed_time = 0
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

-- death icons
death_icons={}
icon_x_spr=128
icon_arrow_spr=129
icon_arrow_left_spr=130

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

function format_time(seconds)
    local m = flr(seconds / 60)
    local s = flr(seconds % 60)
    local ss = tostr(s)
    if s < 10 then ss = "0" .. ss end
    return m .. ":" .. ss
end


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
    ["l"] = 26,
    ["m"] = 27,
    ["n"] = 22,
    ["o"] = 20,
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
    ["3"] = 27,
    ["4"] = 24,
    ["5"] = 23,
    ["6"] = 21,
    ["7"] = 64,
    ["8"] = 65,
}
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
local loaded_chunks = {}

local chunk_x_size = 16
local chunk_y_size = 16

local x_offset = 0
local y_offset = 0

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
    local new_chunk
    
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

        if new_chunk.x ~= chunk_progress_x * 16 or gameState ~= gstate.playerSelect then
            local zombie_spawn_point = getRndSurfaceTile(new_chunk.surface_tiles)
            enableActor(zombies, -1, zombie_spawn_point.x * 8, (zombie_spawn_point.y-1) * 8)
        end

        if x_offset == 64 then
            enableUFO(512, 16)
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
                    if debug_mode then
                        rect(tile.x * 8, tile.y * 8, tile.x * 8 + 8, tile.y * 8 + 8, 9)                      
                    end
                else
                    if debug_mode then
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
    if tile_x_1 and tile_x_2 and (tile_x_1.sprite ~= TILE.NONE or tile_x_2.sprite ~= TILE.NONE) then
        if not is_player then -- HACK, for players this stops collisions in beyond the grid in the -y direction
            new_x_unit = flr(new_x_unit) + 1
        end
        hit_wall = true
    elseif tile_x_3 and tile_x_4 and (tile_x_3.sprite ~= TILE.NONE or tile_x_4.sprite ~= TILE.NONE) then
        new_x_unit = flr(new_x_unit)
        cornerCount += 1
        hit_wall = true
    end

    -- Y
    if tile_y_1 and tile_y_2 and (tile_y_1.sprite ~= TILE.NONE or tile_y_2.sprite ~= TILE.NONE) then
        if new_y > 0 or not is_player then -- HACK, this stops collisions in beyond the grid in the -y direction
            new_y_unit = flr(new_y_unit) + 1
        end
        cornerCount += 1
    elseif tile_y_3 and tile_y_4 and (tile_y_3.sprite ~= TILE.NONE or tile_y_4.sprite ~= TILE.NONE) then
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


function initActorPool(actor_count, actor_table, actor_data)
    for i = 1, actor_count do
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
        reviveCount = 0,
        last_enabled_time = 0,
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
    local actor

    if id == -1 then -- if id -1, then enable first available inactive
        for key, a in pairs(actor_table) do
            if not a.enabled then
                actor = a
                break;
            end
        end

        if not actor then
            printh("no more actors available")
            return
        end
    else
        actor = actor_table[id]

        if not actor then
            printh("can't find actor with id " .. id)
            return
        end
    end

    actor.enabled = true
    actor.last_enabled_time = time()
    actor.ai_enabled = true
    actor.inputDisabled = false
    actor.state = 1
    actor.search_timer = 5 + flr(rnd(5)) -- ufo
    actor.ypos = ypos
    actor.xpos = xpos
    actor.bounce_charge = 0
    actor.jump_gravity = GRAVITY
    return actor
end

function disableActor(actor)
    actor.enabled = false
    actor.ai_enabled = false
    actor.disabledCount += 1 -- player
    actor.totalTimeEnabled += time() - actor.last_enabled_time  -- player
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
    if actor.onGround and not actor.won then
        local jump_dist_p1 = actor.jump_distance * .6
        local jump_dist_p2 = actor.jump_distance * .4
        local jump_velocity = (-2 * actor.jump_height * jump_x_velocity) / jump_dist_p1
        actor.jump_gravity = (2 * actor.jump_height * jump_x_velocity * jump_x_velocity)  / (jump_dist_p1 * jump_dist_p1)
        actor.fall_gravity = (2 * actor.jump_height * jump_x_velocity * jump_x_velocity)  / (jump_dist_p2 * jump_dist_p2)
        actor.vx = jump_x_velocity  * 8
        actor.vy = jump_velocity  * 8
        actor.bounce_charge = 0
        sfx(sfx_hop)
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
    return actor.xpos + 8 < camera_x - 16
        or actor.ypos > camera_y + 200
        or actor.ypos < camera_y - 64
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

local SPEED = 500
local MIN_SPEED = 50
local MAX_SPEED = 65 -- camera speed is 15
local HOVER_DOWN_SPEED = 30
local VULTURE_DOWN_SPEED = 10

function initUFOPool()
    ufos = {}

    initActorPool(1, ufos, {type = "ufo", width = 8, height = 8, sprite = 109, sprite2 = 110})
end

function initKing()
    ufos = {}
    final_boss_health = max(playerCount, 3)
    initActorPool(1, ufos, {type = "king", width = 16, height = 16, sprite = 12, sprite2 = 122})
    ufos[1].boundsOffsetX = 8
    ufos[1].boundsOffsetY = 8
end

function initVulture()
    ufos = {}

    initActorPool(1, ufos, {type = "vulture", width = 16, height = 16, sprite = 14, sprite2 = 126})

    ufos[1].boundsOffsetX = 8
    ufos[1].boundsOffsetY = 8
    ufos[1].tracker_beam.width = 8
    ufos[1].tracker_beam.height = 8
    ufos[1].tracker_beam.boundsOffsetX = 4
    ufos[1].tracker_beam.boundsOffsetY = 6

end


function enableUFO(xpos, ypos)

    local ufo = enableActor(ufos, 1, xpos, ypos)
    --ufo.boundsOffsetX = 4
    --ufo.boundsOffsetY = 4

    resetUFO(ufo, xpos, ypos)

    return ufo

end


function updateUFO(dt)
    local ufo = ufos[1]

    if ufo.enabled and ufo.ai_enabled then
        if ufo.state == 1 then
            
            moveLeftRight(ufo, 50)

            if ufo.type == "king" then
                if ufo.timer_1 == 0 then
                    enableActor(zombies, -1, ufo.xpos, ufo.ypos)
                    ufo.timer_1 = 5
                elseif final_boss_health <= 0 then
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

        ufo.xpos += ufo.vx * dt
        ufo.ypos += ufo.vy * dt

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
    for _, captured in pairs(ufo.capture_tracker) do
        captured.player.xpos = -8
        captured.player.ypos = -8
    end
end

function capturePlayer(player)

    local ufo = ufos[1]

    if not ufo.capture_tracker[player.id] then
       
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

    for _, captured in pairs(ufo.capture_tracker) do
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
        
        if ufo.type ~= "ufo" then
            spr(ufo.sprite, ufo.xpos, ufo.ypos, 2, 2)
        else
            spr(ufo.sprite, ufo.xpos, ufo.ypos, 1, 1)
        end

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
    local rows = ceil((heart_count * 10) / 128)
    local hearts_left_to_draw = heart_count

    for i = 1, rows do

        local xpos = camera_x + 4
        local ypos = camera_y + 4 + (10 *(i-1))
        local hearts = 12

        if i == rows then
            hearts = hearts_left_to_draw
        end

        for j = 1, hearts do
            spr(8, xpos, ypos)
            hearts_left_to_draw -= 1
            xpos += 10
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

function getLeadPlayer()
    local lead = nil
    for key, player in pairs(players) do
        if player.enabled then
            if lead == nil or player.xpos > lead.xpos then
                lead = player
            end
        end
    end
    return lead
end

function initPlayers()
    players = {}
    keys = {}
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

function disablePlayer(player, left)
    add(death_icons,{player.xpos,player.ypos,3,player.sprite,left})
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

    if keyboard_input == 0 or keyboard_input == 2 then
        local sprites = {32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63}
        spr = sprites[playerCount + 1]
    else
        spr = player_sprite_index[keyInput]
    end

    if spr == nil then
        return nil
    end

    playerCount = playerCount + 1
    local p = nil
    if keyboard_input == 2 then
        for i = 6, 32 do
            if players[i] ~= nil and players[i].enabled == false then
                p = players[i]
                players[i] = nil
                break
            end
        end
    else
        p = players[playerCount]
        players[playerCount] = nil
    end

    if p == nil then
        return nil
    end

    p.id = keyInput
    p.sprite = spr
    p.xpos = xpos
    p.ypos = ypos
    players[keyInput] = p

    enableActor(players, keyInput, xpos, posy)
    add(keys, keyInput)

    return p
end

function addPlayers(startingCamPos_x, startingCamPos_y, dt, ready)
    local function joinPlayer(keyInput)
        start_timer = 5.9
        local p = createPlayer(posx + startingCamPos_x, posy + startingCamPos_y, keyInput)
        if p == nil then return nil end
        p.startPosition = posy
        posx = posx + 9
        if posx >= 100 then
            xOffset = xOffset >= 8 and 0 or xOffset + 2
            posx = xOffset
            posy = posy + 9
        end
        return p
    end

    if keyboard_input ~= 2 then
        if ready and stat(30) then
            local keyInput = stat(31)
            if not (keyInput == "\32") and not (keyInput == "\13") and not (keyInput == "\112") and playerCount < 32 then
                if not players[keyInput] then
                    if joinPlayer(keyInput) == nil then return end
                end
                players[keyInput].ypos = players[keyInput].startPosition - 2
            end
            if keyInput == "\32" and playerCount > 0 then return true end
        end
    else
        if ready then
            for b = 0, 5 do
                local joined = players[b] ~= nil and players[b].enabled == true
                if btnp(b, 0) and not joined and playerCount < 6 then
                    joinPlayer(b)
                elseif joined then
                    players[b].ypos = players[b].startPosition - 2
                end
            end
        end
    end

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
                disablePlayer(player, player.xpos+8<camera_x)
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
                    player.reviveCount = player.reviveCount + 1
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
                        player.vx = 0
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



local menu_option = {
    main = 1,
    settings = 2,
    credits = 3
}

local startGameFunction = nil

local menus = {
    [menu_option.main] = {
            [1] = {text = "start", color = 6, action = function() changeMenu(menu_option.settings) end},
            [2] = {text = "credits", color = 6, action = function() changeMenu(menu_option.credits) end}
    },
    [menu_option.settings] = {
        [1] = {text = "play", color = 6, action = function() startGameFunction() end},
        [2] = {text = "gamemode", color = 6, action = function() changeGameMode() end},
        [3] = {text = "input mode", color = 6, action = function() changeInputMode() end},
        [4] = {text = "back", color = 6, action = function() changeMenu(menu_option.main) end}
    },
    [menu_option.credits] = {
        [1] = {text = "back", color = 6, action = function() changeMenu(menu_option.main) end},
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

    print("menu controls: \148\131 and \151", 12, 120, 6)
end

function changeOption(option, previous_menu)

    local previous_m = previous_menu or active_menu

    menus[previous_m][active_option].color = 6
    menus[active_menu][option].color = 7
    active_option = option
end


function changeMenu(menu)
    local previous_menu = active_menu
    active_menu = menu
    changeOption(1, previous_menu)
end

function changeGameMode()
    gameMode = (gameMode + 1) % 2

    if gameMode == gstate.playerSelect or gameMode == gstate.game then
        gamemode_timer = 3
    end
end

function changeInputMode()
    keyboard_input = (keyboard_input + 1) % 3
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
        return {title = "any key" , description = "characters can be \nassigned to \nany key."}
    elseif keyboard_input == 1 then
        return {title = "strict" , description = "characters are \nassigned to \nspecific keys."}
    elseif keyboard_input == 2 then
        return {title = "gamepad" , description = "each button is\nassigned to a\nunique player."}
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

    -- game time
    local time_str = "time: " .. format_time(game_elapsed_time)
    print(time_str, x + flr((128 - #time_str * 4) / 2), y + 2, 10)

    -- top 3 revivers
    print("most revives", x + 40, y + 9, 7)
    local reviver_xs = {x + 16, x + 56, x + 96}
    for i = 1, 3 do
        if revive_order[i] and revive_order[i][2] > 0 then
            local rx = reviver_xs[i]
            spr(revive_order[i][1], rx, y + 15)
            local count_str = tostr(revive_order[i][2])
            local cx = rx + 4 - (#count_str * 2)
            print(count_str, cx, y + 24, 10)
        end
    end

    -- top 3 survivors
    print("leaderboard", x + 42, y + 30, 7)
    local survivor_xs = {x + 16, x + 56, x + 96}
    for i = 1, 3 do
        if win_order[i] then
            local sx = survivor_xs[i]
            spr(win_order[i][1], sx, y + 36)
            print(tostr(i) .. ".", sx, y + 45, 7)
            print(format_time(win_order[i][3]), sx, y + 52, 10)
        end
    end

    -- rest (players 4+)
    if #win_order > 3 then
        ---print("rest", x + 2, y + 62, 7)
        local per_row = 13
        for i = 4, #win_order do
            local slot = i - 4
            local col = slot % per_row
            local row = flr(slot / per_row)
            local rx = x + 6 + col * 9
            local ry = y + 68 + row * 8
            if ry < y + 110 then
                spr(win_order[i][1], rx, ry)
            end
        end
    end

    -- countdown footer
    local countdown_str = "continue in " .. flr(score_timer)
    local cw = #countdown_str * 4
    print(countdown_str, x + flr((128 - cw) / 2), y + 120, 10)

end

function appendLosersToWinOrder()
    local lose_order = {}

    for _, key in ipairs(keys) do
        local player = players[key]
        if player and player.enabled == false then
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

function initCompleteMenu()
    -- Compute total game time
    game_elapsed_time = time() - game_start_time

    -- Finalize totalTimeEnabled for still-enabled players
    for key, player in pairs(players) do
        if player.enabled == true then
            player.totalTimeEnabled = player.totalTimeEnabled + (time() - player.last_enabled_time)
        end
    end

    -- Build win_order: ALL players sorted by totalTimeEnabled descending
    win_order = {}
    for _, key in ipairs(keys) do
        local player = players[key]
        if player then
            add(win_order, {player.sprite, player.disabledCount, player.totalTimeEnabled, player.reviveCount})
        end
    end
    local n = #win_order
    for i = 1, n - 1 do
        for j = 1, n - i do
            if win_order[j][3] < win_order[j+1][3] then
                win_order[j], win_order[j+1] = win_order[j+1], win_order[j]
            end
        end
    end

    -- Build revive_order: ALL players sorted by reviveCount descending
    revive_order = {}
    for _, key in ipairs(keys) do
        local player = players[key]
        if player then
            add(revive_order, {player.sprite, player.reviveCount})
        end
    end
    local m = #revive_order
    for i = 1, m - 1 do
        for j = 1, m - i do
            if revive_order[j][2] < revive_order[j+1][2] then
                revive_order[j], revive_order[j+1] = revive_order[j+1], revive_order[j]
            end
        end
    end
end
poke(0x5F2D, 0x1) -- enable keyboard input
local delta_time,last_time
local timeUntilCameraMoves,timeUntilRestart = 1.5,2
local timer_1,timer_2,new_chunk_threshold,mouse_x,mouse_y = 0,0,0,0,0

function updatePlayerPushedCamera(dt)
    local lead = getLeadPlayer()
    local min_advance = camera_x + camera_min_speed * dt

    local target_x
    if lead ~= nil then
        target_x = lead.xpos - (128 - camera_push_cells * 8)
    else
        target_x = min_advance
    end

    -- never go backward; always apply minimum pressure
    target_x = max(target_x, min_advance)

    camera_x = camera_x + (target_x - camera_x) * min(camera_ease_speed * dt, 1)
end

function _init()
    delta_time,last_time,timer_1 = 0,0,0
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
        initMenu(function() switchGameState(gstate.playerSelect) end)
        music(0, 1000, 1)
    elseif gameState == gstate.playerSelect then
        chunk_progress_x = 0
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
        death_icons={}
        timer_2 = .4
        menuitem(2, "set gamemode", changeGameMode)
        score_timer = 15
        actors = {
            [1] = players,
            [2] = zombies
        }
        music(-1, 1000, 1)
        music(4, 1000, 2)
    elseif gameState == gstate.game then
        music(-1, 1000, 2)
        music(6, 1000, 3)
        setRespawnTimer()
        game_start_time = time()
    elseif gameState == gstate.complete or gameState == gstate.gameover then

        gameover_menu_timer = 3
        music(0, 2000)

        initCompleteMenu()

    end


    
end

function _update()
    local current_time = time()  -- Get the current time
    delta_time = current_time - last_time  -- Calculate delta time
    last_time = current_time  

    if gameState == gstate.mainMenu then
        updateMenu(delta_time)
    elseif gameState == gstate.playerSelect then
        local complete = addPlayers(camera_x, camera_y, delta_time, timer_2 == 0)

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
            end
        else
            if timer_1 < timeUntilCameraMoves then
                timer_1 += delta_time
            else 
                
                updatePlayerPushedCamera(delta_time)
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

            for d in all(death_icons) do
              d[3]-=delta_time
              if d[3]<=0 then del(death_icons,d) end
            end

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
        if keyboard_input ~= 2 then
            while stat(30) do
                keyInput = stat(31)

                if (keyInput == "れ") then
                    toggleDebugMode()
                end

                bouncePlayer(keyInput)
            end
        else
            for b = 0, 5 do
                if btnp(b, 0) then
                    bouncePlayer(b)
                end
            end
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
        drawActors(zombies)
        drawActors(players)
        
        local li=camera_y+112
        for d in all(death_icons) do
          local x,y=mid(d[1],camera_x,camera_x+112),mid(d[2],camera_y,camera_y+112)
          if d[5] then y,li=li,li-16 end
          spr(d[4],x,y-8)
          spr(icon_x_spr,x,y-16)
          if d[5] then spr(icon_arrow_left_spr,x-8,y-8)
          else spr(icon_arrow_spr,x,y) end
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

        if debug_mode then
            debug_draw_asteroid_polys()
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
        menuitem(2, "toggle fast travel", debugToggleQuickTravel)
        menuitem(3, "toggle pcannon", debugTogglePlayerCannon)
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


