local respawnQueue = Queue.new()
local activeBirdList = {}
respawnTimer = nil
--local flyPosition = camera_y + 24 need to make a global var file
local birdSpeed = .8

function init_respawn_birds()
    respawnQueue = Queue.new()
    activeBirdList = {}
    respawnTimer = nil
end

function queue_respawn_bird(player_key)
    respawnQueue:enqueue_unique({bird = {xpos = -8, ypos = -8, width = 8, height = 16, boundsOffsetX = 0, boundsOffsetY = 4, sprite = 1}, playerKey = player_key})
end

function addRespawnBird()
    local respawn = respawnQueue:dequeue()
    local player = players[respawn.playerKey]
    local bird = respawn.bird
    local initXPos = camera_x + 128
    local initYPos = camera_y + 20 + flr(rnd(10))
    bird.xpos = initXPos
    bird.ypos = initYPos
    player.xpos = initXPos
    player.ypos = initYPos + 8

    add(activeBirdList, respawn)

end

function update_respawns()

    if respawnTimer() and not(respawnQueue:isempty()) then
        addRespawnBird()
    end

    local returnToQueue = nil -- move all birds across the screen
    for _, respawn in ipairs(activeBirdList) do
        local newPos = respawn.bird.xpos - birdSpeed      
        respawn.bird.xpos = newPos
        local p = players[respawn.playerKey];
        p.xpos = newPos

        if newPos < camera_x - 8 then
           returnToQueue = respawn
        end
    end

    if not(returnToQueue == nil) then -- remove first bird to go out of bounds
        respawnQueue:enqueue_unique(returnToQueue)
        del(activeBirdList, returnToQueue)
    end

    

end

function draw_respawn_birds()
    for _, respawn in ipairs(activeBirdList) do
        spr(respawn.bird.sprite, respawn.bird.xpos, respawn.bird.ypos)
    end
end