require('consts')
require('util')

function love.load()
    love.window.setMode(WINDOW_W, WINDOW_H, {})
    love.window.setTitle(WINDOW_TITLE)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    KEYSTATE = {}
    KEYPRESS = {}

    PLAYER_IMG = load_image(PLAYER_PATH)
    PLAYER = {
        img = PLAYER_IMG,
        x = 10,
        y = 20,
    }
    PLAYER_W, PLAYER_H = PLAYER_IMG:getDimensions()
    PLAYER_W = PLAYER_W * SCALE
    PLAYER_H = PLAYER_H * SCALE

    FG_IMGS = load_images(FG_PATHS)
    BG_IMGS = load_images(BG_PATHS)
end

function love.update(dt)
    if KEYSTATE[RIGHT] and not KEYSTATE[LEFT] then
        PLAYER.xspeed = PLAYER_XSPEED
        PLAYER.flipped = false
    elseif KEYSTATE[LEFT] and not KEYSTATE[RIGHT] then
        PLAYER.xspeed = -PLAYER_XSPEED
        PLAYER.flipped = true
    else
        PLAYER.xspeed = 0
    end
    PLAYER.x = PLAYER.x + PLAYER.xspeed * dt
    PLAYER.x = clamp(PLAYER.x, 0, WINDOW_W - PLAYER_W)

    KEYPRESS = {}
end

function love.draw()
    love.graphics.clear()
    love.graphics.draw(BG_IMGS[1], 0, 0, 0, SCALE_LEVEL, SCALE_LEVEL)
    love.graphics.draw(FG_IMGS[1], 0, 0, 0, SCALE_LEVEL, SCALE_LEVEL)
    draw_sprite(PLAYER)

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
