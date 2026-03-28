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
    mainmenu = 0,
    playerselect = 1,
    game = 2,
    gameover = 3,
    complete = 4
}
gamestate = gstate.mainmenu

gmode = {
    tournament = 0,
    freeplay = 1
}
gamemode = gmode.tournament


--camera
camera_x = 0
camera_y = 0
old_camera_y_pos = 0
new_camera_y_pos = 0
new_camera_y_lerp_t = 1
new_camera_y_lerp_r = 0

function setcameraypos(y_pos)
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
playercount = 0
disabledplayercount = 0
keys = {}
key_index = 1 -- used for sorting through keys

function setdisabledplayercount(value)

    if value > playercount then
        value = playercount
    end

    disabledplayercount = value
    --printh("dispc " .. disabledplayercount)
end

-- actors
ufos = {}
zombies = {}
players = {}
actors = {}

-- progress
area = {
    green_lands = 0,
    cloud_kingdom = 10
}
current_area = -1
chunk_progress_x = 0
chunk_progress_y = 0
finalbossenabled = false
final_boss_health = 4

tile = {
    none = 0,
    grass = 2,
    ground = 3,
    wall = 4,
    sand_1 = 93,
    sand_2 = 94,
    sand_3 = 95,
    mountain_1 = 96,
    mountain_2 = 97,
    mountain_3 = 99,
    snow_1 = 99,
    snow_2 = 100,
    snow_3 = 101,
    oreland_1 = 102,
    oreland_2 = 103,
    oreland_3 = 104,
    hell_1 = 105,
    hell_2 = 106,
    hell_3 = 107,
    cloud_1 = 89,
    cloud_2 = 90,
    cloud_3 = 91,
    cloud_4 = 92,
    glitch = 88
}

biome_dist_unit = {
    grass = 48,
    desert = 96,
    mountain = 144,
    snow = 192,
    city = 240,
    void = 336,
    kingdom = 384 
}

-- sfx
sfx_hop = 23
sfx_player_death_to_zombie = 24
-- === helper.lua ===

-- tables
function contains(table, value)
    for _, v in ipairs(table) do
        if v == value then 
            return true
        end
    end
    return false
end

queue = {}
queue.__index = queue

-- create a new queue
function queue.new()
    local self = setmetatable({
        items = {}, -- the table to hold queue items
        head = 1,   -- index of the first element
        tail = 1    -- index of the next insertion point
    }, queue)
    return self
end

function queue:enqueue_unique(item)
    if not contains(self.items, item) then
        self.items[self.tail] = item
        self.tail = self.tail + 1
    end

end

-- remove and return the item from the front of the queue
function queue:dequeue()
    if self:isempty() then
        return nil
    end
    local item = self.items[self.head]
    self.items[self.head] = nil -- remove reference
    self.head = self.head + 1
    return item
end

-- check if the queue is empty
function queue:isempty()
    return self.head == self.tail
end

function timer(interval)
    local last_time = t()  -- track the last time the function was called
    
    return function()
        local current_time = t()
        -- check if the interval has passed
        if current_time - last_time >= interval then
            last_time = current_time  -- update the last time to current time
            return true  -- indicate that the interval has elapsed
        end
        return false  -- indicate that the interval has not elapsed
    end
end

function processtimer(time, dt)
    return max(time - dt, 0)
end

function lerp(a, b, t)
    return a + (b - a) * t
end


-- === vector.lua ===
function isinsidepolygon(vertices, xp, yp)
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

function generatesimplepolygon(x,y,width, height)

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

function drawpolygon(polygon)
    line()
    for i = 1, #polygon do 
        line(polygon[i].x, polygon[i].y, 11)
    end
    line(polygon[1].x, polygon[1].y, 11)
end

function drawraycast(point, direction, color)

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
poke(0x5f2d, 0x1) -- enable keyboard input
chunks = {} -- 2 or 3 chunk tables
local terrain_y_offset = 0
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

function initproceduralgen()
    --set_biome_distances()
    map_x_size = biome_dist_unit.void
    rnd_terrain_seed = flr(rnd(128))
end

function generatechunk(x_offset)

    local chunk = {x = x_offset, y = 0,  tiles = {}, surface_tiles = {}}

    -- fill all cells with ground
    for x = x_offset, x_offset+chunk_x_size-1 do
        chunk.tiles[x] = {}
        for y = 0, map_y_size-1 do -- this creates 31 tiles fyi   
            if x < biome_dist_unit.grass then
                chunk.tiles[x][y] = {x = x, y = y, sprite = tile.ground}
            elseif x < biome_dist_unit.desert then
                chunk.tiles[x][y] = {x = x, y = y, sprite = tile.sand_1}
            elseif x < biome_dist_unit.mountain then
                chunk.tiles[x][y] = {x = x, y = y, sprite = tile.mountain_2}
            elseif x < biome_dist_unit.snow then
                chunk.tiles[x][y] = {x = x, y = y, sprite = tile.snow_2}
            elseif x < biome_dist_unit.city then
                chunk.tiles[x][y] = {x = x, y = y, sprite = tile.oreland_1}
            elseif x < biome_dist_unit.void then
                chunk.tiles[x][y] = {x = x, y = y, sprite = tile.hell_2}
            else
                chunk.tiles[x][y] = {x = x, y = y, sprite = tile.ground}
            end  
        end
    end

    for x = x_offset, x_offset+chunk_x_size-1 do
        for y = 0, map_y_size-1 do      
            local h = get_cell_height_at_(x) + terrain_y_offset -- normalize x to [0, 1] (remember to explain why dividing by chunk_x_size fixes sin output)
            --h = 2 * sin( ((x-1) / chunk_x_size) * 2)
            if y - groundlevel < h then
                chunk.tiles[x][y].sprite = tile.none
            end
            
        end
    end

    if x_offset == chunk_progress_x * 16 and gamestate == gstate.playerselect then
            -- do nothing 
    else 
        -- draw a holes randomly
        -- don't draw holes in the last two chunks
        if x_offset > 0 and x_offset < (map_x_size-biome_length) and rnd(1) >= 1-draw_hole_chance then
            local random_x_pos = flr(rnd(chunk_x_size-hole_width-1))
            local hole_start = x_offset + random_x_pos + 1

            for x = hole_start , hole_start + hole_width, 1 do
                for y = 0, map_y_size-1, 1 do
                    chunk.tiles[x][y].sprite = tile.none   
                end
            end
        end
    end

    -- get all surface tiles. update surface sprites if needed
    for x = x_offset, x_offset+chunk_x_size-1 do
        for y = 1, map_y_size-1 do 

            local above_tile = chunk.tiles[x][y-1]
            local target_tile = chunk.tiles[x][y]

            if above_tile.sprite == tile.none and target_tile.sprite ~= tile.none then
                add(chunk.surface_tiles, target_tile)
                
                if x < biome_dist_unit.grass then
                    target_tile.sprite = tile.grass
                elseif x < biome_dist_unit.desert then
                    --target_tile.sprite = tile.grass
                elseif x < biome_dist_unit.mountain then
                    target_tile.sprite = tile.mountain_1
                elseif x < biome_dist_unit.snow then
                    --do nothing
                end                    
            end
            
        end
    end


    return chunk
end

function generatecitychunk(x_offset, y_offset)
    local chunk = {x = x_offset, y = y_offset,  tiles = {}, surface_tiles = {}}

        -- fill all cells with none
    for x = x_offset, x_offset+15 do
        chunk.tiles[x] = {}
        for y = y_offset, y_offset+15 do -- this creates 31 tiles fyi   
            chunk.tiles[x][y] = {x = x, y = y, sprite = tile.none}
        end
    end

    local buildingheight = 10 -- higher is lower..
    local buildinglength = 0
    local buildingheightvariance = 0
    local signal = true

    for x = x_offset, x_offset+15 do

        if buildinglength == 4 then
            signal = not(signal)
            buildinglength = 0
        end
        buildinglength += 1 

        buildingheightvariance = flr(rnd(4))-2

        for y = y_offset, y_offset+15 do
        

            if signal and y == buildingheight + buildingheightvariance then
                chunk.tiles[x][y].sprite = tile.oreland_3
            elseif signal and y > buildingheight-1 + buildingheightvariance then
                chunk.tiles[x][y].sprite = tile.oreland_1
            end

            if y > 14 then
                chunk.tiles[x][y].sprite = tile.oreland_2
            end
            
        end
    end

    for x = x_offset, x_offset+15 do
        for y = y_offset+1, y_offset+15 do

            local above_tile = chunk.tiles[x][y-1]
            local target_tile = chunk.tiles[x][y]

            if above_tile.sprite == tile.none and target_tile.sprite ~= tile.none then
                add(chunk.surface_tiles, target_tile)
            end
            
        end
    end

    return chunk

end

function generatevoidchunk(x_offset, y_offset, startingsize)
    local chunk = {x = x_offset, y = y_offset,  tiles = {}, surface_tiles = {}}

    -- fill all cells with none
    for x = x_offset, x_offset+15 do
        chunk.tiles[x] = {}
        for y = y_offset, y_offset+15 do -- this creates 31 tiles fyi   
            chunk.tiles[x][y] = {x = x, y = y, sprite = tile.none}
        end
    end

    local asteroidcount = 3
    local next_asteroid_x = 0
    local asteroidsize = startingsize

    for i = 1, asteroidcount do

        local x = next_asteroid_x
        next_asteroid_x = next_asteroid_x + 4 + flr(rnd(2))

        local y = flr(rnd(8)) + 7

        local rnd_offset_x = flr(rnd(2))
        local rnd_offset_y = flr(rnd(2))
        createasteroid(asteroidsize, x_offset + x + rnd_offset_x , y_offset + y + rnd_offset_y, x_offset, y_offset, chunk.tiles)
       
        if i & 2 == 0 then
            asteroidsize = max(3, asteroidsize - 1)
        end

    end

    getsurfacetiles(chunk, x_offset, y_offset, 88)

    return chunk

end

function generatecloudchunk(x_offset, y_offset)
    local chunk = {x = x_offset, y = y_offset,  tiles = {}, surface_tiles = {}}

    -- fill all cells with none
    for x = x_offset, x_offset+15 do
        chunk.tiles[x] = {}
        for y = y_offset, y_offset+15 do -- this creates 31 tiles fyi   
            chunk.tiles[x][y] = {x = x, y = y, sprite = tile.cloud_1}
        end
    end

    for x = x_offset, x_offset+15 do
        for y = y_offset, y_offset+15 do      
            if y < sin( ((x-1) / 8)) + 13 and y > sin( ((x-5) / 8)) + 2  then
                chunk.tiles[x][y].sprite = tile.none
            end
            
        end
    end


    getsurfacetiles(chunk, x_offset, y_offset, -1)


    return chunk

end

function createasteroid(size, origin_x, origin_y, x_offset, y_offset, tiles)

    origin_x = min(origin_x, (x_offset + 14) - size)
    origin_y = min(origin_y, (y_offset + 14) - size+1)

    local asteroidpoly = generatesimplepolygon(origin_x * 8, origin_y * 8, size * 8, size * 8)
    add(debug_poly_render, asteroidpoly)

    local tilecount = 0

    for x = 0, size-1, 1 do
        for y = 0, size-1, 1 do

            local tile_x = origin_x + x
            local tile_y = origin_y + y

            local inpolycount = 0

            if isinsidepolygon(asteroidpoly, tile_x * 8, tile_y * 8) then
                inpolycount += 1
            end

            if isinsidepolygon(asteroidpoly, (tile_x + 1) * 8, tile_y * 8) then
                inpolycount += 1
            end

            if isinsidepolygon(asteroidpoly, (tile_x + 1) * 8, (tile_y + 1) * 8) then
                inpolycount += 1
            end

            if isinsidepolygon(asteroidpoly, tile_x * 8, (tile_y + 1)  * 8) then
                inpolycount += 1
            end

            if inpolycount >= 2 then
                tiles[tile_x][tile_y].sprite = 88
                tilecount += 1
            end

        end
    end


    if tilecount == 0 then
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

    if x <= biome_dist_unit.grass then
        return sin( ((x-1 + rnd_terrain_seed) / 16)) 
    elseif x <= biome_dist_unit.desert then
        return sin( ((x-1 + rnd_terrain_seed) / 8))
    elseif x <= biome_dist_unit.mountain then
        return sin( ((x-1 + rnd_terrain_seed) / 16)) + 4 * sin( ((x-1 + rnd_terrain_seed) / 16) * 1.5)
    elseif x <= biome_dist_unit.snow then
        return sin( ((x-1 + rnd_terrain_seed) / 16)) 
    else
        return sin( ((x-1 + rnd_terrain_seed) / 16)) 
    end

end

function getsurfacetiles(chunk, x_offset, y_offset, surface_sprite)
    -- get all surface tiles. update surface sprites if needed
    for x = x_offset, x_offset+15 do
        for y = y_offset+1, y_offset+15 do

            local above_tile = chunk.tiles[x][y-1]
            local target_tile = chunk.tiles[x][y]

            if above_tile.sprite == tile.none and target_tile.sprite ~= tile.none then
                if surface_sprite > 0 then
                    target_tile.sprite = surface_sprite               
                end
                add(chunk.surface_tiles, target_tile)
            end
            
        end
    end
end

function getrndsurfacetile(tiles)
    return tiles[flr(rnd(#tiles))+1]
end

function get_surface_tile_at_pos(x_pos)
    local x = flr(x_pos / 8)
    for y = 1, 15 do 

        local above_tile = gettile(x,y-1)
        local target_tile = gettile(x,y)

        --printh("get surface " + target_tile.tile)

        if above_tile.tile == tile.none and target_tile.tile ~= tile.none then
            return target_tile
        end
        
    end

end

function debug_draw_asteroid_polys()

    for index, poly in ipairs(debug_poly_render) do
        drawpolygon(poly)
        
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

local startingasteroidsize = 8

function initlevelload(chunk_progress_x)

    loaded_chunks = {}

    startingasteroidsize = 8
    debug_poly_render = {}
    
    x_offset = chunk_progress_x * 16 --initial
    y_offset = 0

    loadchunk()
    loadchunk()
    --loadchunk()

end

function updatechunks(chunk_progress_x)
    --printh(chunk_progress_x)        
        local new_chunk = loadchunk(x_offset, 0)
        
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

-- note: using distance to check biome won't work for secret areas
function loadchunk()
    local new_chunk = {}
    
    if x_offset >= biome_dist_unit.void then
        new_chunk = generatecloudchunk(x_offset, y_offset)

        if x_offset == biome_dist_unit.void + 16 then
            initking()
            enableufo(376 * 8, 40)
            finalbossenabled = true
        end

    elseif x_offset >= biome_dist_unit.city then
        new_chunk = generatevoidchunk(x_offset,y_offset, startingasteroidsize)
        startingasteroidsize -= 1

    elseif x_offset >= biome_dist_unit.snow then
        new_chunk = generatecitychunk(x_offset, y_offset)

        if x_offset == biome_dist_unit.snow + 16 then
            initvulture()
            enableufo((biome_dist_unit.snow + 16) * 8, 8)
        end


    else
        new_chunk = generatechunk(x_offset)

        if new_chunk.x == chunk_progress_x * 16 and gamestate == gstate.playerselect then

        else 
            
            local zombie_spawn_point = getrndsurfacetile(new_chunk.surface_tiles)
            enableactor(zombies, -1, zombie_spawn_point.x * 8, (zombie_spawn_point.y-1) * 8)
        end

        if x_offset == 64 then
           -- printh(#ufos)
            local ufo = enableufo(64 * 8, 2 * 8)
            --printh(ufo.xpos)
        end

    end
    
    add(loaded_chunks, new_chunk)
    x_offset += chunk_x_size

    --y_offset -= 2
    --setcameraypos(y_offset * 8)

    return new_chunk
end


function drawchunks()
    for chunk in all(loaded_chunks) do
        for x = chunk.x, chunk.x + chunk_x_size-1 do
            for y = chunk.y, chunk.y + chunk_y_size-1 do     

                local tile = chunk.tiles[x][y]
                if tile.sprite > 0 then -- no error was returned
                    spr(tile.sprite, tile.x * 8, tile.y * 8)
                    --debug
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

function gettile(x,y)
    local rearchunk = loaded_chunks[1]
    local forwardchunk = loaded_chunks[#loaded_chunks]

    if x < rearchunk.x or x >= forwardchunk.x + chunk_x_size or 
    y < rearchunk.y or y >= rearchunk.y + map_y_size then
        --printh("(" .. x .. "," .. y .. ") tile index is out of bounds")
        -- for some reason, get_tile calls in out of bounds (x 298-303) spike when player reaches the end.
        return {tile = -1}
    else

        local chunk = {tile = -1}

        x = flr(x)
        y = flr(y)

        -- 1. identify which chunk to search for
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

        -- 2. return tile from the correct chunk
        return chunk.tiles[x][y]
    end
end

function getsurfacetileatxpos(x_pos)

    local chunk = {tile = -1}

    local x = flr(x_pos/8)

    -- 1. identify which chunk to search for
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


function checktilecollision(new_x, new_y, x,y, is_player)
    -- convert world positions to grid positions
    local new_x_unit = new_x / 8
    local new_y_unit = new_y / 8
    local x_unit = x / 8
    local y_unit = y / 8
    local onground = false
    local hit_wall = false

    --printh(new_x)
    -- check x axis collisions
    local tile_x_1 = gettile(new_x_unit, y_unit)
    local tile_x_2 = gettile(new_x_unit, y_unit + 0.999)
    local tile_x_3 = gettile(new_x_unit + 1, y_unit)
    local tile_x_4 = gettile(new_x_unit + 1, y_unit + 0.999)

    -- check y axis collisions
    local tile_y_1 = gettile(x_unit, new_y_unit)
    local tile_y_2 = gettile(x_unit + 0.999, new_y_unit)
    local tile_y_3 = gettile(x_unit, new_y_unit + 1)
    local tile_y_4 = gettile(x_unit + 0.999, new_y_unit + 1)

    local cornercount = 0

    -- x
    if (tile_x_1 ~= nil and tile_x_2 ~= nil) and (tile_x_1.sprite ~= tile.none or tile_x_2.sprite ~= tile.none) then
        if is_player == false then -- hack, for players this stops collisions in beyond the grid in the -y direction
            new_x_unit = flr(new_x_unit) + 1 
        end 
        hit_wall = true
    elseif (tile_x_3 ~= nil and tile_x_4 ~= nil) and (tile_x_3.sprite ~= tile.none or tile_x_4.sprite ~= tile.none) then
        new_x_unit = flr(new_x_unit)
        cornercount += 1
        hit_wall = true
    end

    -- y
    if (tile_y_1 ~= nil and tile_y_2 ~= nil) and (tile_y_1.sprite ~= tile.none or tile_y_2.sprite ~= tile.none) then
        if new_y > 0 or is_player == false then -- hack, this stops collisions in beyond the grid in the -y direction
            new_y_unit = flr(new_y_unit) + 1
        end
        cornercount += 1
    elseif (tile_y_3 ~= nil and tile_y_4 ~= nil) and (tile_y_3.sprite ~= tile.none or tile_y_4.sprite ~= tile.none) then
        new_y_unit = flr(new_y_unit)
        
        onground = true
    end

    if cornercount == 2 then -- yay this fixes the corner bug
        if new_y > y then -- going down
            new_y_unit = new_y_unit - 1
        end

    end

    -- note on hack: it seems that ignoring tile collisions in the -y and -x direction allows the player to jump beyond the 
    -- camera position in the -y direction. i had to add a condition to check if the y position is greater than zero 
    -- so that players would collide with the cloud kingdom roof. if i decide to modify generation to have different heights,
    -- then this check will need to account for that.

    -- convert grid positions to world positions
    new_x = new_x_unit * 8
    new_y = new_y_unit * 8

    return {x = new_x, y = new_y, onground = onground, hit_wall = hit_wall} -- this is returning nil for some reason
end
-- === actor.lua ===

-- player variables
local playerwoncount = 0
local maxplayers = 32
local maxfallvelocity = 200

-- movement
local gravity = 15  -- gravity value
local speed = 5
local min_speed = 50
local max_speed = 65 -- camera speed is 15
local bounce_factor = -8  -- factor to bounce back after collision
local jump_acceleration_x = 10
local jump_acceleration_y = 20
local min_jump_height = 1.5
local min_jump_distance = 1.5
local max_jump_height = 12
local max_jump_distance = 8
local jump_x_velocity = 4
local bouncecharge = 0 -- [0-1]
local maxchargetime = 4 -- seconds
local hover_down_speed = 30 -- ufo
local debug = false
local players_can_release_others = false

local d_last_time = 0 -- ??


function initactorpool(actor_count, actor_table, actor_data)
    for i = 1, actor_count, 1 do
        actor_table[i] = createactor(actor_data, i)
    end
end


function createactor(actor_data, id)
    local actor = {
        id=id, 
        type = actor_data.type,
        enabled = false,
        inputdisabled = false,
        xpos = -8, 
        ypos = -8, 
        startposition = 0,
        boundsoffsetx = 0, 
        boundsoffsety = 0, 
        vx = 0, 
        vy = 0, 
        move_dir = -1,
        width = actor_data.width,
        height = actor_data.height,
        boundsoffsetx = 0,
        boundsoffsety = 0,
        onground = false, 
        bounce_charge = 0,
        jump_height = min_jump_height,
        jump_distance = min_jump_distance,
        jump_gravity = 0,
        fall_gravity = 50,
        sprite = actor_data.sprite, 
        sprite2 = actor_data.sprite2,
        disabledcount = 0,
        ai_enabled = false,
        state = 1,
        totaltimeenabled = 0,
        won = false,
        timer_1 = 0,
        capture_tracker = {},
        tracker_beam = {
            xpos = 0,
            ypos = 0,
            width = 16,
            height = 32,
            boundsoffsetx = 4,
            boundsoffsety = 28
        }
    }
    --add(keys, keyinput)
    --playercount = playercount + 1
    return actor


end

function enableactor(actor_table, id, xpos, ypos)
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
    actor.inputdisabled = false
    actor.state = 1
    actor.search_timer = 5 + flr(rnd(5)) -- ufo
    actor.ypos = ypos
    actor.xpos = xpos
    actor.bounce_charge = 0
    return actor
end

function disableactor(actor)
    actor.enabled = false
    actor.ai_enabled = false
    actor.disabledcount = actor.disabledcount + 1 -- player
    actor.totaltimeenabled = actor.totaltimeenabled + (time() - actor.totaltimeenabled)  -- player
    --actor.xpos = -8
    --actor.ypos = -8
    actor.vx = 0
    actor.vy = 0
    --disabledplayercount = disabledplayercount + 1
    --queue_respawn_bird(player.key)
end


function getnewactorposition(zombie, dt)
    if zombie.vy >= 0 then
        jump_acceleration_y = zombie.fall_gravity * 8
    else
        jump_acceleration_y = zombie.jump_gravity * 8

    end

    local zombie_new_x = zombie.xpos + zombie.vx * dt + 0.5 * jump_acceleration_x * dt * dt
    local zombie_new_y = zombie.ypos + zombie.vy * dt + 0.5 * jump_acceleration_y * dt * dt
    zombie.vx += jump_acceleration_x * dt
    zombie.vy += jump_acceleration_y * dt
    zombie.vy = min(zombie.vy, maxfallvelocity)

    return {xpos = zombie_new_x, ypos = zombie_new_y}
end

function bounceactor(actor) -- or actor?
    if actor.onground and not(actor.won) then
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
-- moveactorto()
-- automoveleftright()
-- attractactors(thisactor)

function moveleftright(actor, speed)


    actor.vx = actor.move_dir * speed
    

    if actor.xpos < camera_x + 8 then
        actor.move_dir = abs(actor.move_dir)
        actor.xpos = camera_x + 8
    elseif actor.xpos > camera_x + 110 then
        actor.move_dir = -abs(actor.move_dir)
        actor.xpos = camera_x + 110
    end

end

function checkactoroutofbounds(actor)
    if actor.xpos + 8 < camera_x - 16
    --or actor.xpos > camera_x + 200 -- we don't care about right bounds
    --or actor.ypos < camera_y  
    or actor.ypos > camera_y + 200 then
        --printh(actor.type .. " " .. actor.id .. " out of bounds")
        return true
    end

    return false
end

function drawactors(actor_table)
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
    

     -- super janky here. i should figure out how to properly do this
     return a_edges.bottom > b_edges.top and a.ypos < b.ypos and a.vy > 0
        
end

function get_edges(obj)
    -- calculate reference point
    local center_x = obj.xpos + obj.boundsoffsetx
    local center_y = obj.ypos + obj.boundsoffsety
    
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
local speed = 5

function initzombiepool(max_zombies)

    zombies = {}

    initactorpool(max_zombies, zombies, {type = "zombie", width = 1, height = 1, sprite = 108, sprite2 = 0})
    
end

function updatezombie(id, dt)

end

function update_zombies(dt)
    for index, zombie in ipairs(zombies) do

        if zombie.enabled and zombie.ai_enabled then

            if checkactoroutofbounds(zombie) then
                disableactor(zombie)
                break
            end
        
            zombie.vx = zombie.move_dir * speed

            local zombie_new_pos = getnewactorposition(zombie, dt)

            -- check new positions for collisions
            local checked_position = checktilecollision(zombie_new_pos.xpos, zombie_new_pos.ypos, zombie.xpos, zombie.ypos, false)
            zombie.onground = checked_position.onground

            if zombie.onground then
                zombie.vx = 0
                zombie.vy = 0

                if checked_position.hit_wall then

                bounceactor(zombie)
                    -- if can't bounce then
                    --zombie.move_dir = -zombie.move_dir
                    --zombie.vx = 0
                end
            end


            -- apply final position updates, if any
            zombie.xpos = checked_position.x
            --zombie.x = checked_position.x
            zombie.ypos = checked_position.y
                
        end
    end
end
-- === ufo.lua ===

local speed = 500
local min_speed = 50
local max_speed = 65 -- camera speed is 15
local hover_down_speed = 30
local vulture_down_speed = 10
local debug = false
local players_can_release_others = false

function initufopool()
    ufos = {}

    initactorpool(1, ufos, {type = "ufo", width = 8, height = 8, sprite = 109, sprite2 = 110})
end

function initking()
    ufos = {}
    final_boss_health = max(playercount, 3)
    initactorpool(1, ufos, {type = "king", width = 8, height = 8, sprite = 121, sprite2 = 122})
end

function initvulture()
    ufos = {}

    initactorpool(1, ufos, {type = "vulture", width = 8, height = 8, sprite = 125, sprite2 = 126})

    ufos[1].tracker_beam.width = 8
    ufos[1].tracker_beam.height = 8
    ufos[1].tracker_beam.boundsoffsetx = 4
    ufos[1].tracker_beam.boundsoffsety = 6

end


function enableufo(xpos, ypos)

    local ufo = enableactor(ufos, 1, xpos, ypos)
    ufo.boundsoffsetx = 4
    ufo.boundsoffsety = 4

    resetufo(ufo, xpos, ypos)

    return ufo

end


function updateufo(dt)
    local ufo = ufos[1]

    if ufo.enabled and ufo.ai_enabled then
        if ufo.state == 1 then
            
            moveleftright(ufo, 50)

            if ufo.type == "king" then
                if ufo.timer_1 == 0 then
                    enableactor(zombies, -1, ufo.xpos, ufo.ypos)
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

            ufo.timer_1 = processtimer(ufo.timer_1, dt)

        elseif ufo.state == 2 then

            if ufo.type == "ufo" then
                local tile = getsurfacetileatxpos(ufo.xpos)
                if (tile) then
                    if ufo.ypos < (tile.y - 4) * 8 then
                        ufo.vy = hover_down_speed
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

                moveleftright(ufo, 65)

                if ufo.ypos < (7) * 8 then
                    ufo.vy = vulture_down_speed
                    ufo.tracker_beam.xpos = ufo.xpos
                    ufo.tracker_beam.ypos = ufo.ypos
                else
                    ufo.vy = -vulture_down_speed
                    ufo.state = 4
                    hidecapturedactors(ufo)
                end

            end

        
        elseif ufo.state == 3 then
            ufo.timer_1 = processtimer(ufo.timer_1, dt)
            ufo.tracker_beam.xpos = ufo.xpos
            ufo.tracker_beam.ypos = ufo.ypos

            if ufo.timer_1 == 0 then
                hidecapturedactors(ufo)
                ufo.state = 4
            end                             
        elseif ufo.state == 4 then
            ufo.ypos -= max_speed * dt

            if ufo.ypos+8 <= camera_y-32 then 

                // set 0 to 1 for vulture to respawn
                if ufo.type == "vulture" and ufo.disabledcount < 0 then
                    ufo.disabledcount = ufo.disabledcount + 1
                    resetufo(ufo, camera_x + 8, 8)
                else    
                    disableactor(ufo)
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
           attractplayers(dt)
        end

        local self_new_x = ufo.xpos + ufo.vx * dt
        local self_new_y = ufo.ypos + ufo.vy * dt
        
        ufo.xpos = self_new_x
        ufo.ypos = self_new_y

    end
    
end

function resetufo(ufo, xpos, ypos)
    ufo.xpos = xpos
    ufo.ypos = ypos
    ufo.vx = 0
    ufo.vy = 0
    ufo.state = 1
    ufo.timer_1 = 5 + flr(rnd(5))
    ufo.capture_tracker = {}
end

function hidecapturedactors(ufo)
    for key, captured in pairs(ufo.capture_tracker) do
        captured.player.xpos = -8
        captured.player.ypos = -8
    end
end

function captureplayer(player)

    local ufo = ufos[1]

    if ufo.capture_tracker[player.id] == nil then
       
        ufo.capture_tracker[player.id] = {
            player = player,
            t = 0
        }

        disableactor(player)
        setdisabledplayercount(disabledplayercount + 1)

    end

end

function attractplayers(dt)

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

function drawufo()

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
            drawhearts(final_boss_health)               
        end

        if debug_mode then

            local ufo_bounds = get_edges(ufo)

            rect(ufo_bounds.left, ufo_bounds.top, ufo_bounds.right, ufo_bounds.bottom, 8)
        end

    end

end

function drawhearts(heart_count)
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
-- perserve: queue

local respawnqueue = queue.new()
local activebirdlist = {}
respawntimer = nil
--local flyposition = camera_y + 24 need to make a global var file
local birdspeed = .8

function init_respawn_birds()
    respawnqueue = queue.new()
    activebirdlist = {}
    respawntimer = nil
end

function queue_respawn_bird(player_key)
    respawnqueue:enqueue_unique({bird = {xpos = -8, ypos = -8, width = 8, height = 16, boundsoffsetx = 0, boundsoffsety = 4, sprite = 1}, playerkey = player_key})
end

function addrespawnbird()
    local respawn = respawnqueue:dequeue()
    local player = players[respawn.playerkey]
    local bird = respawn.bird
    local initxpos = camera_x + 128
    local initypos = camera_y + 20 + flr(rnd(10))
    bird.xpos = initxpos
    bird.ypos = initypos
    player.xpos = initxpos
    player.ypos = initypos + 8

    add(activebirdlist, respawn)

end

function update_respawns()

    if respawntimer() and not(respawnqueue:isempty()) then
        addrespawnbird()
    end

    local returntoqueue = nil -- move all birds across the screen
    for _, respawn in ipairs(activebirdlist) do
        local newpos = respawn.bird.xpos - birdspeed      
        respawn.bird.xpos = newpos
        local p = players[respawn.playerkey];
        p.xpos = newpos

        if newpos < camera_x - 8 then
           returntoqueue = respawn
        end
    end

    if not(returntoqueue == nil) then -- remove first bird to go out of bounds
        respawnqueue:enqueue_unique(returntoqueue)
        del(activebirdlist, returntoqueue)
    end

    

end

function draw_respawn_birds()
    for _, respawn in ipairs(activebirdlist) do
        spr(respawn.bird.sprite, respawn.bird.xpos, respawn.bird.ypos)
    end
end
-- === players.lua ===
poke(0x5f2d, 0x1) -- enable keyboard input

-- game variables
local gravity = 15  -- gravity value
local bounce_factor = -8  -- factor to bounce back after collision
local playerwoncount = 0
local maxplayers = 32
local maxfallvelocity = 200


local jump_acceleration_x = 10
local jump_acceleration_y = 20
local min_jump_height = 1.5
local min_jump_distance = 1.5
local max_jump_height = 12
local max_jump_distance = 8
local jump_x_velocity = 4
local bouncecharge = 0 -- [0-1]
local maxchargetime = 4 -- seconds

local d_last_time = 0 -- ??

-- start screen variables
local posx = 0 -- not using this
local posy = 0
local xoffset = 0
local row = 1

function initplayers()
    players = {}
    playercount = 0
    playerwoncount = 0
    init_respawn_birds()
    setdisabledplayercount(0)
    posx = 0
    posy = 16
    xoffset = 0
    row = 1
    initactorpool(32, players, {type = "player", width = 8, height = 8, sprite = 0, sprite2 = 0})
end

function disableplayer(player)
    queue_respawn_bird(player.id)
    disableactor(player)
    setdisabledplayercount(disabledplayercount + 1)
end

function enableplayer(player)
    enableactor(players, player.key, player.xpos, player.ypos)
    setdisabledplayercount(disabledplayercount - 1)
end

function createplayer(xpos, ypos, keyinput)
    local spr = nil

    if keyboard_input == 1 then
        local sprites = {32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63}
        spr = sprites[playercount + 1]
    else
        spr = player_sprite_index[keyinput]
    end

    if spr == nil then
        return nil
    end

    playercount = playercount + 1
    local p = players[playercount]
    p.id = keyinput
    p.sprite = spr
    p.xpos = xpos
    p.ypos = ypos
    players[playercount] = nil
    players[keyinput] = p     

    enableactor(players, keyinput, xpos, posy)
    add(keys, keyinput)

    return p
end

function addplayers(startingcampos_x, startingcampos_y, dt, ready)

    if ready and stat(30) then 
        local keyinput = stat(31)
        
        if not (keyinput == "\32") and not (keyinput == "\13") and not (keyinput == "\112") and playercount < 32 then 

            if not players[keyinput] then
                start_timer = 5.9 -- plus .9 so the players see "5"

                local p = createplayer(posx + startingcampos_x, posy + startingcampos_y, keyinput)    
                if p == nil then
                    return
                end
                p.startposition = posy

                posx = posx + 9
                if (posx >= 100) then
                    
                    if xoffset >= 8 then
                        xoffset = 0
                    else
                        xoffset = xoffset + 2
                    end

                    posx = xoffset

                    posy = posy + 9
                end
            end
            
            players[keyinput].ypos = players[keyinput].startposition - 2
        end
    
        -- exit player selection and start the game
        if (keyinput == "\32" and playercount > 0) then            
            return true
        end  
        
    end

    -- bounce affect 
    for key, player in pairs(players) do
            if player.ypos < player.startposition then
                player.ypos = min(player.startposition, player.ypos + (20 * dt))
            end
    end

    return false
end

function update_players(game_progress_x, game_progress_y, dt)  
    for key, player in pairs(players) do
        if player.enabled and not(player.inputdisabled) then
            if not(player.vx == 0) then
                jump_acceleration_x = 0
            else
                jump_acceleration_x = 0 -- what's this for ?? 
            end

            local player_new_pos = getnewactorposition(player, dt)

            -- check new positions for collisions
            local checked_position = checktilecollision(player_new_pos.xpos, player_new_pos.ypos, player.xpos, player.ypos, true)
            player.onground = checked_position.onground

            if player.onground then
                player.vx = 0
                player.vy = 0

                player.bounce_charge = min(player.bounce_charge + dt , maxchargetime)
                local t = player.bounce_charge / maxchargetime
                player.jump_height = lerp(min_jump_height, max_jump_height, t)
                player.jump_distance = lerp(min_jump_distance, max_jump_distance, t)
            end

            -- apply final position updates, if any
            player.xpos = min(checked_position.x, game_progress_x+128-player.width)
            player.ypos = checked_position.y

            if checkactoroutofbounds(player) then
                disableplayer(player)
                player.xpos = -8
                player.ypos = -8
                break;
            end

            -- check for respawn bird collisions
            for _, respawn in ipairs(activebirdlist) do
                if check_object_collision(player, respawn.bird) then
                    enableactor(players, respawn.playerkey, player.xpos, player.ypos) -- update this
                    setdisabledplayercount(disabledplayercount - 1)
                    del(activebirdlist, respawn)
                    break;
                end
            end   
            
            -- check for zombie collisions
            for _, zombie in ipairs(zombies) do
                if check_object_collision(player, zombie) then
                    disableplayer(player)
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
                    captureplayer(player, dt)
                end
            end


        end


    end
end

-- look up key associated with player and bounce them
function bounceplayer(key)
    
    local player = players[key]

    if not (player == nil) and not(player.inputdisabled) and player.enabled then
        bounceactor(player)
    elseif (player == nil) and gamemode == gmode.freeplay and playercount < 32 then
        createplayer(camera_x + 64, camera_y, key)
        setrespawntimer()
    end
end

function setrespawntimer()
        local timedelay = lerp(10,1,playercount/32)
        respawntimer = timer(timedelay)

end

-- === menu.lua ===


local menu_option = {
    main = 1,
    settings = 2,
    credits = 3
}

local startgamefunction = nil

local menus = {
    [menu_option.main] = {
            [1] = {text = "start", active = false, color = 6, action = function() changemenu(menu_option.settings) end},
            [2] = {text = "credits", active = false, color = 6, action = function() changemenu(menu_option.credits) end}
    },
    [menu_option.settings] = { 
        [1] = {text = "play", active = false, color = 6, action = function() startgamefunction() end},
        [2] = {text = "gamemode", active = false, color = 6, action = function() changegamemode() end},
        [3] = {text = "input mode", active = false, color = 6, action = function() changeinputmode() end},
        [4] = {text = "back", active = false, color = 6, action = function() changemenu(menu_option.main) end}
    },
    [menu_option.credits] = { 
        [1] = {text = "back", active = false, color = 6, action = function() changemenu(menu_option.main) end},
    }
}

local active_menu = menu_option.main
local active_option = 1



function initmenu(startgamecallback)
    active_menu = menu_option.main
    changeoption(1)
    startgamefunction = startgamecallback
end

function updatemenu(dt)
    
    if btnp(5) then
        menus[active_menu][active_option].action()
    end

     if btnp(2) then
        local option = active_option - 1
        if option < 1 then
            option = #menus[active_menu]
        end
        changeoption(option)
     end
     
     if btnp(3) then
        local option = active_option + 1
        if option > #menus[active_menu] then
            option = 1
        end
        changeoption(option)
     end

     if gamemode_timer > 0 then
        print(showgamemodetext().title, camera_x + 32)
        gamemode_timer = max(0, gamemode_timer - dt)
     end
end

function drawmenu()

    local x_pos = 16
    local y_pos = 60

    if active_menu == menu_option.main then
        print("\^w\^thop32", 46,16, 7)
    elseif active_menu == menu_option.settings then
        x_pos = 16
        print("\^w\^thop32", 46,16, 7)
        if active_option == 2 then
            gmodetext = showgamemodetext()
            print(gmodetext.title, x_pos + 44 ,y_pos + 10, 6)
            print(gmodetext.description, x_pos + 44 ,y_pos + 20, 6)
        elseif active_option == 3 then
            gmodetext = showinputmodetext()
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

function changeoption(option, previous_menu)

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


function changemenu(menu)
    local previous_menu = active_menu
    if menu == menu_option.main then      
       active_menu = menu_option.main     
    elseif menu == menu_option.settings then
        active_menu = menu_option.settings
    elseif menu == menu_option.credits then
        active_menu = menu_option.credits
    end

    changeoption(1, previous_menu)
end

function changegamemode()
    local nextmode = gamemode + 1
    if nextmode > 1 then
        nextmode = 0
    end

    gamemode = nextmode

    if gamemode == gstate.playerselect or gamemode == gstate.game then
        gamemode_timer = 3
    end
end

function changeinputmode()
    local nextmode = keyboard_input + 1
    if nextmode > 1 then
        nextmode = 0
    end

    keyboard_input = nextmode
end


function showgamemodetext()
    if gamemode == gmode.tournament then
        return {title = "tournament" , description = "players cannot \njoin once the game \nhas started."}
    elseif gamemode == gmode.freeplay then
        return  {title = "freeplay" , description = "players are free \nto join after the game \nhas started."}
    end
end

function showinputmodetext()
    if keyboard_input == 0 then
        return {title = "strict" , description = "characters are \nassigned to \nspecific keys."}
    elseif keyboard_input == 1 then
        return  {title = "any key" , description = "characters can be \nassigned to \nany key."}
    elseif keyboard_input == 2 then
        return  {title = "controller" , description = "characters are \nassigned to \ncontroller buttons."}
    end
end


function drawcompletemenu()

    if gameover_menu_timer > 0 then        
        if gamestate == gstate.complete then
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
    leftcounter = 0
    for i = 1, #win_order do
        xoffset = leftcounter * 32
        spr(win_order[i][1], x + 12 + xoffset, current_y)
        print(tostr(i)..indent.."\n", x + 4 + xoffset, current_y, 10)
        if leftcounter == 3 then
            current_y = current_y + line_height
        end
        leftcounter = (leftcounter + 1) % 4
        --end
    end
    
    print("\t\tcontinue in " .. flr(score_timer) .. "\n", x, y + 116, 10)
end


-- === main.lua ===
poke(0x5f2d, 0x1) -- enable keyboard input
local delta_time
local last_time
local timeuntilcameramoves = 1.5
local timeuntilrestart = 2
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
    if gamestate == gstate.complete or gamestate == gstate.gameover then
        gamestate = gstate.playerselect
    else
        gamestate = gstate.mainmenu
    end
    switchgamestate(gamestate)
end

function restart()
    cls()
    _init()
end

function switchgamestate(state)

    gamestate = state

    if gamestate == gstate.mainmenu then
        camera_x = 0
        camera_y = 0
        initmenu(startgamefrommainmenu)
        music(0, 1000, 1)
    elseif gamestate == gstate.playerselect then
        chunk_progress_x = 0
        chunk_progress_y = 0
        new_chunk_threshold = (chunk_progress_x + 1) * 128
        camera_x = chunk_progress_x * 16 * 8
        camera_y = chunk_progress_y * 16 * 8
        finalbossenabled = false
        initufopool()
        initzombiepool(5)
        init_respawn_birds()
        initproceduralgen()
        initlevelload(chunk_progress_x)
        max_distance = map_x_size * 8 - 128 + 80
        initplayers()
        win_order = {}
        timer_2 = .4
        menuitem(2, "set gamemode", function ()
            changegamemode()
        end)
        score_timer = 15
        actors = {
            [1] = players,
            [2] = zombies
        }
        music(-1, 1000, 1)
        music(4, 1000, 2)
    elseif gamestate == gstate.game then
        music(-1, 1000, 2)
        music(6, 1000, 3)
        setrespawntimer()
    elseif gamestate == gstate.complete or gamestate == gstate.gameover then
        
        gameover_menu_timer = 3

        music(0, 2000)

        for key, player in pairs(players) do
            if player.enabled == true then
                add(win_order, {player.sprite, player.disabledcount, player.totaltimeenabled})
            end
        end

        appendloserstowinorder()
    end


    
end

startgamefrommainmenu = function ()
    switchgamestate(gstate.playerselect)
end

function _update()
    local current_time = time()  -- get the current time
    delta_time = current_time - last_time  -- calculate delta time
    last_time = current_time  

    if gamestate == gstate.mainmenu then
        updatemenu(delta_time)
    elseif gamestate == gstate.playerselect then
        local complete = false

        complete = addplayers(camera_x, camera_y, delta_time, timer_2 == 0)

        if timer_2 > 0 then
            stat(31)
        end
        timer_2 = max(0, timer_2 - delta_time)        
        
        if playercount > 0 then 
            start_timer = max(0, start_timer - delta_time)
            if start_timer == 0 then
                complete = true
            end
        end

        if complete then
            switchgamestate(gstate.game)
        end
    
    elseif gamestate == gstate.game then
        if debug_mode then
            debug_controls()

            if debug_fast_travel then
                debugupdatequicktravel()
            elseif debug_player_cannon then
                debugupdateplayercannon()
            end
        else
            if timer_1 < timeuntilcameramoves then
                timer_1 += delta_time
            else 
                
                camera_x = camera_x + camera_speed * delta_time
                --printh(chunk_progress_x)
            end

            -- set current area to cloud kingdom
            -- maybe use the special conditions function i was thinking about
            if current_area ~= area.cloud_kingdom then 
                current_area = area.cloud_kingdom
            else

                if finalbossenabled and not(ufos[1].enabled) then
                    switchgamestate(gstate.complete)
                end



            end

            if disabledplayercount == playercount then
                switchgamestate(gstate.gameover)
                timer_1 = 0
            end

            updateufo(delta_time)
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
            updatechunks(chunk_progress_x)
        end

        


        -- process key input
        while stat(30) do
            keyinput = stat(31)

            if (keyinput == "れ") then
                toggledebugmode()
            end

            bounceplayer(keyinput)       
        end
    elseif gamestate == gstate.gameover then

        updateufo(delta_time)
        update_players(camera_x, camera_y, delta_time)
        update_zombies(delta_time)
        resetgameaftertimer()
        gameover_menu_timer = processtimer(gameover_menu_timer, delta_time)

    elseif gamestate == gstate.complete then
        resetgameaftertimer()
        gameover_menu_timer = processtimer(gameover_menu_timer, delta_time)
        
    end
end

function _draw()
        cls()
        camera(camera_x, camera_y)
        map(0,0,0,camera_y,128,16)
        map(0,0,1024,camera_y,128,16) 
        map(0,0,2048,camera_y,128,16)
        map(0,0,3072,camera_y,128,16)
        drawchunks()
        drawufo()
        draw_respawn_birds()
        --draw_zombies()
        drawactors(zombies)
        drawactors(players)
        
    
        if debug_mode then
            debug_draw_asteroid_polys()
            
        end

        -- ui
        if gamestate == gstate.mainmenu then
            drawmenu()

        elseif gamestate == gstate.playerselect then

            rectfill(camera_x, 0, camera_x + 128, camera_y + 5, camera_y)

            print("press any button to join", camera_x + 4, camera_y, 7)

            if playercount > 0 then 
                print("starting in " .. flr(start_timer), camera_x + 4, camera_y+8, 7)
            end

            print("\^w\^thop" .. playercount, camera_x + 46,camera_y + 56, 7)

        elseif gamestate == gstate.game then

        elseif gamestate == gstate.complete or gamestate == gstate.gameover then
            drawcompletemenu()
        end

        if gamestate == gstate.game or gamestate == gstate.playerselect then
            if gamemode_timer > 0 then
                rectfill(camera_x, 0, camera_x + 128, camera_y + 5, camera_y)
                print("set gamemode to " .. showgamemodetext().title, camera_x + 16, camera_y, 7)
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

function resetgameaftertimer()
    if timer_1 < timeuntilrestart then
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

function toggledebugmode()
    debug_mode = not(debug_mode)

    if debug_mode then
        menuitem(2, "toggle fast travel", function() debugtogglequicktravel() end)
        menuitem(3, "toggle pcannon", function() debugtoggleplayercannon() end)
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

function debugtogglequicktravel()
    --debug_mode = true
    debug_fast_travel = not(debug_fast_travel)
end

function debugupdatequicktravel()
    for key, player in pairs(players) do
        if player.enabled == false then
            player.xpos = camera_x + 56
            player.ypos = camera_y + 8
        end
    end
end

function debugtoggleplayercannon()
    debug_player_cannon = not(debug_player_cannon)
end

function debugupdateplayercannon()

    if stat(34) == 1 then
        --printh(flr(mouse_x/8) .. ", " .. flr(mouse_y/8))

        local p = players[keys[key_index]]
        if p.enabled then enableplayer(p) end
        p.xpos = flr(mouse_x)
        p.ypos = flr(mouse_y)

        p.vx = 100
        p.vy = 100

    end
    
    update_players(camera_x, camera_y, delta_time)

end

function appendloserstowinorder()
    local lose_order = {}

    for key, player in pairs(players) do
        if player.enabled == false and type(player.id) ~= "number" then
            add(lose_order, {player.sprite, player.disabledcount, player.totaltimeenabled})
        end
    end

    local n = #lose_order
    for i = 1, n - 1 do
        for j = 1, n - i do
            local a = lose_order[j]
            local b = lose_order[j + 1]
            -- compare by disabledcount (ascending)
            -- if disabledcount is the same, compare by totaltimeenabled (descending)
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

__gff__
0000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000000000000000000000000000000000000000120401c0401e040200402204023040240401e0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000855008550045500655006550025500155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

