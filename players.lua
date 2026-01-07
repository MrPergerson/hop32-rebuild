poke(0x5F2D, 0x1) -- enable keyboard input

-- game variables
local GRAVITY = 15  -- Gravity value
local BOUNCE_FACTOR = -8  -- Factor to bounce back after collision

keys = {}
key_index = 1 -- used for sorting through keys
playerCount = 0
local playerWonCount = 0
local maxPlayers = 32
local maxFallVelocity = 200
disabledPlayerCount = 0

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

--voters = {}
--votesToStart = 0

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
    disabledPlayerCount = 0
    posx = 0
    posy = 16
    xOffset = 0
    row = 1
    initActorPool(32, players, {type = "player", width = 8, height = 8, sprite = 0, sprite2 = 0})
end

function disablePlayer(player)
    queue_respawn_bird(player.id)
    disableActor(player)
    disabledPlayerCount = disabledPlayerCount + 1
    
end

function enablePlayer(player)
    enableActor(players, player.key, player.xpos,player.ypos) -- I already have the player ref??
    disabledPlayerCount = disabledPlayerCount - 1
end


function addPlayers(startingCamPos_x, startingCamPos_y, dt, ready)
    local sprites = {33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64}

    if ready and stat(30) then 
        local keyInput = stat(31)
        
        if not (keyInput == "\32") and not (keyInput == "\13") and not (keyInput == "\112") and playerCount <= 32 then 

            if not players[keyInput] then
                start_timer = 5.9 -- plus .9 so the players see "5"

                playerCount = playerCount + 1
                local p = players[playerCount]
                p.id = keyInput
                p.sprite = player_sprite_index[keyInput]
                p.xpos = 8 + posx + camera_x
                p.ypos = 8 + posy + camera_y
                p.startPosition = posy
                players[playerCount] = nil
                players[keyInput] = p     

                enableActor(players, keyInput, posx + startingCamPos_x, posy + startingCamPos_y)
                add(keys, keyInput)
                

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
            --player.x = checked_position.x
            player.ypos = checked_position.y

            if checkActorOutOfBounds(player) then
                disablePlayer(player)
                player.xpos = -8
                player.ypos = -8
            end

             -- Check for respawn bird collisions
             for _, respawn in ipairs(activeBirdList) do
                if check_object_collision(player, respawn.bird) then
                    enableActor(players, respawn.playerKey, player.xpos, player.ypos) -- update this
                    disabledPlayerCount = disabledPlayerCount - 1
                    del(activeBirdList, respawn)
                end
            end   
            
            -- Check for zombie collisions
            for _, zombie in ipairs(zombies) do
                if check_object_collision(player, zombie) then
                    disablePlayer(player)
                    player.xpos = -8
                    player.ypos = -8
                    sfx(1)
                end
            end

            for _, ufo in ipairs(ufos) do
                if check_object_collision(player, ufo) then
                    // if colliding with top of ufo, bounce
                    if check_object_collision_on_top(player, ufo) then
                        sfx(2)
                        
                        player.ypos = ufo.ypos-8  -- best way to guarantee this code runs once
                        player.vy = -100
                    end       
                end

                if (ufo.state == 3 or (ufo.type == "vulture" and ufo.state == 2)) and check_object_collision(player, ufo.tracker_beam) then
                    printh(player.id .. " " .. player.xpos .. " " .. ufo.tracker_beam.xpos)
                    capturePlayer(player, dt)
                end
            end


        end


    end
end

-- look up key associated with player and bounce them
function bouncePlayer(key)
    
    local player = players[key]

    if not (player == nil) and not(player.inputDisabled) then
        bounceActor(player)
    elseif gameMode == gMode.freeplay then
        createActor(camera_x + 64, camera_y, key)
        setRespawnTimer()
        --disablePlayer(players[key]) -- new mode?
    end
end

function setRespawnTimer()
        local timeDelay = lerp(10,1,playerCount/32)
        respawnTimer = timer(timeDelay)

end
