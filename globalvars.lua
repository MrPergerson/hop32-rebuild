debug_mode = false
debug_fast_travel = false
debug_player_cannon = false
debug_camera_x = 0 --??
debug_camera_y = 0
keyboard_input = true
gstate = {
    mainMenu = 0,
    playerSelect = 1,
    game = 2,
    gameover = 3,
    complete = 4
}
gameState = gstate.mainMenu

gMode = {
    tournament = 0,
    freeplay = 1
}
gameMode = gMode.tournament

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

-- timers
start_timer = 5.9
gamemode_timer = 0
score_timer = 15

-- players
win_order = {}

-- actors
ufos = {}
zombies = {}
players = {}
actors = {}

-- progress
AREA = {
    GREEN_LANDS = 0,
    CLOUD_KINGDOM = 10
}
current_area = -1
chunk_progress_x = 0
chunk_progress_y = 0
finalBossEnabled = false

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
    CLOUD_4 = 92,
    GLITCH = 88
}

-- next time don't use cumulative distance. 
-- these values should be the distance of each biome
BIOME_DIST_UNIT = {
    GRASS = 48,
    DESERT = 96,
    MOUNTAIN = 144,
    SNOW = 192,
    CITY = 240,
    VOID = 368,
    KINGDOM = 416 
}