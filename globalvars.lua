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
AREA = {
    GREEN_LANDS = 0,
    CLOUD_KINGDOM = 10
}
current_area = -1


TILE = {
    NONE = 0,
    GRASS = 2,
    GROUND = 3,
    WALL = 4,
    SAND_1 = 93,
    SAND_2 = 94,
    SAND_3 = 95,
    MOUNTAIN_1 = 96,
    MOUNTAIN_2 = 97,
    MOUNTAIN_3 = 99,
    SNOW_1 = 99,
    SNOW_2 = 100,
    SNOW_3 = 101,
    ORELAND_1 = 102,
    ORELAND_2 = 103,
    ORELAND_3 = 104,
    HELL_1 = 105,
    HELL_2 = 106,
    HELL_3 = 107,
    CLOUD_1 = 89,
    CLOUD_2 = 90,
    CLOUD_3 = 91,
    CLOUD_4 = 92
}

BIOME_DIST_UNIT = {
    GRASS = 0,
    DESERT = 0,
    MOUNTAIN = 0,
    SNOW = 0,
    ORELAND = 0,
    HELL = 0
}