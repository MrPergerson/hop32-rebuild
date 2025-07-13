-- TODO
-- add debug visual to separate chunks
-- add visual for zombie spawn point (or turn off ai and gravity?)


poke(0x5F2D, 0x1) -- enable keyboard input
--poke(0x5F2D, 0x2) 

local delta_time
local last_time

local camera_x = 0
local camera_y = 0
local game_pos_x = 0
local game_pos_y = 0
local mouse_x = 0
local mouse_y = 0

function _init()
    delta_time = 0
    last_time = 0
    game_pos_x = 0
    game_pos_y = 80
    camera_x = game_pos_x
    camera_y = game_pos_y

    init_terrain_gen(10)
    max_camera_distance = (map_x_size - 16) * 8

end

function restart()
    cls()
    _init()
end

chunk_generated_callback = function(chunk)
        
end


function _update()
    local current_time = time()  -- Get the current time
    delta_time = current_time - last_time  -- Calculate delta time
    last_time = current_time  

    if debug_mode then
        debug_controls()
    else
        camera_x = game_pos_x
        camera_y = game_pos_y
    end

    -- Process key input
    while stat(30) do
        keyInput = stat(31)

        if (keyInput == "れ") then
            debug_mode = not(debug_mode)
        end

        --bouncePlayer(keyInput)       
    end
end



function _draw()
        cls()
        map(0,0,0,camera_y,128,16) -- make this repeatable
        map(0,0,1024,camera_y,128,16) -- make this repeatable
        map(0,0,2048,camera_y,128,16) -- make this repeatable
        draw_terrain()
        draw_players(gameStarted)
        
        camera(camera_x, camera_y)

        if (debug_mode) then
            --print("cpu usage: " .. stat(1) * 100 .. "%", camera_x,camera_y+8,6)
            --print("memory usage: " .. flr(stat(0)) .. "/2048 bytes bytes", camera_x,camera_y+16,6)
            --print("frame rate: " .. stat(7), camera_x,camera_y+24,6)

            rect(game_pos_x, game_pos_y, game_pos_x + 128, game_pos_y + 128, 7)
            print(game_pos_x/8 .. "," .. game_pos_y/8, game_pos_x+4, game_pos_y+4)
            print(game_pos_x/8+16 .. "," .. game_pos_y/8+16, game_pos_x + 128 + 4, game_pos_y + 128 + 4)

            mouse_x = stat(32) + camera_x
            mouse_y = stat(33) + camera_y
            rect(mouse_x, mouse_y, mouse_x + 2, mouse_y + 2)
        end       
end

function debug_controls()
    local speed = 10

    if btn(0) then
        camera_x -= speed
    end

    if btn(1) then
        camera_x += speed
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