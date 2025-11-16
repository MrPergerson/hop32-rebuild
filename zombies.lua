zombies = {}

local GRAVITY = 10  -- Gravity value
local SPEED = 5
local jump_acceleration_x = 10
local jump_acceleration_y = 20
local min_jump_height = 1.5
local min_jump_distance = 1.5
local max_jump_height = 12
local max_jump_distance = 8
local jump_x_velocity = 4
local maxFallVelocity = 200
local bounceCharge = 0 -- [0-1]
local maxChargeTime = 4 -- seconds
 
function initZombiePool(max_zombies)

    zombies = {}

    for i = 0, max_zombies, 1 do
        add(zombies, {
            id = i,
            x = 0,
            y = 0,
            vx = 0,
            vy = 0,
            width = 1,
            height = 1,
            boundsOffsetX = 0,
            boundsOffsetY = 0,
            bounce_charge = 0,
            jump_height = min_jump_height,
            jump_distance = min_jump_distance,
            jump_gravity = 0,
            fall_gravity = 50,
            sprite = 108,
            active = false,
            ai_enabled = false,
            move_dir = -1
        })
    end
end

function spawn_zombie(x,y)
    local zombie = nil
    for index, z in ipairs(zombies) do
        if z.active == false then
            zombie = z
            break; -- does this work?
        end
    end

    if zombie == nil then
        printh("no more zombies available")
        return
    end

    zombie.active = true
    zombie.x = x * 8
    zombie.y = y * 8

    
    -- spawn zombie over X seconds
    -- set timer and call function? Does this work with simultaneous spawns?
    --yield()
    -- enable zombie AI
    zombie.ai_enabled = true

end

function disable_zombie(zombie)
    zombie.x = 0
    zombie.y = 0
    zombie.active = false
    zombie.ai_enabled = false
end

function update_zombies(dt)
    for index, zombie in ipairs(zombies) do

        if zombie.x + 8 < camera_x 
        or zombie.x > camera_x + 200 
        or zombie.y < camera_y  
        or zombie.y > camera_y + 200 then
            disable_zombie(zombie)
            break
        end


        if zombie.active and zombie.ai_enabled then
        
            zombie.vx = zombie.move_dir * SPEED

            if zombie.vy >= 0 then
                jump_acceleration_y = zombie.fall_gravity * 8
            else
                jump_acceleration_y = zombie.jump_gravity * 8

            end

            zombie_new_x = zombie.x + zombie.vx * dt + 0.5 * jump_acceleration_x * dt * dt
            zombie_new_y = zombie.y + zombie.vy * dt + 0.5 * jump_acceleration_y * dt * dt
            zombie.vx += jump_acceleration_x * dt
            zombie.vy += jump_acceleration_y * dt
            zombie.vy = min(zombie.vy, maxFallVelocity)


            -- Check new positions for collisions
            local checked_position = checkTileCollision(zombie_new_x, zombie_new_y, zombie.x, zombie.y, false)
            zombie.onGround = checked_position.onGround

            if zombie.onGround then
                zombie.vx = 0
                zombie.vy = 0

                if checked_position.hit_wall then

                local jump_dist_p1 = zombie.jump_distance * .6
                local jump_dist_p2 = zombie.jump_distance * .4
                local jump_velocity = (-2 * zombie.jump_height * jump_x_velocity) / jump_dist_p1
                zombie.jump_gravity = (2 * zombie.jump_height * jump_x_velocity * jump_x_velocity)  / (jump_dist_p1 * jump_dist_p1)
                zombie.fall_gravity = (2 * zombie.jump_height * jump_x_velocity * jump_x_velocity)  / (jump_dist_p2 * jump_dist_p2)
                zombie.vx = jump_x_velocity  * 8
                zombie.vy = jump_velocity  * 8
                zombie.bounce_charge = 0

                    -- if can't bounce then
                    --zombie.move_dir = -zombie.move_dir
                    --zombie.vx = 0
                end
            end


            -- Apply final position updates, if any
            zombie.x = checked_position.x
            --zombie.x = checked_position.x
            zombie.y = checked_position.y
                
        end
    end
end

function draw_zombies()
    for index, zombie in ipairs(zombies) do
        if zombie.active then
            spr(zombie.sprite, zombie.x, zombie.y)
        end
    end
end