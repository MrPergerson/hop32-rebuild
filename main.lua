poke(0x5F2D, 0x1) -- enable keyboard input
local delta_time,last_time
local timeUntilCameraMoves,timeUntilRestart = 1.5,2
local timer_1,timer_2,new_chunk_threshold,mouse_x,mouse_y = 0,0,0,0,0

function updatePlayerPushedCamera(dt)
    local lead = getLeadPlayer()
    local min_advance = camera_x + tournament_mode_base_camera_speed * dt

    local target_x
    if lead ~= nil then
        target_x = lead.xpos - (128 - camera_push_cells * 8)
    else
        target_x = min_advance
    end

    -- never go backward; always apply minimum pressure
    if gameMode == gMode.tournament then
        target_x = max(target_x, min_advance)
    else
        target_x = max(target_x, 0)
    end

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
            drawCompleteMenu(delta_time)
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


