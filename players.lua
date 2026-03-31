poke(0x5F2D, 0x1) -- enable keyboard input

-- game variables
local GRAVITY = 15  -- Gravity value
local BOUNCE_FACTOR = -8  -- Factor to bounce back after collision
local playerWonCount = 0
local maxPlayers = 32
local maxFallVelocity = 200


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

-- start screen variables
local posx = 0 -- not using this
local posy = 0
local xOffset = 0
local row = 1

function getLeadPlayer()
    local lead = nil
    for key, player in pairs(players) do
        if player.enabled then
            if lead == nil or player.xpos > lead.xpos then
                lead = player
            end
        end
    end
    return lead
end

function initPlayers()
    players = {}
    playerCount = 0
    playerWonCount = 0
    init_respawn_birds()
    setDisabledPlayerCount(0)
    posx = 0
    posy = 16
    xOffset = 0
    row = 1
    initActorPool(32, players, {type = "player", width = 8, height = 8, sprite = 0, sprite2 = 0})
end

function disablePlayer(player, left)
    add(death_icons,{player.xpos,player.ypos,3,player.sprite,left})
    queue_respawn_bird(player.id)
    disableActor(player)
    setDisabledPlayerCount(disabledPlayerCount + 1)
end

function enablePlayer(player)
    enableActor(players, player.key, player.xpos, player.ypos)
    setDisabledPlayerCount(disabledPlayerCount - 1)
end

function createPlayer(xpos, ypos, keyInput)
    local spr = nil

    if keyboard_input == 0 or keyboard_input == 2 then
        local sprites = {32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63}
        spr = sprites[playerCount + 1]
    else
        spr = player_sprite_index[keyInput]
    end

    if spr == nil then
        return nil
    end

    playerCount = playerCount + 1
    local p = nil
    if keyboard_input == 2 then
        for i = 6, 32 do
            if players[i] ~= nil and players[i].enabled == false then
                p = players[i]
                players[i] = nil
                break
            end
        end
    else
        p = players[playerCount]
        players[playerCount] = nil
    end

    if p == nil then
        return nil
    end

    p.id = keyInput
    p.sprite = spr
    p.xpos = xpos
    p.ypos = ypos
    players[keyInput] = p

    enableActor(players, keyInput, xpos, posy)
    add(keys, keyInput)

    return p
end

function addPlayers(startingCamPos_x, startingCamPos_y, dt, ready)
    local function joinPlayer(keyInput)
        start_timer = 5.9
        local p = createPlayer(posx + startingCamPos_x, posy + startingCamPos_y, keyInput)
        if p == nil then return nil end
        p.startPosition = posy
        posx = posx + 9
        if posx >= 100 then
            xOffset = xOffset >= 8 and 0 or xOffset + 2
            posx = xOffset
            posy = posy + 9
        end
        return p
    end

    if keyboard_input ~= 2 then
        if ready and stat(30) then
            local keyInput = stat(31)
            if not (keyInput == "\32") and not (keyInput == "\13") and not (keyInput == "\112") and playerCount < 32 then
                if not players[keyInput] then
                    if joinPlayer(keyInput) == nil then return end
                end
                players[keyInput].ypos = players[keyInput].startPosition - 2
            end
            if keyInput == "\32" and playerCount > 0 then return true end
        end
    else
        if ready then
            for b = 0, 5 do
                local joined = players[b] ~= nil and players[b].enabled == true
                if btnp(b, 0) and not joined and playerCount < 6 then
                    joinPlayer(b)
                elseif joined then
                    players[b].ypos = players[b].startPosition - 2
                end
            end
        end
    end

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
            player.ypos = checked_position.y

            if checkActorOutOfBounds(player) then
                disablePlayer(player, player.xpos+8<camera_x)
                player.xpos = -8
                player.ypos = -8
                break;
            end

            -- Check for respawn bird collisions
            for _, respawn in ipairs(activeBirdList) do
                if check_object_collision(player, respawn.bird) then
                    enableActor(players, respawn.playerKey, player.xpos, player.ypos) -- update this
                    setDisabledPlayerCount(disabledPlayerCount - 1)
                    del(activeBirdList, respawn)
                    break;
                end
            end   
            
            -- Check for zombie collisions
            for _, zombie in ipairs(zombies) do
                if check_object_collision(player, zombie) then
                    disablePlayer(player)
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
                    capturePlayer(player, dt)
                end
            end


        end


    end
end

-- look up key associated with player and bounce them
function bouncePlayer(key)
    
    local player = players[key]

    if not (player == nil) and not(player.inputDisabled) and player.enabled then
        bounceActor(player)
    elseif (player == nil) and gameMode == gMode.freeplay and playerCount < 32 then
        createPlayer(camera_x + 64, camera_y, key)
        setRespawnTimer()
    end
end

function setRespawnTimer()
        local timeDelay = lerp(10,1,playerCount/32)
        respawnTimer = timer(timeDelay)

end
