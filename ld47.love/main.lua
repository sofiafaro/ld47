require('consts')
require('util')

function love.load()
    love.window.setMode(WINDOW_W, WINDOW_H, {})
    love.window.setTitle(WINDOW_TITLE)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    KEYSTATE = {}
    KEYPRESS = {}

    SPRITES_IMG = load_image(SPRITES_PATH)
    SPRITES_QUADS = make_quads(SPRITES_IMG)

    TILES_IMG = load_image(TILES_PATH)
    TILES_QUADS = make_quads(TILES_IMG)
end

function love.update(dt)
    KEYPRESS = {}
end

function love.draw()
    love.graphics.clear()
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
