

WINDOW_W = 640
WINDOW_H = 360
WINDOW_MARGIN_W = 20
WINDOW_MARGIN_H = 20

WINDOW_TITLE = 'MOUSEHERD - LD 47'

SPRITES_PATH = 'img/sprites.png'
TILES_PATH = 'img/tiles.png'
FONT_PATH = 'img/font.png'
ICON_PATH = 'img/icon.png'

SPRITE_W = 16
SPRITE_H = 16

MIN_SCALE = 1
MAX_SCALE = 4
SCALE = 3
ANIMATION_FRAME = 0.25

STEP_TIME = 0.25
PLAYER_STEP_TIME = 0.2
PLAYER_LEVEL_COOLDOWN = 0.25

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
T_SWITCH_ON = {3,1}
T_SWITCH_OFF = {3,2}
T_GATE_ON = {3,3}
T_GATE_OFF = {3,4}

-- logical kind
K_DOOR = 'door'
K_CRATE = 'crate'
K_WALL = 'wall'
K_CHEESE = 'cheese'
K_PLAYER = 'player'
K_MOUSE = 'mouse'
K_ARROW = 'arrow'
K_SWITCH_ON = 'switch_on'
K_SWITCH_OFF = 'switch_off'
K_GATE_ON = 'gate_on'
K_GATE_OFF = 'gate_off'

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

L_SWITCH_ON = { kind = K_SWITCH_ON, tile = T_SWITCH_ON, undertile = T_SWITCH_ON, walkable = true }
L_SWITCH_OFF = { kind = K_SWITCH_OFF, tile = T_SWITCH_OFF, undertile = T_SWITCH_OFF, walkable = true }
L_GATE_ON = { kind = K_GATE_ON, tile = T_GATE_ON, undertile = T_GATE_OFF, drawable = true }
L_GATE_OFF = { kind = K_GATE_OFF, tile = T_GATE_OFF, undertile = T_GATE_OFF, walkable = true, drawable = true }

-- colors
C_WHITE = {1.0, 1.0, 1.0}
C_WALL = {115/255, 23/255, 45/255}
C_FLOOR_ODD = {166/255, 252/255, 219/255}
C_FLOOR_EVEN = {32/255, 214/255, 199/255}


-- level data
LEVEL_DATA = {
    {
        title = "WELCOME TO THE CHEESE",
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

    {
        title = "POLARITY",
        w=9,
        h=5,
        cells = {
            {L_WALL, L_WALL, L_WALL, L_WALL, L_WALL, L_WALL, L_WALL, L_CHEESE, L_WALL},
            {L_WALL, nil, nil, L_MOUSE_SOUTH, L_WALL, L_MOUSE_NORTH, nil, nil, L_WALL},
            {L_DOOR, nil, nil, nil, L_PLAYER, nil, nil, nil, L_WALL},
            {L_WALL, L_MOUSE_NORTH, nil, nil, L_WALL, nil, nil, L_MOUSE_SOUTH, L_WALL},
            {L_WALL, L_CHEESE, L_WALL, L_WALL, L_WALL, L_WALL, L_WALL, L_WALL, L_WALL},
        },
    },

    {
        title = "CYCLES",
        w=7,
        h=5,
        cells = {
            {L_MOUSE_EAST, nil, L_WALL, nil, nil, nil, nil},
            {nil, nil, nil, nil, L_WALL, nil, L_CHEESE},
            {L_PLAYER, L_WALL, L_MOUSE_NORTH, nil, nil, L_MOUSE_SOUTH, L_DOOR},
            {nil, nil, nil, L_WALL, nil, nil, L_CHEESE},
            {L_WALL, nil, L_MOUSE_WEST, nil, nil, L_WALL, nil},
        }
    },

    {
        title = "LOOPS",
        w=5, h=6,
        cells = {
            {nil, nil, nil, L_MOUSE_SOUTH, L_WALL},
            {nil, L_WALL, L_CHEESE, nil, L_PLAYER},
            {nil, nil, nil, nil, L_MOUSE_SOUTH},
            {L_MOUSE_NORTH, nil, nil, nil, nil},
            {L_DOOR, nil, L_CHEESE, L_WALL, nil},
            {L_WALL, L_MOUSE_NORTH, nil, nil},
        },
    },

    {
        title = "CHEESE FRIEND",
        w=6,
        h=6,
        cells = {
            {L_MOUSE_NORTH, L_PLAYER, nil, nil, nil, nil},
            {L_WALL, L_WALL, L_WALL, L_WALL, L_WALL, nil},
            {nil, nil, nil, nil, nil, nil},
            {nil, L_WALL, L_WALL, L_WALL, L_WALL, L_WALL},
            {nil, nil, nil, nil, nil, nil, nil},
            {L_WALL, L_WALL, L_WALL, L_WALL, L_CHEESE, L_DOOR},
        },
    },


    {
        title = "PRESS SHIFT",
        w=5,
        h=4,
        cells = {
            {nil, L_WALL, L_DOOR, L_WALL, nil},
            {nil, L_PLAYER, L_MOUSE_EAST, nil, nil},
            {nil, L_WALL, L_CHEESE, L_WALL, nil},
            {L_WALL,L_WALL,L_WALL,L_WALL,L_WALL},
        }
    },

    {
        title = "AN ARROW IS REQUIRED",
        w=9,
        h=3,
        cells = {
            {nil, nil, nil, L_WALL, L_CHEESE, L_WALL, nil, nil, nil},
            {L_MOUSE_NORTH, nil, nil, nil, L_PLAYER, nil, L_MOUSE_NORTH, nil, nil},
            {nil, nil, nil, L_WALL, L_DOOR, L_WALL, nil, nil, nil},
        },
    },

    {
        title = "CORRIDORS OF CHEESE",
        w=7,
        h=6,
        cells = {
            {L_WALL, nil, nil, nil, L_WALL,L_DOOR,L_WALL},
            {L_CHEESE, nil, L_WALL, nil, nil,nil,L_PLAYER},
            {L_WALL, nil, L_WALL, nil, L_WALL,L_WALL,L_WALL},
            {nil,nil,nil,nil,nil,L_MOUSE_WEST,L_WALL},
            {nil,L_WALL,nil,L_WALL,L_WALL,nil,L_WALL},
            {nil, nil,nil,L_WALL,nil,L_MOUSE_EAST,nil},
        }
    },


    {
        title = "ROUND AND ROUND",
        w=6,
        h=6,
        cells = {
            {L_CHEESE, L_PLAYER, nil, L_MOUSE_EAST, nil, L_MOUSE_EAST},
            {L_WALL, L_WALL, L_MOUSE_WEST, nil, L_MOUSE_WEST, nil},
            {nil, L_MOUSE_NORTH, L_WALL, nil, nil, L_WALL},
            {L_MOUSE_SOUTH, nil, nil, L_CHEESE, nil, L_CHEESE},
            {nil, L_MOUSE_NORTH, nil, nil, nil, nil},
            {L_MOUSE_SOUTH, nil, L_WALL, L_CHEESE, nil, L_DOOR},
        },
    },

    {
        title = "MORAL OF THE STORY",
        w=6,
        h=6,
        cells = {
            {L_PLAYER, nil, nil, nil, L_WALL, nil},
            {nil, L_CHEESE, L_WALL, nil, nil, nil},
            {nil, L_WALL, L_WALL, L_WALL, L_WALL, nil},
            {nil, nil, L_WALL, L_DOOR, nil, L_MOUSE_NORTH},
            {L_WALL, nil, L_WALL, nil, L_WALL, nil},
            {nil, nil, nil, L_MOUSE_WEST, nil, nil},
        },
    },

    {
        title = "SWITCHING IT UP",
        w = 9,
        h = 3,
        cells = {
            {nil, L_PLAYER, nil, L_WALL, L_WALL, L_WALL, nil, L_SWITCH_ON, nil},
            {nil, L_CHEESE, nil, L_GATE_OFF, nil, L_GATE_ON, nil, L_DOOR, nil},
            {nil, nil, nil, L_WALL, L_WALL, L_WALL, L_MOUSE_EAST, L_SWITCH_OFF, nil},
        }
    },

    {
        title = "BOOTH",
        w = 10,
        h = 3,
        cells = {
            {L_WALL, L_WALL, L_WALL,
             L_MOUSE_EAST, L_GATE_ON, nil,
             L_GATE_OFF, nil, L_GATE_ON, nil},
            {L_SWITCH_OFF, L_DOOR, L_WALL,
             L_GATE_ON, nil, L_GATE_OFF,
             nil, L_GATE_ON, nil, L_GATE_OFF},
            {L_SWITCH_ON, L_PLAYER, L_WALL,
             nil, L_GATE_OFF, nil,
             L_GATE_ON, nil, L_GATE_OFF, L_CHEESE},
        },
    },

    {
        title = "LUNCH TIME",
        w=9,
        h=9,
        cells = {
            {L_PLAYER, L_WALL, L_MOUSE_SOUTH,
             L_MOUSE_SOUTH, L_MOUSE_SOUTH, L_MOUSE_SOUTH,
             L_MOUSE_SOUTH, L_MOUSE_SOUTH, L_MOUSE_SOUTH},
            {nil, L_WALL, L_MOUSE_SOUTH,
             L_MOUSE_SOUTH, L_MOUSE_SOUTH, L_MOUSE_SOUTH,
             L_MOUSE_SOUTH, L_MOUSE_SOUTH, L_MOUSE_SOUTH},
            {nil, L_WALL, L_GATE_ON,
             L_GATE_ON, L_GATE_ON, L_GATE_ON,
             L_GATE_ON, L_GATE_ON, L_GATE_ON},
            {L_SWITCH_ON, L_WALL, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE},
            {nil, nil, nil, nil, nil, nil, nil, nil, L_DOOR},
            {L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE, L_CHEESE},
            {L_GATE_ON, L_GATE_ON, L_GATE_ON,
             L_GATE_ON, L_GATE_ON, L_GATE_ON,
             L_GATE_ON, L_GATE_ON, L_GATE_ON},
            {L_MOUSE_NORTH, L_MOUSE_NORTH, L_MOUSE_NORTH,
             L_MOUSE_NORTH, L_MOUSE_NORTH, L_MOUSE_NORTH,
             L_MOUSE_NORTH, L_MOUSE_NORTH, L_MOUSE_NORTH},
            {L_MOUSE_NORTH, L_MOUSE_NORTH, L_MOUSE_NORTH,
             L_MOUSE_NORTH, L_MOUSE_NORTH, L_MOUSE_NORTH,
             L_MOUSE_NORTH, L_MOUSE_NORTH, L_MOUSE_NORTH},
        },
    },

    {
        title = "QUEUE",
        w=7, h=7,
        cells = {
            {L_MOUSE_EAST, L_SWITCH_OFF, nil, L_WALL,
             L_MOUSE_SOUTH, L_GATE_ON, L_MOUSE_NORTH},
            {L_SWITCH_ON, L_CHEESE, L_SWITCH_OFF, L_GATE_OFF,
             L_GATE_ON, L_WALL, L_GATE_ON},
            {nil, L_SWITCH_OFF, nil, L_WALL,
             L_MOUSE_SOUTH, L_WALL, L_MOUSE_NORTH},
            {L_DOOR, L_WALL, L_WALL, L_WALL,
             L_GATE_ON, L_WALL, L_GATE_ON},
            {L_WALL, L_CHEESE, L_WALL, L_WALL,
             L_MOUSE_SOUTH, L_WALL, L_MOUSE_NORTH},
            {L_CHEESE, nil, L_CHEESE, L_WALL,
             L_GATE_ON, L_WALL, L_GATE_ON},
            {L_WALL, nil, nil, L_GATE_ON,
             nil, L_WALL, L_PLAYER},
        }
    },

    {
        title = "FORTRESS",
        w=5, h=5,
        cells = {
            { nil, nil, L_SWITCH_OFF, nil, L_MOUSE_SOUTH },
            { nil, L_PLAYER, L_GATE_ON, L_SWITCH_OFF, nil },
            { L_SWITCH_ON, L_GATE_OFF, L_CHEESE, L_GATE_ON, L_SWITCH_OFF },
            { nil, L_SWITCH_ON, L_GATE_OFF, L_DOOR, nil },
            { L_MOUSE_NORTH, nil, L_SWITCH_ON, nil, nil },
        }
    },

}

STARTING_LEVEL = 1
FINAL_LEVEL = 15
