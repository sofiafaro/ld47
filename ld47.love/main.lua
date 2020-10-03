require('consts')
require('util')

function love.load()
    love.window.setMode(WINDOW_W, WINDOW_H, {})
    love.window.setTitle(WINDOW_TITLE)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    KEYSTATE = {}
    KEYPRESS = {}

    SPRITES_IMAGE = load_image(SPRITES_PATH)
    SPRITES_QUADS = make_quads(SPRITES_IMAGE)

    TILES_IMAGE = load_image(TILES_PATH)
    TILES_QUADS = make_quads(TILES_IMAGE)

    KEYSTATE = {}
    KEYPRESS = {}

    LEVEL = 1
    STATE = LEVEL_DATA[LEVEL]
end

function love.update(dt)
    KEYPRESS = {}
end

function love.draw()
    local actual_sprite_w = SPRITE_W * SCALE
    local actual_sprite_h = SPRITE_H * SCALE

    local grid_w = STATE.w
    local grid_h = STATE.h
    local actual_grid_w = grid_w * actual_sprite_w
    local actual_grid_h = grid_h * actual_sprite_h
    local grid_x = (WINDOW_W - actual_grid_w) / 2
    local grid_y = (WINDOW_H - actual_grid_h) / 2

    local sprite_to_actual = function (x,y)
        return (x-1) * actual_sprite_w + grid_x, (y-1) * actual_sprite_h + grid_y
    end
    local draw_sprite = function (sprite,dir,x,y)
        local ax, ay = sprite_to_actual(x,y)
        love.graphics.draw(SPRITES_IMAGE, SPRITES_QUADS[sprite][dir], ax, ay, 0, SCALE, SCALE)
    end
    local draw_tile = function (tile,x,y)
        local row = tile[1]
        local col = tile[2]
        local ax, ay = sprite_to_actual(x,y)
        love.graphics.draw(TILES_IMAGE, TILES_QUADS[row][col], ax, ay, 0, SCALE, SCALE)
    end

    love.graphics.clear()
    love.graphics.setColor(C_WALL)
    love.graphics.rectangle('fill', 0, 0, WINDOW_W, WINDOW_H)
    love.graphics.setColor(C_FLOOR_ODD)
    love.graphics.rectangle('fill', grid_x, grid_y, actual_grid_w, actual_grid_h)
    love.graphics.setColor(C_FLOOR_EVEN)
    for tx = 1, grid_w do
        for ty = 1, grid_h do
            if (tx + ty) % 2 == 0 then
                local ax, ay = sprite_to_actual(tx, ty)
                love.graphics.rectangle('fill', ax, ay, actual_sprite_w, actual_sprite_h)
            end
        end
    end
    love.graphics.setColor(C_WHITE)

    for tx = 1, grid_w do
        for ty = 1, grid_h do
            local t = STATE.cells[ty][tx]
            if t then
                if t.sprite then
                    draw_sprite(t.sprite, t.dir, tx, ty)
                elseif t.tile then
                    draw_tile(t.tile, tx, ty)
                end
            end
        end
    end

--    draw_tile(T_DOOR_CLOSED, 2, 2)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    else
        KEYSTATE [key] = true
        KEYPRESS [key] = (KEYPRESS[key] or 0) + 1
    end
end

function love.keyreleased(key)
    KEYSTATE [key] = false
end
