require('consts')
require('util')

function love.load()
    love.window.setMode(WINDOW_W, WINDOW_H, {})
    love.window.setTitle(WINDOW_TITLE)
    love.window.setIcon(love.image.newImageData(ICON_PATH))
    love.graphics.setDefaultFilter('nearest', 'nearest')

    KEYSTATE = {}
    KEYPRESS = {}

    SPRITES_IMAGE = load_image(SPRITES_PATH)
    SPRITES_QUADS = make_quads(SPRITES_IMAGE)

    TILES_IMAGE = load_image(TILES_PATH)
    TILES_QUADS = make_quads(TILES_IMAGE)

    FONT = love.graphics.newImageFont(FONT_PATH,
        " AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz" ..
        "1234567890")

    KEYSTATE = {}
    KEYPRESS = {}

    load_main_menu()
end

function load_main_menu()
    load_level(STARTING_LEVEL)
    IN_MENU = true
    MAIN_MENU = true
    GAME_PAUSED = false
    PAUSE_MENU = false
end

function pause_game()
    if GAME_PAUSED then
        IN_MENU = false
        PAUSE_MENU = false
        GAME_PAUSED = false
    else
        IN_MENU = true
        PAUSE_MENU = true
        GAME_PAUSED = true
    end
end

function restart_level()
    load_level(LEVEL)
end

function skip_level()
    if LEVEL < FINAL_LEVEL then
        load_level(LEVEL+1)
        VALID_RUN = false
    end
end

function prev_level()
    if LEVEL > STARTING_LEVEL then
        load_level(LEVEL-1)
    end
end

function load_level(level_num)
    if level_num > #(LEVEL_DATA) then
        IN_MENU = true
        MAIN_MENU = true
        GAME_DONE = true
        level_num = 1
        RUN_TIMER_PAUSED = true
        LAST_RUN = VALID_RUN and RUN_TIMER
        if LAST_RUN and (not BEST_RUN or BEST_RUN < LAST_RUN) then
            BEST_RUN = LAST_RUN
        end
    end

    LEVEL = level_num
    STATE = clone(LEVEL_DATA[LEVEL])
    TIMER = STEP_TIME
    TICKS = 0
    MICE = {}
    ANIM_CHEESES = {}
    PLAYER = nil
    ARROW = nil
    DOOR = nil
    KEYSTATE = {}
    KEYPRESS = {}
    PASSIVE_KEY_ENABLED = false
    RUN_TIMER_PAUSED = true

    local h_scale = math.floor((WINDOW_H - WINDOW_MARGIN_H) / (SPRITE_H * STATE.h))
    local w_scale = math.floor((WINDOW_W - WINDOW_MARGIN_W) / (SPRITE_W * STATE.w))
    SCALE = clamp(math.min(h_scale, w_scale), MIN_SCALE, MAX_SCALE)

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

    PLAYER.cooldown = PLAYER_LEVEL_COOLDOWN
end

function is_walkable(x, y)
    if 1 <= x and x <= STATE.w and 1 <= y and y <= STATE.h then
        local cell = STATE.cells[y][x]
        return (not cell) or cell.walkable
    else
        return false
    end
end

function is_drawable()
    return (not PLAYER.cell.over) or PLAYER.cell.over.drawable
end

function love.update(dt)
    if VALID_RUN and (not RUN_TIMER_PAUSED) and (not GAME_PAUSED) then
        RUN_TIMER = RUN_TIMER + dt
    end

    TICKS = TICKS + dt

    -- handle input
    if MAIN_MENU then
        if KEYPRESS['return'] then
            IN_MENU = false
            GAME_PAUSED = false
            MAIN_MENU = false
            VALID_RUN = true
            RUN_TIMER = 0.0
        end
    elseif PAUSE_MENU then
        if KEYPRESS['return'] then
            IN_MENU = false
            PAUSE_MENU = false
            GAME_PAUSED = false
        elseif KEYPRESS['r'] then
            restart_level()
            IN_MENU = false
            PAUSE_MENU = false
            GAME_PAUSED = false
        elseif KEYPRESS['n'] then
            skip_level()
            IN_MENU = false
            PAUSE_MENU = false
            GAME_PAUSED = false
        elseif KEYPRESS['p'] then
            prev_level()
            IN_MENU = false
            PAUSE_MENU = false
            GAME_PAUSED = false
        end
    elseif not IN_MENU then
        if KEYPRESS['return'] then
            IN_MENU = true
            PAUSE_MENU = true
            GAME_PAUSED = true
        elseif KEYPRESS['r'] then
            restart_level()
        elseif KEYPRESS['n'] then
            skip_level()
        elseif KEYPRESS['p'] then
            prev_level()
        end
    end

    local player_d = PLAYER.buffered
    local player_d2 = nil
    if not IN_MENU then
        for k,d in pairs(MOVE_KEYS) do
            if KEYPRESS[k] then
                player_d = d
                PASSIVE_KEY_ENABLED = true
                RUN_TIMER_PAUSED = false
            end
            if KEYSTATE[k] and PASSIVE_KEY_ENABLED then
                player_d2 = d
            end
        end

        if KEYPRESS['lshift'] or KEYPRESS['rshift'] then
            PLAYER.arrow_buf = true
        end
    end

    if not GAME_PAUSED then

        local stepped_on = {}

        if PLAYER.cooldown > dt then
            PLAYER.buffered = player_d
            PLAYER.cooldown = PLAYER.cooldown - dt
        elseif PLAYER.x == DOOR.x and PLAYER.y == DOOR.y then
            load_level(LEVEL+1)
            return
        elseif player_d or player_d2 then
            player_d = player_d or player_d2
            local dx = OFFSET_X[player_d]
            local dy = OFFSET_Y[player_d]
            local px = PLAYER.x
            local py = PLAYER.y
            local nx = clamp(PLAYER.x + dx, 1, STATE.w)
            local ny = clamp(PLAYER.y + dy, 1, STATE.h)

            if PLAYER.arrow_buf then
                if is_drawable() then
                    ARROW = {x=px, y=py, dir=player_d}
                end
                PLAYER.arrow_buf = false
            end

            if is_walkable(nx, ny) then
                STATE.cells[py][px] = PLAYER.cell.over
                PLAYER.cell.over = STATE.cells[ny][nx]
                table.insert(stepped_on, PLAYER.cell.over)
                STATE.cells[ny][nx] = PLAYER.cell
                PLAYER.x = nx
                PLAYER.y = ny
                PLAYER.cell.dir = player_d
                PLAYER.cell.moved = true
                PLAYER.cooldown = PLAYER.cooldown + PLAYER_STEP_TIME - dt
            elseif STATE.cells[ny][nx].kind == K_DOOR and #(MICE) == 0 then
                STATE.cells[py][px] = PLAYER.cell.over
                PLAYER.cell.over = nil
                STATE.cells[ny][nx].sprite = S_PLAYER_STAND
                STATE.cells[ny][nx].dir = player_d
                STATE.cells[ny][nx].moved = true
                PLAYER.cooldown = PLAYER.cooldown + PLAYER_STEP_TIME - dt
                PLAYER.x = nx
                PLAYER.y = ny
            else
                PLAYER.cell.moved = false
                PLAYER.cooldown = 0
            end

            PLAYER.buffered = nil
        else
            PLAYER.buffered = nil
            PLAYER.cooldown = 0
            PLAYER.cell.moved = false
        end

        TIMER = TIMER - dt
        if TIMER + dt > STEP_TIME/3 and TIMER <= STEP_TIME/3 then
            for icheese, cheese in ipairs(ANIM_CHEESES) do
                if cheese.mice == 2 then
                    cheese.tile = T_CHEESE_BOTH
                else
                    cheese.tile = T_CHEESE_HALF[cheese.dir]
                end
                cheese.sprite = nil
                cheese.moved = nil
                cheese.dir = nil
            end
            ANIM_CHEESES = {}
        end

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
                        if is_walkable(nx, ny) then
                            table.insert(stepped_on, ncell)
                            STATE.cells[my][mx] = mouse.cell.over
                            mouse.cell.over = STATE.cells[ny][nx]
                            STATE.cells[ny][nx] = mouse.cell
                            mouse.x = nx
                            mouse.y = ny
                            mouse.cell.dir = nd
                            mouse.cell.moved = true
                            break
                        elseif ncell.kind == K_CHEESE and (ncell.mice or 0) < 2 then
                            STATE.cells[my][mx] = mouse.cell.over
                            mouse.cell.over = nil
                            ncell.mice = (ncell.mice or 0) + 1
                            ncell.sprite = S_MOUSE1
                            ncell.dir = nd
                            ncell.moved = true
                            table.insert(ANIM_CHEESES, ncell)
                            mdone = true
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

        if #(MICE) == 0 then
            DOOR.cell.tile = T_DOOR_OPEN
        end

        local toggle_switches = false
        for istepped, icell in ipairs(stepped_on) do
            if icell.kind == K_SWITCH_ON then
                toggle_switches = true
                break
            end
        end
        if toggle_switches then
            for ty = 1, STATE.h do
                for tx = 1, STATE.w do
                    toggle_at(tx, ty)
                end
            end
        end
    end

    KEYPRESS = {}
end

function toggle_at(x, y)
    STATE.cells[y][x] = toggled(STATE.cells[y][x])
end

function toggled(cell)
    if not cell then
        return nil
    elseif cell.kind == K_SWITCH_ON then
        return clone(L_SWITCH_OFF)
    elseif cell.kind == K_SWITCH_OFF then
        return clone(L_SWITCH_ON)
    elseif cell.kind == K_GATE_ON then
        return clone(L_GATE_OFF)
    elseif cell.kind == K_GATE_OFF then
        return clone(L_GATE_ON)
    else
        cell.over = toggled(cell.over)
        return cell
    end
end

function draw_menu()
    MENU_X = 40
    MENU_X2 = 400
    MENU_Y = 40
    MENU_W = 195
    MENU_H = WINDOW_H - 80
    HGAP = 5
    IGAP = 20
    MAIN_MENU_X = MENU_X+59
    MAIN_MENU_Y = MENU_Y+98
    PAUSE_MENU_X = MENU_X+55
    PAUSE_MENU_Y = MENU_Y+78
    END_MENU_X = MENU_X+46
    END_MENU_Y = MENU_Y+200
    love.graphics.setFont(FONT)

    if IN_MENU then
        love.graphics.setColor({0.3, 0.3, 0.3, 0.98})
        love.graphics.rectangle('fill', MENU_X, MENU_Y, MENU_W, MENU_H)
        love.graphics.setColor({1, 1, 1})

        love.graphics.print("MOUSEHERD", MENU_X+20, MENU_Y+10, 0, 2, 2)
        love.graphics.print("LD 47  STUCK IN A LOOP", MENU_X+20, MENU_Y+42)
    end
    if MAIN_MENU then
        love.graphics.print("MAIN MENU", MAIN_MENU_X, MAIN_MENU_Y)
        love.graphics.print(
            {{1,1,1}, "PRESS ", {1, 0.8, 0.4}, "ENTER", {1, 1, 1}, " TO START"},
            MENU_X+20, MAIN_MENU_Y + HGAP + IGAP
        )
        love.graphics.print(
            {{1,1,1}, "PRESS ", {1, 0.8, 0.4}, "ESCAPE", {1, 1, 1}, " TO EXIT"},
            MENU_X+20, MAIN_MENU_Y + HGAP + IGAP*2
        )
    end

    if PAUSE_MENU then
        love.graphics.print("PAUSE MENU", PAUSE_MENU_X, PAUSE_MENU_Y)
        love.graphics.print(
            {{1,1,1}, "", {1, 0.8, 0.4}, "ENTER", {1, 1, 1}, " TO RESUME"},
            MENU_X+20, PAUSE_MENU_Y + HGAP + IGAP
        )
        love.graphics.print(
            {{1,1,1}, "", {1, 0.8, 0.4}, "ESCAPE", {1, 1, 1}, " TO END RUN"},
            MENU_X+20, PAUSE_MENU_Y + HGAP + IGAP*2
        )
        love.graphics.print(
            {{1,1,1}, "", {1, 0.8, 0.4}, "R", {1, 1, 1}, " TO RESTART LEVEL"},
            MENU_X+20, PAUSE_MENU_Y + HGAP + IGAP*3
        )
        if LEVEL < FINAL_LEVEL then
            love.graphics.print(
                {{1,1,1}, "", {1, 0.8, 0.4}, "N", {1, 1, 1}, " TO SKIP LEVEL"},
                MENU_X+20, PAUSE_MENU_Y + HGAP + IGAP*4
            )
        end
    end

    if IN_MENU then
        love.graphics.print({{1.0, 1.0, 1.0},  "GAME CONTROLS"}, END_MENU_X, END_MENU_Y)
        love.graphics.print(
            {{1, 0.8, 0.4}, "ARROW KEYS", {1, 1, 1}, " TO MOVE"},
            MENU_X+20, END_MENU_Y + HGAP + IGAP
        )
        love.graphics.print(
            {{1, 0.8, 0.4}, "SHIFT", {1, 1, 1}, " TO PLACE ARROW"},
            MENU_X+20, END_MENU_Y + HGAP + IGAP*2
        )
    end

    if IN_MENU and GAME_DONE then
        love.graphics.setColor({0.3, 0.3, 0.3, 0.98})
        love.graphics.rectangle('fill', MENU_X2, MENU_Y, MENU_W, MENU_H)
        love.graphics.setColor({1, 1, 1})
        love.graphics.print("WELL DONE", MENU_X2+20, MENU_Y+10, 0, 2, 2)
        love.graphics.print("THANKS FOR PLAYING", MENU_X2+20, MENU_Y+42)

        RUN_STATS_LINES = 2
        RUN_STATS_Y = MENU_Y+240 - RUN_STATS_LINES*IGAP
        CREDITS_Y = MENU_Y+118 - RUN_STATS_LINES*IGAP/2

        love.graphics.print("CREDITS", MENU_X2+65, CREDITS_Y)
        love.graphics.print("GAME BY TYPESWITCH", MENU_X2+20, CREDITS_Y+HGAP+IGAP)
        love.graphics.print("FONT BY THE KROOB", MENU_X2+20, CREDITS_Y+HGAP+IGAP*2)

        love.graphics.print("RUN STATS", MENU_X2+60, RUN_STATS_Y)
        if not LAST_RUN then
            love.graphics.print("LAST RUN USED SKIPS", MENU_X2+20, RUN_STATS_Y+HGAP+IGAP)
        else
            love.graphics.print("LAST RUN  " .. math.floor(LAST_RUN), MENU_X2+20, RUN_STATS_Y+HGAP+IGAP)
        end
        if BEST_RUN then
            love.graphics.print("BEST RUN  " .. math.floor(BEST_RUN), MENU_X2+20, RUN_STATS_Y+HGAP+IGAP*2)
        end
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
                if t.tile then
                    draw_tile(t.tile, tx, ty)
                end
                if t.over and t.over.undertile then
                    draw_tile(t.over.undertile, tx, ty)
                end
            end
        end
    end

    for tx = 1, grid_w do
        for ty = 1, grid_h do
            local t = STATE.cells[ty][tx]
            if t and t.sprite then
                local ats = t.sprite
                local atx, aty = tx, ty
                if t.moved then
                    local f = TIMER / STEP_TIME
                    if t.kind == K_PLAYER or t.kind == K_DOOR then
                        f = PLAYER.cooldown / PLAYER_STEP_TIME
                        local o = {[0]=1,[1]=0,[2]=2,[3]=0}
                        local b = o [math.floor(TICKS*2 / ANIMATION_FRAME) % 4]
                        ats = ats + b
                    else
                        ats = ats + math.floor(TICKS / ANIMATION_FRAME) % 2
                    end
                    atx = tx - OFFSET_X[t.dir] * f
                    aty = ty - OFFSET_Y[t.dir] * f
                end
                draw_sprite(ats, t.dir, atx, aty)
            end
        end
    end

    draw_menu()
    if (not MAIN_MENU) and VALID_RUN then
        local rt_text = '' .. math.floor(RUN_TIMER)
        local rt_color = ((RUN_TIMER_PAUSED or GAME_PAUSED) and {0.7,0.7,0.7}) or {1,1,1}
        love.graphics.print({rt_color, rt_text}, 10, 0, 0, 2, 2)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        if MAIN_MENU then
            love.event.quit()
        else
            load_main_menu()
        end
    else
        KEYSTATE [key] = true
        KEYPRESS [key] = (KEYPRESS[key] or 0) + 1
    end
end

function love.keyreleased(key)
    KEYSTATE [key] = false
end
