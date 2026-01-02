
-- player variables
players = {}
keys = {}
key_index = 1 -- used for sorting through keys
playerCount = 0
local playerWonCount = 0
local maxPlayers = 32
local maxFallVelocity = 200
disabledPlayerCount = 0

-- movement
local GRAVITY = 15  -- Gravity value
local SPEED = 5
local MIN_SPEED = 50
local MAX_SPEED = 65 -- camera speed is 15
local BOUNCE_FACTOR = -8  -- Factor to bounce back after collision
local jump_acceleration_x = 10
local jump_acceleration_y = 20
local min_jump_height = 1.5
local min_jump_distance = 1.5
local max_jump_height = 12
local max_jump_distance = 8
local jump_x_velocity = 4
local bounceCharge = 0 -- [0-1]
local maxChargeTime = 4 -- seconds
local HOVER_DOWN_SPEED = 30 -- UFO
local debug = false
local players_can_release_others = false

local d_last_time = 0 -- ??


function initActorPool(actor_count, actor_table, actor_data)
    for i = 1, actor_count, 1 do
        actor_table[i] = createActor(actor_data, i)
    end
end


function createActor(actor_data, id)

    --local sprite = player_sprite_index[actor_data.id]
    local actor = {
        id=id, 
        type = actor_data.type,
        enabled = false,
        inputDisabled = false,
        xpos = 0, 
        ypos = 0, 
        startPosition = 0,
        boundsOffsetX = 0, 
        boundsOffsetY = 0, 
        vx = 0, 
        vy = 0, 
        move_dir = -1,
        width = actor_data.width,
        height = actor_data.height,
        boundsOffsetX = 0,
        boundsOffsetY = 0,
        onGround = false, 
        bounce_charge = 0,
        jump_height = min_jump_height,
        jump_distance = min_jump_distance,
        jump_gravity = 0,
        fall_gravity = 50,
        sprite = actor_data.sprite, 
        sprite2 = actor_data.sprite2,
        disabledCount = 0,
        ai_enabled = false,
        state = 1,
        totalTimeEnabled = 0,
        won = false,
        search_timer = 5, -- ufo
        capture_tracker = {},
        capture_timer = 5,
        tracker_beam = {
            xpos = 0,
            ypos = 0,
            width = 16,
            height = 32,
            boundsOffsetX = 4,
            boundsOffsetY = 28
        },
        update = nil
        }
    --add(keys, keyInput)
    --playerCount = playerCount + 1
    return actor


end

function enableActor(actor_table, id, xpos, ypos)
    local actor = nil

    if id == -1 then -- if id -1, then enable first available inactive
        for key, a in pairs(actor_table) do
            if a.enabled == false then
                actor = a
                break;
            end
        end

        if actor == nil then
            printh("no more actors available")
            return
        end
    else
        actor = actor_table[id]

        if actor == nil then
            printh("can't find actor with id " .. id)
            return
        end
    end

    actor.enabled = true
    actor.ai_enabled = true
    actor.inputDisabled = false
    actor.state = 1
    actor.search_timer = 5 + flr(rnd(5)) -- ufo
    actor.ypos = ypos
    actor.xpos = xpos
    actor.bounce_charge = 0-- may want to change this, but adding charge introduces bug
    return actor
end

function disableActor(actor)
    actor.enabled = false
    actor.ai_enabled = false
    actor.disabledCount = actor.disabledCount + 1 -- player
    actor.totalTimeEnabled = actor.totalTimeEnabled + (time() - actor.totalTimeEnabled)  -- player
    actor.xpos = -8
    actor.ypos = -8
    actor.vx = 0
    actor.vy = 0
    --disabledPlayerCount = disabledPlayerCount + 1
    --queue_respawn_bird(player.key)
end

function updateActors(dt)
    for i, actor_table in ipairs(actors) do
        
    end
    
end

function getNewActorPosition(zombie, dt)
    if zombie.vy >= 0 then
        jump_acceleration_y = zombie.fall_gravity * 8
    else
        jump_acceleration_y = zombie.jump_gravity * 8

    end

    local zombie_new_x = zombie.xpos + zombie.vx * dt + 0.5 * jump_acceleration_x * dt * dt
    local zombie_new_y = zombie.ypos + zombie.vy * dt + 0.5 * jump_acceleration_y * dt * dt
    zombie.vx += jump_acceleration_x * dt
    zombie.vy += jump_acceleration_y * dt
    zombie.vy = min(zombie.vy, maxFallVelocity)

    return {xpos = zombie_new_x, ypos = zombie_new_y}
end

function bounceActor(actor) -- or actor?
    if actor.onGround and not(actor.won) then
        local jump_dist_p1 = actor.jump_distance * .6
        local jump_dist_p2 = actor.jump_distance * .4
        local jump_velocity = (-2 * actor.jump_height * jump_x_velocity) / jump_dist_p1
        actor.jump_gravity = (2 * actor.jump_height * jump_x_velocity * jump_x_velocity)  / (jump_dist_p1 * jump_dist_p1)
        actor.fall_gravity = (2 * actor.jump_height * jump_x_velocity * jump_x_velocity)  / (jump_dist_p2 * jump_dist_p2)
        actor.vx = jump_x_velocity  * 8
        actor.vy = jump_velocity  * 8
        actor.bounce_charge = 0
        sfx(0)
        d_last_time = time()
    end
end

-- timer()
-- moveActorTo()
-- autoMoveLeftRight()
-- attractActors(thisActor)

function checkActorOutOfBounds(actor)
    if actor.xpos + 8 < camera_x - 16
    --or actor.xpos > camera_x + 200 -- we don't care about right bounds
    --or actor.ypos < camera_y  
    or actor.ypos > camera_y + 200 then
        --printh(actor.type .. " " .. actor.id .. " out of bounds")
        return true
    end

    return false
end

function drawActors(actor_table)
    for key, actor in pairs(actor_table) do
        if actor.enabled then
            spr(actor.sprite, actor.xpos, actor.ypos)
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