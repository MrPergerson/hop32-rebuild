
local SPEED = 500
local MIN_SPEED = 50
local MAX_SPEED = 65 -- camera speed is 15
local HOVER_DOWN_SPEED = 30
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

    initActorPool(1, ufos, {type = "vulture", width = 8, height = 8, sprite = 125, sprite2 = 122})
end


function enableUFO(xpos, ypos)

    local ufo = enableActor(ufos, 1, xpos, ypos)
    ufo.boundsOffsetX = 4
    ufo.boundsOffsetY = 4
    ufo.search_timer = 5 + flr(rnd(5))

    return ufo

end


function updateUFO(dt)

    local ufo = ufos[1]

    if ufo.enabled and ufo.ai_enabled then

        if ufo.state == 1 then
            
            if ufo.move_dir > 0 then
                ufo.vx = ufo.move_dir * MAX_SPEED
            else
                ufo.vx = ufo.move_dir * MIN_SPEED
            end

            if ufo.xpos < camera_x + 8 then
                ufo.move_dir = abs(ufo.move_dir)
                ufo.xpos = camera_x + 8
            elseif ufo.xpos > camera_x + 110 then
                ufo.move_dir = -abs(ufo.move_dir)
                ufo.xpos = camera_x + 110
            end

            ufo.search_timer = max(ufo.search_timer - dt, 0)

            if ufo.search_timer == 0 and ufo.xpos > camera_x + 70 then
                ufo.vx = 0
                ufo.state = 2
            end
           

        elseif ufo.state == 2 then
            local tile = getSurfaceTileAtXPos(ufo.xpos)
            if (tile) then
                if ufo.ypos < (tile.y - 4) * 8 then
                    ufo.vy = HOVER_DOWN_SPEED
                else
                    ufo.vy = 0
                    ufo.state = 3
                    ufo.capture_timer = 5
                    sfx(3,1)
                end
            end
        
        elseif ufo.state == 3 then
            
            ufo.capture_timer = max(ufo.capture_timer - dt, 0)
            ufo.tracker_beam.xpos = ufo.xpos
            ufo.tracker_beam.ypos = ufo.ypos

            if ufo.capture_timer == 0 then
                for key, captured in pairs(ufo.capture_tracker) do
                    
                    if (captured.t > .2) then
                        disablePlayer(captured.player)
                    else
                        captured.player.disabled = false
                    end
                end
                ufo.state = 4
            end
           
        elseif ufo.state == 4 then
            ufo.ypos -= MAX_SPEED * dt
            if ufo.ypos+8 <= camera_y then 
                disableActor(ufo)
            end                      
        end
        
        local self_new_x = ufo.xpos + ufo.vx * dt
        local self_new_y = ufo.ypos + ufo.vy * dt
        
        ufo.xpos = self_new_x
        ufo.ypos = self_new_y

        

    end
    
end

function attractPlayer(player, dt)

    local ufo = ufos[1]

    if ufo.capture_tracker[player.id] == nil then
       
        ufo.capture_tracker[player.id] = {
            player = player,
            t = 0
        }

        ufo.capture_tracker[player.id].player.inputDisabled = true
    else
        local captured = ufo.capture_tracker[player.id] 


        player.xpos = player.xpos + (ufo.xpos - player.xpos) * min(captured.t,1)
        player.ypos = player.ypos + ((ufo.ypos+8) - player.ypos) * min(captured.t,1)

        captured.t += .1 * dt 
        -- t will increase past 1 but never in calculations
        -- t is also used to determine who gets released first

    end
    
    
end

function drawUFO()

    local ufo = ufos[1]

    if ufo.enabled then
        

        if ufo.state == 3 or ufo.state == 4 then
            spr(ufo.sprite2, ufo.xpos, ufo.ypos+6)
        end

        spr(ufo.sprite, ufo.xpos, ufo.ypos)

        if debug then

            local ufo_bounds = get_edges(self)

            rect(ufo_bounds.left, ufo_bounds.top, ufo_bounds.right, ufo_bounds.bottom, 8)

            if ufo.state == 3 then
                local beam_bounds = get_edges(ufo.tracker_beam)

                rect(beam_bounds.left, beam_bounds.top, beam_bounds.right, beam_bounds.bottom, 8)
            end
        end

    end

end