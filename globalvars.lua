debug_mode = false
debug_fast_travel = false
debug_player_cannon = false
debug_camera_x = 0 --??
debug_camera_y = 0
keyboard_input = 0 -- 0=any key, 1=strict, 2=gamepad
gstate = {
    mainMenu = 0,
    playerSelect = 1,
    game = 2,
    gameover = 3,
    complete = 4,
    biomeTest = 5
}
gameState = gstate.mainMenu

gMode = {
    tournament = 0,
    freeplay = 1
}
gameMode = gMode.freeplay


--camera
camera_x = 0
camera_y = 0
old_camera_y_pos = 0
new_camera_y_pos = 0
new_camera_y_lerp_t = 1
new_camera_y_lerp_r = 0
camera_push_cells = 7   
camera_ease_speed = 1.5 
camera_min_speed  = 8    
tournament_mode_base_camera_speed = 250

function setCameraYPos(y_pos)
    old_camera_y_pos = camera_y
    new_camera_y_pos = y_pos
    new_camera_y_lerp_t = 0
end

-- timers
start_timer = 5.9
gamemode_timer = 0
score_timer = 15
gameover_menu_timer = 3

-- players
win_order = {}
revive_order = {}
game_start_time = 0
game_elapsed_time = 0
playerCount = 0
disabledPlayerCount = 0
keys = {}
key_index = 1 -- used for sorting through keys

function setDisabledPlayerCount(value)

    if value > playerCount then
        value = playerCount
    end

    disabledPlayerCount = value
    --printh("disPC " .. disabledPlayerCount)
end

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
final_boss_health = 4

TILE = {
    NONE = 0,
    GRASS = 96,
    GROUND = 97,
    SAND_1 = 98,
    SAND_2 = 99,
    MOUNTAIN_1 = 100,
    MOUNTAIN_2 = 101,
    SNOW_1 = 102,
    ORELAND_1 = 104,
    ORELAND_2 = 105,
    ORELAND_3 = 106,
    GLITCH = 107,
    CLOUD_1 = 108
}

biome_length = 16

BIOME_DIST_UNIT = {
        GRASS = 48,
    DESERT = 96,
    MOUNTAIN = 144,
    SNOW = 192,
    CITY = 240,
    VOID = 336,
    KINGDOM = 384 
}

-- SFX
sfx_hop = 23
sfx_player_death_to_zombie = 24

-- death icons
death_icons={}
icon_x_spr=128
icon_arrow_spr=129
icon_arrow_left_spr=130