
local SPEED = 500
local MIN_SPEED = 50
local MAX_SPEED = 65 -- camera speed is 15
local HOVER_DOWN_SPEED = 30
local VULTURE_DOWN_SPEED = 10

function initUFOPool()
    ufos = {}

    initActorPool(1, ufos, {type = "ufo", width = 8, height = 8, sprite = 109, sprite2 = 110})
end

function initKing()
    ufos = {}
    final_boss_health = max(playerCount, 3)
    initActorPool(1, ufos, {type = "king", width = 16, height = 16, sprite = 12, sprite2 = 122})
    ufos[1].boundsOffsetX = 8
    ufos[1].boundsOffsetY = 8
end

function initVulture()
    ufos = {}

    initActorPool(1, ufos, {type = "vulture", width = 16, height = 16, sprite = 14, sprite2 = 126})

    ufos[1].boundsOffsetX = 8
    ufos[1].boundsOffsetY = 8
    ufos[1].tracker_beam.width = 8
    ufos[1].tracker_beam.height = 8
    ufos[1].tracker_beam.boundsOffsetX = 4
    ufos[1].tracker_beam.boundsOffsetY = 6

end


function enableUFO(xpos, ypos)

    local ufo = enableActor(ufos, 1, xpos, ypos)
    --ufo.boundsOffsetX = 4
    --ufo.boundsOffsetY = 4

    resetUFO(ufo, xpos, ypos)

    return ufo

end


function updateUFO(dt)
    local ufo = ufos[1]

    if ufo.enabled and ufo.ai_enabled then
        if ufo.state == 1 then
            
            moveLeftRight(ufo, 50)

            if ufo.type == "king" then
                if ufo.timer_1 == 0 then
                    enableActor(zombies, -1, ufo.xpos, ufo.ypos)
                    ufo.timer_1 = 5
                elseif final_boss_health <= 0 then
                    ufo.state = 4
                end                
            else
                if ufo.timer_1 == 0 and ufo.xpos > camera_x + 70 then
                    ufo.vx = 0
                    ufo.state = 2
                end
            end

            ufo.timer_1 = processTimer(ufo.timer_1, dt)

        elseif ufo.state == 2 then

            if ufo.type == "ufo" then
                local tile = getSurfaceTileAtXPos(ufo.xpos)
                if (tile) then
                    if ufo.ypos < (tile.y - 4) * 8 then
                        ufo.vy = HOVER_DOWN_SPEED
                    else
                        ufo.vy = 0
                        ufo.state = 3
                        ufo.timer_1 = 5
                        sfx(3,1)
                    end
                else
                    ufo.state = 1
                end
            elseif ufo.type == "vulture" then

                moveLeftRight(ufo, 65)

                if ufo.ypos < (7) * 8 then
                    ufo.vy = VULTURE_DOWN_SPEED
                    ufo.tracker_beam.xpos = ufo.xpos
                    ufo.tracker_beam.ypos = ufo.ypos
                else
                    ufo.vy = -VULTURE_DOWN_SPEED
                    ufo.state = 4
                    hideCapturedActors(ufo)
                end

            end

        
        elseif ufo.state == 3 then
            ufo.timer_1 = processTimer(ufo.timer_1, dt)
            ufo.tracker_beam.xpos = ufo.xpos
            ufo.tracker_beam.ypos = ufo.ypos

            if ufo.timer_1 == 0 then
                hideCapturedActors(ufo)
                ufo.state = 4
            end                             
        elseif ufo.state == 4 then
            ufo.ypos -= MAX_SPEED * dt

            if ufo.ypos+8 <= camera_y-32 then 

                // set 0 to 1 for vulture to respawn
                if ufo.type == "vulture" and ufo.disabledCount < 0 then
                    ufo.disabledCount = ufo.disabledCount + 1
                    resetUFO(ufo, camera_x + 8, 8)
                else    
                    disableActor(ufo)
                    --printh("complete")
                end

                
            end                      
        end

        if ufo.type == "vulture" then
            for key, captured in pairs(ufo.capture_tracker) do
                captured.player.xpos = ufo.xpos + 4
                captured.player.ypos = ufo.ypos + 4
            end
        end
        
        if ufo.type == "ufo" then
           attractPlayers(dt)
        end

        ufo.xpos += ufo.vx * dt
        ufo.ypos += ufo.vy * dt

    end
    
end

function resetUFO(ufo, xpos, ypos)
    ufo.xpos = xpos
    ufo.ypos = ypos
    ufo.vx = 0
    ufo.vy = 0
    ufo.state = 1
    ufo.timer_1 = 5 + flr(rnd(5))
    ufo.capture_tracker = {}
end

function hideCapturedActors(ufo)
    for _, captured in pairs(ufo.capture_tracker) do
        captured.player.xpos = -8
        captured.player.ypos = -8
    end
end

function capturePlayer(player)

    local ufo = ufos[1]

    if not ufo.capture_tracker[player.id] then
       
        ufo.capture_tracker[player.id] = {
            player = player,
            t = 0
        }

        disableActor(player)
        setDisabledPlayerCount(disabledPlayerCount + 1)

    end

end

function attractPlayers(dt)

    local ufo = ufos[1]
    --local captured = ufo.capture_tracker[player.id] 

    for _, captured in pairs(ufo.capture_tracker) do
        captured.player.xpos = captured.player.xpos + (ufo.xpos - captured.player.xpos) * min(captured.t,.2)
        captured.player.ypos = captured.player.ypos + ((ufo.ypos+8) - captured.player.ypos) * min(captured.t,.2)

        captured.t += .1 * dt 

        if captured.t >= .2 then
            captured.player.xpos = -8
            captured.player.ypos = -8
        end
    end
end

function drawUFO()

    local ufo = ufos[1]

    if ufo and ufo.enabled then
        
        if ufo.type ~= "ufo" then
            spr(ufo.sprite, ufo.xpos, ufo.ypos, 2, 2)
        else
            spr(ufo.sprite, ufo.xpos, ufo.ypos, 1, 1)
        end

        if  ufo.state == 3 or ufo.state == 4 or (ufo.type == "vulture" and ufo.state == 2) then
            
            if ufo.type == "vulture" then
                spr(ufo.sprite2, ufo.xpos, ufo.ypos+4)
            else
                spr(ufo.sprite2, ufo.xpos, ufo.ypos+6)
            end

            if debug_mode then
                local beam_bounds = get_edges(ufo.tracker_beam)

                rect(beam_bounds.left, beam_bounds.top, beam_bounds.right, beam_bounds.bottom, 8)
            end
        end

        if ufo.type == "king" then
            drawHearts(final_boss_health)               
        end

        if debug_mode then

            local ufo_bounds = get_edges(ufo)

            rect(ufo_bounds.left, ufo_bounds.top, ufo_bounds.right, ufo_bounds.bottom, 8)
        end

    end

end

function drawHearts(heart_count)
    local rows = ceil((heart_count * 10) / 128)
    local hearts_left_to_draw = heart_count

    for i = 1, rows do

        local xpos = camera_x + 4
        local ypos = camera_y + 4 + (10 *(i-1))
        local hearts = 12

        if i == rows then
            hearts = hearts_left_to_draw
        end

        for j = 1, hearts do
            spr(8, xpos, ypos)
            hearts_left_to_draw -= 1
            xpos += 10
        end
        
    end


    
    -- local xpos = camera_x + 46
    -- local ypos = camera_y + 4
    -- local offset = 12
    -- rectfill(xpos - 2, ypos - 2, xpos - 2 + (offset * 3) , ypos + 9,0 )
    -- rect(xpos - 2, ypos - 2, xpos - 2 + (offset * 3) , ypos + 9, 8 )
    -- for i = 1, final_boss_health, 1 do
    --     spr(8, xpos, ypos)
    --     xpos += offset
    -- end
    
end