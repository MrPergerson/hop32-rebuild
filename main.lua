-- TODO
-- add debug visual to separate chunks
-- add visual for zombie spawn point (or turn off ai and gravity?)


poke(0x5F2D, 0x1) -- enable keyboard input
--poke(0x5F2D, 0x2) 

local delta_time
local last_time

local camera_x = 0
local camera_y = 0
local timeUntilCameraMoves = 1.5
local timeUntilRestart = 2
local camera_speed = 15
local chunk_progress_x = 0
local chunk_progress_y = 0
local new_chunk_threshold = 0
local mouse_x = 0
local mouse_y = 0



function _init()
    
    delta_time = 0
    last_time = 0
    chunk_progress_x = 15
    chunk_progress_y = 0
    new_chunk_threshold = (chunk_progress_x + 1) * 128
    camera_x = chunk_progress_x * 16 * 8
    camera_y = chunk_progress_y * 16 * 8

    initProceduralGen()
    initLevelLoad(chunk_progress_x)
    max_distance = map_x_size * 8 - 128
end

function restart()
    cls()
    _init()
end

function _update()
    local current_time = time()  -- Get the current time
    delta_time = current_time - last_time  -- Calculate delta time
    last_time = current_time  

    if gameState == gstate.startMenu then
        -- todo
        
    elseif gameState == gstate.playerSelect then
        
        local complete = initPlayers(camera_x, camera_y, delta_time)
        if complete then
            gameState = gstate.game
        end
    
    elseif gameState == gstate.game then
        if debug_mode then
            debug_controls()

            if debug_fast_travel then
                debugUpdateQuickTravel()
            end

        else
            if timeUntilCameraMoves > 0 then
                timeUntilCameraMoves -= delta_time
            else 
                
                camera_x = min(camera_x + camera_speed * delta_time, max_distance)
                --printh(chunk_progress_x)
            end

            if chunk_progress_x >= max_distance then
                gameState = gstate.complete
            end

            update_players(camera_x, camera_y, delta_time)
        end

        if camera_x >= new_chunk_threshold then
            printh("update")
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
    elseif gameState == gstate.complete then
        printh("complete")
    end

   
end



function _draw()
        cls()
        camera(camera_x, camera_y)
        map(0,0,0,camera_y,128,16) -- make this repeatable
        map(0,0,1024,camera_y,128,16) -- make this repeatable
        map(0,0,2048,camera_y,128,16) -- make this repeatable
        drawChunks()
        draw_players(gameStarted)
        
        -- UI
        if gameState == gstate.startMenu then
            -- menu functions
        elseif gameState == gstate.playerSelect then

            if playerCount > 0 then
                if startTimerVisible then 
                    print("starting in " .. flr(start_timer), camera_x + 70, camera_y, 7)
                end
                --print("ready: " .. votesToStart .. "/" .. playerCount, camera_x + 4, camera_y, 7)
            end

            rectfill(camera_x, 0, camera_x + 128, camera_y + 5, camera_y)
            print("press any button to join", camera_x + 4, camera_y, 7)

            print("\^w\^thop" .. get_player_count(), camera_x + 46,camera_y + 56)

        elseif gameState == gstate.game then
           
        end

        --print("cpu usage: " .. stat(1) * 100 .. "%", camera_x,camera_y+8,6)
        --print("memory usage: " .. flr(stat(0)) .. "/2048 bytes bytes", camera_x,camera_y+16,6)
        --print("frame rate: " .. stat(7), camera_x,camera_y+24,6)

        if (debug_mode) then
            --print("cpu usage: " .. stat(1) * 100 .. "%", camera_x,camera_y+8,6)
            --print("memory usage: " .. flr(stat(0)) .. "/2048 bytes bytes", camera_x,camera_y+16,6)
            --print("frame rate: " .. stat(7), camera_x,camera_y+24,6)

            rect(camera_x, camera_y, camera_x + 127, camera_y + 127, 7)
            print(camera_x/8 .. "," .. camera_y/8, camera_x+4, camera_y+4)
            print(camera_x/8+16 .. "," .. camera_y/8+16, camera_x + 128 + 4, camera_y + 128 + 4)

            mouse_x = stat(32) + camera_x
            mouse_y = stat(33) + camera_y
            rect(mouse_x, mouse_y, mouse_x + 2, mouse_y + 2)
        end       
end

function toggleDebugMode()
    debug_mode = not(debug_mode)

    if debug_mode then
        menuitem(1, "toggle fast travel", function() debugToggleQuickTravel() end)
    else
        menuitem(1)
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
        if player.disabled == false then
            player.x = camera_x + 56
            player.y = camera_y + 8
        end
    end

    --chunk_progress_x = camera_x 
    --chunk_progress_y = camera_y

end