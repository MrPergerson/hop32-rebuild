
local SPEED = 500
local MIN_SPEED = 50
local MAX_SPEED = 65 -- camera speed is 15
local HOVER_DOWN_SPEED = 30
local VULTURE_DOWN_SPEED = 10
local debug = false
local players_can_release_others = false

function initUFOPool()
    ufos = {}

    initActorPool(1, ufos, {type = "ufo", width = 8, height = 8, sprite = 109, sprite2 = 110})
end

function initKing()
    ufos = {}

    initActorPool(1, ufos, {type = "king", width = 8, height = 8, sprite = 121, sprite2 = 122})
end

function initVulture()
    ufos = {}

    initActorPool(1, ufos, {type = "vulture", width = 8, height = 8, sprite = 125, sprite2 = 126})

    ufos[1].tracker_beam.width = 10
    ufos[1].tracker_beam.height = 8
    ufos[1].tracker_beam.boundsOffsetX = 4
    ufos[1].tracker_beam.boundsOffsetY = 6

end


function enableUFO(xpos, ypos)

    local ufo = enableActor(ufos, 1, xpos, ypos)
    ufo.boundsOffsetX = 4
    ufo.boundsOffsetY = 4

    resetUFO(ufo, xpos, ypos)

    return ufo

end


function updateUFO(dt)

    local ufo = ufos[1]

    if ufo.enabled and ufo.ai_enabled then

        if ufo.state == 1 then
            
            moveLeftRight(ufo)

            if ufo.timer_1 == 0 and ufo.xpos > camera_x + 70 then
                ufo.vx = 0
                ufo.state = 2
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

                moveLeftRight(ufo)

                if ufo.ypos < (7) * 8 then
                    ufo.vy = VULTURE_DOWN_SPEED
                    ufo.tracker_beam.xpos = ufo.xpos
                    ufo.tracker_beam.ypos = ufo.ypos
                else
                    ufo.vy = -VULTURE_DOWN_SPEED
                    ufo.state = 4
                    disableCapturedActors(ufo)
                end

            end

        
        elseif ufo.state == 3 then
            ufo.timer_1 = processTimer(ufo.timer_1, dt)
            ufo.tracker_beam.xpos = ufo.xpos
            ufo.tracker_beam.ypos = ufo.ypos

            if ufo.timer_1 == 0 then
                disableCapturedActors(ufo)
                ufo.state = 4
            end                             
        elseif ufo.state == 4 then
            ufo.ypos -= MAX_SPEED * dt

            if ufo.ypos+8 <= camera_y-32 then 

                if ufo.type == "vulture" and ufo.disabledCount < 1 then
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
        
        local self_new_x = ufo.xpos + ufo.vx * dt
        local self_new_y = ufo.ypos + ufo.vy * dt
        
        ufo.xpos = self_new_x
        ufo.ypos = self_new_y

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

function disableCapturedActors(ufo)
    for key, captured in pairs(ufo.capture_tracker) do
        captured.player.xpos = -8
        captured.player.ypos = -8
    end
end

function attractPlayer(player, dt)

    local ufo = ufos[1]

    if ufo.capture_tracker[player.id] == nil then
       
        ufo.capture_tracker[player.id] = {
            player = player,
            t = 0
        }

        disableActor(player)
        disabledPlayerCount = disabledPlayerCount + 1

    else
        local captured = ufo.capture_tracker[player.id] 

        if ufo.type ~= "vulture" then
            player.xpos = player.xpos + (ufo.xpos - player.xpos) * min(captured.t,.2)
            player.ypos = player.ypos + ((ufo.ypos+8) - player.ypos) * min(captured.t,.2)

            captured.t += .1 * dt 

            if captured.t >= .2 then
                player.xpos = -8
                player.ypos = -8
            end
        end
    end
end

function drawUFO()

    local ufo = ufos[1]

    if ufo.enabled then
        
        spr(ufo.sprite, ufo.xpos, ufo.ypos)

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

        

        if debug_mode then

            local ufo_bounds = get_edges(ufo)

            rect(ufo_bounds.left, ufo_bounds.top, ufo_bounds.right, ufo_bounds.bottom, 8)
        end

    end

end