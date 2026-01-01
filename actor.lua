
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
        enabled = false,
        xpos = 0, 
        ypos = 0, 
        startPosition = 0,
        width = 8, 
        height = 8, 
        boundsOffsetX = 0, 
        boundsOffsetY = 0, 
        vx = 0, 
        vy = 0, 
        move_dir = -1,
        width = 1,
        height = 1,
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
            x = 0,
            y = 0,
            width = 16,
            height = 32,
            boundsOffsetX = 4,
            boundsOffsetY = 28
        }
        }
    --add(keys, keyInput)
    --playerCount = playerCount + 1
    return actor


end

function enableActor(actor_table, id, xpos, ypos)
    local actor = nil

    if id == -1 then -- if id -1, then enable first available inactive
        for index, a in ipairs(actor_table) do
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
    actor.state = 1
    actor.search_timer = 5 + flr(rnd(5)) -- ufo
    actor.y = ypos
    actor.x = xpos
    actor.bounce_charge = 0-- may want to change this, but adding charge introduces bug
    
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
-- bounceActor()
-- advancedBounceActor()
-- attractActors(thisActor)