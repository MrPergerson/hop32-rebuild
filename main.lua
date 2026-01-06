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
        gameState = gstate.playerSelect
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
    elseif gameState == gstate.playerSelect then
        chunk_progress_x = 3
        chunk_progress_y = 0
        new_chunk_threshold = (chunk_progress_x + 1) * 128
        camera_x = chunk_progress_x * 16 * 8
        camera_y = chunk_progress_y * 16 * 8
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
    elseif gameState == gstate.game then
        setRespawnTimer()
    elseif gameState == gstate.complete or gameState == gstate.gameover then
        for key, player in pairs(players) do
            if player.disabled == false then
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

    elseif gameState == gstate.complete then
        resetGameAfterTimer()
        
    end
end

function _draw()
        cls()
        camera(camera_x, camera_y)
        map(0,0,0,camera_y,128,16) -- make this repeatable
        map(0,0,1024,camera_y,128,16) -- make this repeatable
        map(0,0,2048,camera_y,128,16) -- make this repeatable
        map(0,0,3072,camera_y,128,16) -- make this repeatable
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

            print("\^w\^thop" .. playerCount, camera_x + 46,camera_y + 56)

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

    -- add disabled players to lose_order
    for key, player in pairs(players) do
        if player.disabled then
            add(lose_order, {player.sprite, player.disabledCount, player.totalTimeEnabled})
        end
    end

    -- sort lost_order
    local n = #lose_order
    for i = 1, n - 1 do
        for j = 1, n - i do
            local a = lose_order[j]
            local b = lose_order[j + 1]
            -- Compare by disabledCount (ascending)
            -- If disabledCount is the same, compare by totalTimeEnabled (descending)
            if a[2] > b[2] or (a[2] == b[2] and a[3] < b[3]) then
                -- Swap elements if necessary
                lose_order[j], lose_order[j + 1] = lose_order[j + 1], lose_order[j]
            end
            
        end
    end

    -- append lose order to win_order
    for i = 1, #lose_order do 
        add(win_order, lose_order[i])
        -- for debug printh("Player " .. lose_order[i][1] .. " | Disabled count: " .. lose_order[i][2] .. " | TotalTimeEnabled: " .. lose_order[i][3])
    end

end

