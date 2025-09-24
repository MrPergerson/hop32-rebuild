debug_mode = false
debug_fast_travel = false
debug_camera_x = 0 --??
debug_camera_y = 0
keyboard_input = true
gstate = {
    mainMenu = 0,
    playerSelect = 1,
    game = 2,
    complete = 3
}
gameState = gstate.playerSelect

--camera
camera_x = 0
camera_y = 0
old_camera_y_pos = 0
new_camera_y_pos = 0
new_camera_y_lerp_t = 1
new_camera_y_lerp_r = 0

function setCameraYPos(y_pos)
    old_camera_y_pos = camera_y
    new_camera_y_pos = y_pos
    new_camera_y_lerp_t = 0
end

-- progress
local AREA = {
    GREEN_LANDS = 0,
    CLOUD_KINGDOM = 10
}
current_area = -1