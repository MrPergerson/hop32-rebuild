
local camera_x = 0
local camera_y = 0
local camera_speed = 2
local game_progress_x = 0
local game_progress_y = 0
local mouse_x = 0
local mouse_y = 0
local max_level_chunks = 4
local level_chunks = 2
local editor_grid = {}

local level = {
    chunks = {},
    name = ""
}

function createChunk(x,y) 
    
    local tiles = {}
    return {
        pos_x = x,
        pos_y = y,
        surface_tiles = {}
    }
end

function createTile(x,y, tile)
    return {
        x = x,
        y = y,
        sprite = tile
    }
end

function loadNewLevel()

    -- add chunks
    for i = 0, level_chunks, 1 do
        level.chunks[i] = createChunk(i * 128, 0)
    end

end


function initEditorGrid()

    for x = 0, #level.chunks * 16, 1 do
        editor_grid[x] = {}
        for y = 0, 16, 1 do
            editor_grid[x][y] = {x = x, y = y, color = 2} -- 9 for tiles
        end
    end
end

function _init()
    --loadNewLevel()
    level = level0
    initEditorGrid()
end

function _update()
    if btn(0) then
        camera_x -= camera_speed
    end

    if btn(1) then 
        camera_x += camera_speed
    end

    local cell_x = flr(mouse_x/8)
    local cell_y = flr(mouse_y/8)

    if stat(34) == 1 then
        --printh(flr(mouse_x/8) .. ", " .. flr(mouse_y/8))


        -- find chunk to drawn in
        -- add it to tiles
        -- then draw in _draw()

        for i = 0, #level.chunks-1, 1 do
            if cell_x * 8 < level.chunks[i].pos_x + 128 then

                local surface_tiles = level.chunks[i].surface_tiles

                local found = false
                for _, tile in ipairs(surface_tiles) do
                    if tile.x == cell_x and tile.y == cell_y then
                        found = true
                    end
                end

                if not(found) then
                    add_unique(surface_tiles, {x = cell_x, y = cell_y, sprite = TILE.GRASS})
                    printh("success at " ..i .. " " ..  #level.chunks[i].surface_tiles)
                end

                break;
            end
        end

    end

    if stat(34) == 2 then
        for i = 0, #level.chunks-1, 1 do
            if cell_x * 8 < level.chunks[i].pos_x + 128 then

                local surface_tiles = level.chunks[i].surface_tiles

                local found_tile = -1
                for i, tile in ipairs(surface_tiles) do
                    if tile.x == cell_x and tile.y == cell_y then
                        found_tile = i
                    end
                end

                printh(found_tile)
                deli(level.chunks[i].surface_tiles, found_tile)
                --surface_tiles[found_tile] = {}

                break;
            end
        end
    end

     while stat(30) do
        keyInput = stat(31)

        if (keyInput == "s") then
            print_table(level, "level.txt", true, true)
        end 
    end
end

function _draw()
        cls()
        camera_x = min(max(camera_x, 0), (#level.chunks-1) * 128)
        camera(camera_x, camera_y)
        map(0,0,0,camera_y,128,16) -- make this repeatable
        map(0,0,1024,camera_y,128,16) -- make this repeatable
        map(0,0,2048,camera_y,128,16) -- make this repeatable
        --draw_terrain() -- make this usable here

        for i = 0, #level.chunks, 1 do
            local chunk = level.chunks[i]
            for index, surface_tile in pairs(chunk.surface_tiles) do
                spr(surface_tile.sprite, surface_tile.x * 8, surface_tile.y * 8)
            end
        end
        
        
        

        mouse_x = stat(32) + camera_x
        mouse_y = stat(33) + camera_y
        
        
        for x = 0, #editor_grid-1, 1 do
            for y = 0, #editor_grid[x]-1, 1 do
                local cell = editor_grid[x][y]
                 rect(cell.x * 8, cell.y * 8, cell.x * 8 + 8, cell.y * 8 + 8, cell.color)
            end
        end

        
        rect(0, 0, (#level.chunks*128)-1, 127, 7)
        rect(mouse_x, mouse_y, mouse_x + 2, mouse_y + 2)  
        
end