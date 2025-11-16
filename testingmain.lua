local debug = true

function _init()
    zombie = {} -- for testing
    testmode = false
    start_position = 0
    camera_x = start_position
    camera_y = 80
    
    last_time = 0
    delta_time = 0
    timeUntilRestart = 2
    last_time = time()
    start_time = time()

    -- level generation
    init_terrain_gen(10)
    max_camera_distance = (BIOME_DIST_UNIT.VOID + biome_length - 32) * 8

    zombie = {
        x = 20, 
        y = 90, 
        width = 8, 
        height = 8, 
        boundsOffsetX = 0, 
        boundsOffsetY = 0, 
        vx = 0, 
        vy = 0, 
        onGround = false, 
        bounce_force = minBounceForce, 
        key=70, 
        sprite = 70, 
        disabled = false,
        disabledCount = 0,
        totalTimeEnabled = 0,
        won = false
    }
end

function _update()
    local current_time = time()  -- Get the current time
    delta_time = current_time - last_time  -- Calculate delta time
    last_time = current_time  

    update_terrain_chunks()

    if testmode then
        update_players_testmode()
    else
        hop_mode()
    end

end

function _draw()
    cls()
    draw_terrain()
    camera(camera_x, camera_y)
    spr(34, zombie.x, zombie.y)

    if (debug) then
        print("cpu usage: " .. stat(1) * 100 .. "%", camera_x,camera_y+8)
        print("memory usage: " .. stat(0) .. "/2048 bytes", camera_x,camera_y+16)
        print("frame rate: " .. stat(7), camera_x,camera_y+24)
    end  

end

function update_players_testmode()
    
    camera_x = zombie.x - 56
    --camera_y = player.y + 64

    zombie.vx = 0
    zombie.vy = 0

    if btn(0) then
        zombie.vx -= 2
     end
     
     if btn(1) then
        zombie.vx += 2
     end
     
     if btn(2) then
        zombie.vy -= 2
     end
     
     if btn(3) then
        zombie.vy += 2
     end

    while stat(30) do
        keyInput = stat(31)
        if keyInput == "t" then
            testmode = false
        end        
    end

     local player_new_x = zombie.x + zombie.vx
     local player_new_y = zombie.y + zombie.vy

     checked_position = check_collision(player_new_x, player_new_y, zombie.x, zombie.y)

     zombie.x = checked_position.x
     zombie.y = checked_position.y
    
end

function hop_mode()
    camera_x += .5
    camera_x = min(camera_x, (map_x_size-16) * 8)

    -- Process key input
    while stat(30) do
        keyInput = stat(31)
        if keyInput == "t" then
            testmode = true
        elseif zombie.onGround then
            zombie.vx = 1
            zombie.vy = -3
        end
        
    end

    -- Apply gravity
    if zombie.onGround == false then
        zombie.vy += .3
    else
        if zombie.vy >= 0 then -- if just landed
            zombie.vx = 0
        end
    end
    
    local player_new_x = zombie.x + zombie.vx
    local player_new_y = zombie.y + zombie.vy

    -- Check for collisions
    local checked_position = check_collision(player_new_x, player_new_y, zombie.x, zombie.y)
    zombie.onGround = checked_position.onGround

    zombie.x = checked_position.x
    zombie.y = checked_position.y
end