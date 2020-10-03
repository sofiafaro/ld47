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

    load_level(1)
end

function load_level(level_num)
    if level_num > #(LEVEL_DATA) then
        GAME_DONE = true
        level_num = 1
    end

    LEVEL = level_num
    STATE = clone(LEVEL_DATA[LEVEL])
    TIMER = STEP_TIME
    MICE = {}
    PLAYER = nil
    ARROW = nil
    DOOR = nil
    KEYSTATE = {}
    KEYPRESS = {}
    PASSIVE_KEY_ENABLED = false

    for y = 1, STATE.h do
        local row = STATE.cells[y]
        for x = 1, STATE.w do
            local cell = row[x]
            if cell then
                if cell.kind == K_PLAYER then
                    PLAYER = { x=x, y=y, cell=cell, cooldown=0 }
                elseif cell.kind == K_DOOR then
                    DOOR = { x=x, y=y, cell=cell }
                elseif cell.kind == K_MOUSE then
                    local mouse = { x=x, y=y, cell=cell }
                    table.insert(MICE, mouse)
                end
            end
        end
    end

    if not PLAYER then
        love.system.error("player not found on level " .. LEVEL)
    end
    if not DOOR then
        love.system.error("door not found on level " .. LEVEL)
    end
end

function love.update(dt)
    if KEYPRESS['r'] then
        load_level(LEVEL)
    elseif KEYPRESS['n'] then
        local nl = clamp(LEVEL+1, 1, #(LEVEL_DATA))
        load_level(nl)
    elseif KEYPRESS['p'] then
        local nl = clamp(LEVEL-1, 1, #(LEVEL_DATA))
        load_level(nl)
    end

    local player_d = PLAYER.buffered
    local player_d2 = nil
    for k,d in pairs(MOVE_KEYS) do
        if KEYPRESS[k] then
            player_d = d
            PASSIVE_KEY_ENABLED = true
        end
        if KEYSTATE[k] and PASSIVE_KEY_ENABLED then
            player_d2 = d
        end
    end

    if KEYPRESS['lshift'] or KEYPRESS['rshift'] then
        PLAYER.arrow_buf = true
    end

    if PLAYER.cooldown > dt then
        PLAYER.buffered = player_d
        PLAYER.cooldown = PLAYER.cooldown - dt
    elseif player_d or player_d2 then
        player_d = player_d or player_d2
        local dx = OFFSET_X[player_d]
        local dy = OFFSET_Y[player_d]
        local px = PLAYER.x
        local py = PLAYER.y
        local nx = clamp(PLAYER.x + dx, 1, STATE.w)
        local ny = clamp(PLAYER.y + dy, 1, STATE.h)

        if PLAYER.arrow_buf then
            ARROW = {x=px, y=py, dir=player_d}
            PLAYER.arrow_buf = false
        end

        if not STATE.cells[ny][nx] then
            STATE.cells[py][px] = nil
            STATE.cells[ny][nx] = PLAYER.cell
            PLAYER.x = nx
            PLAYER.y = ny
            PLAYER.cell.dir = player_d
        elseif STATE.cells[ny][nx].kind == K_DOOR and #(MICE) == 0 then
            load_level(LEVEL+1)
            PLAYER.cooldown = 1.0
            PLAYER.buffered = nil
            return
        end

        PLAYER.buffered = nil
        PLAYER.cooldown = PLAYER.cooldown + PLAYER_STEP_TIME - dt
    else
        PLAYER.buffered = nil
        PLAYER.cooldown = 0
    end

    TIMER = TIMER - dt
    if TIMER <= 0 then
        TIMER = TIMER + STEP_TIME
        local new_mice = {}
        for imouse, mouse in ipairs(MICE) do
            local mx = mouse.x
            local my = mouse.y
            local md = mouse.cell.dir
            if ARROW and ARROW.x == mx and ARROW.y == my then
                md = ARROW.dir
            end
            local mdone = false
            mouse.cell.moved = false
            for irot, rot in ipairs(ROT_ORDER) do
                local nd = rot[md]
                local dx = OFFSET_X[nd]
                local dy = OFFSET_Y[nd]
                local nx = clamp(mx + dx, 1, STATE.w)
                local ny = clamp(my + dy, 1, STATE.h)
                if nx ~= mx or ny ~= my then
                    local ncell = STATE.cells[ny][nx]
                    if not ncell then
                        STATE.cells[my][mx] = nil
                        STATE.cells[ny][nx] = mouse.cell
                        mouse.x = nx
                        mouse.y = ny
                        mouse.cell.dir = nd
                        mouse.cell.moved = true
                        break
                    elseif ncell.kind == K_CHEESE and (ncell.mice or 0) < 2 then
                        STATE.cells[my][mx] = nil
                        ncell.mice = (ncell.mice or 0) + 1
                        if ncell.mice == 2 then
                            ncell.tile = T_CHEESE_BOTH
                        else
                            ncell.tile = T_CHEESE_HALF[nd]
                        end
                        mdone = true
                        mouse.cell.moved = true
                        break
                    end
                end
            end
            if not mdone then
                table.insert(new_mice, mouse)
            end
        end
        MICE = new_mice
    end

    KEYPRESS = {}

    if #(MICE) == 0 then
        DOOR.cell.tile = T_DOOR_OPEN
    end
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

    if ARROW then
        draw_sprite(S_ARROW, ARROW.dir, ARROW.x, ARROW.y)
    end

    for tx = 1, grid_w do
        for ty = 1, grid_h do
            local t = STATE.cells[ty][tx]
            if t then
                if t.sprite then
                    local atx, aty = tx, ty
                    if t.moved then
                        local f = TIMER / STEP_TIME
                        atx = tx - OFFSET_X[t.dir] * f
                        aty = ty - OFFSET_Y[t.dir] * f
                    end
                    draw_sprite(t.sprite, t.dir, atx, aty)
                elseif t.tile then
                    draw_tile(t.tile, tx, ty)
                end
            end
        end
    end

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
