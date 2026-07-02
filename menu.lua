

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
        return {title = "tournament" , description = "auto scrolling \ncamera. \nplayers cannot \njoin after the \ngame has started."}
    elseif gameMode == gMode.freeplay then
        return  {title = "freeplay" , description = "camera follows \nplayers. \nplayers can \njoin after the \ngame has started."}
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


function drawCompleteMenu(dt)

    if gameover_menu_timer > 0 then        
        if gameState == gstate.complete then
            print("\^w\^tyou win!", camera_x + 30, camera_y + 60, 10)
        else
            print("\^w\^tnext time...", camera_x + 20, camera_y + 60, 10)
        end
    else
        
        rectfill(camera_x, camera_y, camera_x + 128, camera_y + 128, 12)
        draw_winners(camera_x, camera_y, dt)
        
    end
    

end

function draw_winners(x, y, dt)

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

    -- leaderboard (full scrolling list)
    scoreboard_timer += dt
    print("leaderboard", x + 42, y + 30, 7)
    clip(0, 36, 128, 80)
    local speed = 20
    local overflow = #win_order * 8 - 80
    if overflow > 0 then
        if scroll_y >= overflow then
            scroll_y = overflow
            if scoreboard_timer > 2 then
                scroll_y = 0
                scoreboard_timer = 0
            end
        elseif scoreboard_timer > 4 then
            scroll_y += speed * dt
            if scroll_y >= overflow then
                scroll_y = overflow
                scoreboard_timer = 0
            end
        end
    end
    for i = 1, #win_order do
        local ry = y + 36 + (i - 1) * 8 - scroll_y
        spr(win_order[i][1], x + 8, ry)
        print(win_order[i][3], x + 96, ry + 1, 10)
    end
    clip()

    -- countdown footer
    local countdown_str = "continue in " .. flr(score_timer)
    local cw = #countdown_str * 4
    print(countdown_str, x + flr((128 - cw) / 2), y + 120, 10)

end

function initCompleteMenu()
    -- Compute total game time
    game_elapsed_time = time() - game_start_time
    scoreboard_timer = 0
    scroll_y = 0

    -- Finalize totalTimeEnabled for still-enabled players
    for key, player in pairs(players) do
        if player.enabled == true then
            player.totalTimeEnabled = player.totalTimeEnabled + (time() - player.last_enabled_time)
        end
    end

    -- Build win_order: ALL players sorted by score descending
    win_order = {}
    for _, key in ipairs(keys) do
        local player = players[key]
        if player then
            local score = flr(player.totalTimeEnabled) * 10 + player.reviveCount * 100 + player.kingHits * 50
            add(win_order, {player.sprite, player.disabledCount, score, player.reviveCount})
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