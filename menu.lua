

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
        [3] = {text = "back", active = false, color = 6, action = function() changeMenu(menu_option.main) end}
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
    --startGameCallback()
    startGameFunction = startGameCallback
    --startGameFunction()
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
        print("\^w\^thop32", 46,16, 6)
    elseif active_menu == menu_option.settings then
        --print("\^w\^tsettings", 46,16, 6)
        x_pos = 16
        
        gmodetext = showGameModeText()
        print(gmodetext.title, x_pos + 40 ,y_pos + 10, 6)
        print(gmodetext.description, x_pos + 40 ,y_pos + 20, 6)
        
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

function showGameModeText()
    if gameMode == gMode.tournament then
        return {title = "tournament" , description = "players cannot \njoin once the game \nhas started."}
    elseif gameMode == gMode.freeplay then
        return  {title = "freeplay" , description = "players are free \nto join after the game \nhas started."}
    end
end

