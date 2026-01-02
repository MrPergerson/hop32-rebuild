local SPEED = 5

function initZombiePool(max_zombies)

    zombies = {}

    initActorPool(max_zombies, zombies, {type = "zombie", width = 1, height = 1, sprite = 108, sprite2 = 0})
    
end

function updateZombie(id, dt)

end

function update_zombies(dt)
    for index, zombie in ipairs(zombies) do

        if zombie.enabled and zombie.ai_enabled then

            if checkActorOutOfBounds(zombie) then
                disableActor(zombie)
                break
            end
        
            zombie.vx = zombie.move_dir * SPEED

            local zombie_new_pos = getNewActorPosition(zombie, dt)

            -- Check new positions for collisions
            local checked_position = checkTileCollision(zombie_new_pos.xpos, zombie_new_pos.ypos, zombie.xpos, zombie.ypos, false)
            zombie.onGround = checked_position.onGround

            if zombie.onGround then
                zombie.vx = 0
                zombie.vy = 0

                if checked_position.hit_wall then

                bounceActor(zombie)
                    -- if can't bounce then
                    --zombie.move_dir = -zombie.move_dir
                    --zombie.vx = 0
                end
            end


            -- Apply final position updates, if any
            zombie.xpos = checked_position.x
            --zombie.x = checked_position.x
            zombie.ypos = checked_position.y
                
        end
    end
end