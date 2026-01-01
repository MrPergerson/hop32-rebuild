poke(0x5F2D, 0x1) -- enable keyboard input

-- game variables
local GRAVITY = 15  -- Gravity value
local BOUNCE_FACTOR = -8  -- Factor to bounce back after collision
players = {}
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
    initActorPool(32, players, {sprite = 0, sprite2 = 0})
end

function disablePlayer(player)
    disableActor(player)
    disabledPlayerCount = disabledPlayerCount + 1
    queue_respawn_bird(player.key)
    
end

function enablePlayer(player)
    enableActor(players, player.key, 0,0) -- I already have the player ref??
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
        if player.enabled then
            if not(player.vx == 0) then
                jump_acceleration_x = 0
            else
                jump_acceleration_x = 0 -- what's this for ?? 
            end

            if player.vy >= 0 then
                jump_acceleration_y = player.fall_gravity * 8
            else
                jump_acceleration_y = player.jump_gravity * 8

            end

            player_new_x = player.xpos + player.vx * dt + 0.5 * jump_acceleration_x * dt * dt
            player_new_y = player.ypos + player.vy * dt + 0.5 * jump_acceleration_y * dt * dt
            player.vx += jump_acceleration_x * dt
            player.vy += jump_acceleration_y * dt
            player.vy = min(player.vy, maxFallVelocity)


            -- Check new positions for collisions
            local checked_position = checkTileCollision(player_new_x, player_new_y, player.xpos, player.ypos, true)
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

            if player.xpos < camera_x-16 then
                disablePlayer(player)
            elseif player.ypos >= camera_y + 128 then
                disablePlayer(player)
            end

             -- Check for respawn bird collisions
             for _, respawn in ipairs(activeBirdList) do
                if check_object_collision(player, respawn.bird) then
                    enableActor(players, respawn.playerKey, player.xpos, player.ypos) -- update this
                    del(activeBirdList, respawn)
                end
            end   
            
            -- Check for zombie collisions
            for _, zombie in ipairs(zombies) do
                if check_object_collision(player, zombie) then
                    disablePlayer(player)
                    sfx(1)
                end
            end

            for _, ufo in ipairs(ufos) do
                if check_object_collision(player, ufo) then
                    // if colliding with top of ufo, bounce
                    if check_object_collision_on_top(player, ufo) then
                        
                        if players_can_release_others then
                            ufo:releasePlayer()
                        end
                        
                        ufo:addToIgnoreList(player.key)
                        sfx(2)
                        
                        player.ypos = ufo.ypos-8  -- best way to guarantee this code runs once
                        player.vy = -100
                    end       
                end
            end

        end

        -- Check for ufo collisions
        for _, ufo in ipairs(ufos) do
            if ufo.state == 3 and check_object_collision(player, ufo.tracker_beam) then
                ufo:attractPlayer(player, dt)
            end
        end
    end
end

-- look up key associated with player and bounce them
function bouncePlayer(key)
    local player = players[key]
    if not (player == nil) then
        bounceActor(player)
    elseif gameMode == gMode.freeplay then
        createActor(camera_x + 64, camera_y, key)
        setRespawnTimer()
        --disablePlayer(players[key]) -- new mode?
    end
end


function draw_players()
    for key, player in pairs(players) do
        spr(player.sprite, player.xpos, player.ypos)
    end

end

function get_disabled_count()
    return disabledPlayerCount
end

function checkForOutOfBounds(leftBounds)    
    for key, player in pairs(players) do
        if player.enabled then 
            if player.ypos >= (map_y_size - 1) * 8 then
                disablePlayer(player)
            elseif player.xpos < leftBounds then
                disablePlayer(player)
            end
        end
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

function setRespawnTimer()
        local timeDelay = lerp(10,1,playerCount/32)
        respawnTimer = timer(timeDelay)

end
