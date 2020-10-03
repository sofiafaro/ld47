

WINDOW_W = 640
WINDOW_H = 360

WINDOW_TITLE = 'LD47 - stuck in a loop'

SPRITES_PATH = 'img/sprites.png'
TILES_PATH = 'img/tiles.png'

SPRITE_W = 16
SPRITE_H = 16
SCALE = 3

STEP_TIME = 0.2
PLAYER_STEP_TIME = 0.15

-- directions
D_NORTH = 1
D_EAST = 2
D_SOUTH = 3
D_WEST = 4

MOVE_KEYS = { up = D_NORTH, right = D_EAST, down = D_SOUTH, left = D_WEST }
OFFSET_X = { [D_NORTH] = 0, [D_EAST] = 1, [D_SOUTH] = 0, [D_WEST] = -1 }
OFFSET_Y = { [D_NORTH] = -1, [D_EAST] = 0, [D_SOUTH] = 1, [D_WEST] = 0 }

ROT_0   = { [D_NORTH] = D_NORTH, [D_EAST] = D_EAST,  [D_SOUTH] = D_SOUTH, [D_WEST] = D_WEST  }
ROT_90  = { [D_NORTH] = D_EAST,  [D_EAST] = D_SOUTH, [D_SOUTH] = D_WEST,  [D_WEST] = D_NORTH }
ROT_180 = { [D_NORTH] = D_SOUTH, [D_EAST] = D_WEST,  [D_SOUTH] = D_NORTH, [D_WEST] = D_EAST  }
ROT_270 = { [D_NORTH] = D_WEST,  [D_EAST] = D_NORTH, [D_SOUTH] = D_EAST,  [D_WEST] = D_SOUTH }
ROT_ORDER = { ROT_0, ROT_90, ROT_270, ROT_180 }

-- sprites
S_WALL = 1
S_ARROW = 2
S_MOUSE1 = 3
S_MOUSE2 = 4
S_PLAYER_STAND = 5
S_PLAYER_WALK1 = 6
S_PLAYER_WALK2 = 7

-- tiles
T_DOOR_CLOSED = {1,1}
T_DOOR_OPEN = {1,2}
T_CRATE = {1,3}
T_WALL = {1,4}
T_CHEESE_NONE = {2,1}
T_CHEESE_BOTTOM = {2,2}
T_CHEESE_TOP = {2,3}
T_CHEESE_BOTH = {2,4}
T_CHEESE_HALF = {
    [D_NORTH] = T_CHEESE_BOTTOM, [D_EAST] = T_CHEESE_BOTTOM,
    [D_SOUTH] = T_CHEESE_TOP, [D_WEST] = T_CHEESE_TOP
}

-- logical kind
K_DOOR = 'door'
K_CRATE = 'crate'
K_WALL = 'wall'
K_CHEESE = 'cheese'
K_PLAYER = 'player'
K_MOUSE = 'mouse'
K_ARROW = 'arrow'

-- logical tiles
L_NONE = nil
L_DOOR = { kind = K_DOOR, tile = T_DOOR_CLOSED }
L_CRATE = { kind = K_CRATE, tile = T_CRATE }
L_WALL = { kind = K_WALL, tile = T_WALL }

L_CHEESE_NONE = { kind = K_CHEESE, mice = 0, tile = T_CHEESE_NONE}
L_CHEESE_BOTTOM = { kind = K_CHEESE, mice = 1, tile = T_CHEESE_BOTTOM }
L_CHEESE_TOP = { kind = K_CHEESE, mice = 1, tile = T_CHEESE_TOP }
L_CHEESE_BOTH = { kind = K_CHEESE, mice = 2, tile = T_CHEESE_BOTH }
L_CHEESE = L_CHEESE_NONE

L_PLAYER_NORTH = { kind = K_PLAYER, sprite = S_PLAYER_STAND, dir = D_NORTH }
L_PLAYER_EAST  = { kind = K_PLAYER, sprite = S_PLAYER_STAND, dir = D_EAST  }
L_PLAYER_SOUTH = { kind = K_PLAYER, sprite = S_PLAYER_STAND, dir = D_SOUTH }
L_PLAYER_WEST  = { kind = K_PLAYER, sprite = S_PLAYER_STAND, dir = D_WEST  }
L_PLAYER = L_PLAYER_SOUTH

L_MOUSE_NORTH = { kind = K_MOUSE, sprite = S_MOUSE1, dir = D_NORTH }
L_MOUSE_EAST  = { kind = K_MOUSE, sprite = S_MOUSE1, dir = D_EAST  }
L_MOUSE_SOUTH = { kind = K_MOUSE, sprite = S_MOUSE1, dir = D_SOUTH }
L_MOUSE_WEST  = { kind = K_MOUSE, sprite = S_MOUSE1, dir = D_WEST  }

-- colors
C_WHITE = {1.0, 1.0, 1.0}
C_WALL = {115/255, 23/255, 45/255}
C_FLOOR_ODD = {166/255, 252/255, 219/255}
C_FLOOR_EVEN = {32/255, 214/255, 199/255}

-- level data
LEVEL_DATA = {
    {
        w = 5,
        h = 5,
        cells = {
            {nil, nil, nil, nil, nil},
            {nil, nil, L_PLAYER, nil, nil},
            {L_MOUSE_NORTH, nil, L_DOOR, nil, L_MOUSE_SOUTH},
            {nil, nil, L_CHEESE, nil, nil},
            {nil, nil, nil, nil, nil},
        },
    },
}
