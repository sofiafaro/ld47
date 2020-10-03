function map(f, xs)
    ys = {}
    for i,x in ipairs(xs) do
        ys[i] = f(x)
    end
    return ys
end

function clamp(x, lo, hi)
    if x < lo then
        return lo
    elseif x > hi then
        return hi
    else
        return x
    end
end

function load_image(path)
    return love.graphics.newImage(path)
end

function load_images(paths)
    return map(load_image, paths)
end

function draw_sprite(data)
    local img = data.img
    local flipped = data.flipped or false
    local sign = (flipped and -1) or 1
    local x = data.x or 0
    local y = data.y or 0
    local r = data.r or 0
    if flipped then
        local w, h = img:getDimensions()
        x = x + w * SCALE
    end
    love.graphics.draw(img, x, y, r or 0, sign * SCALE, SCALE)
end
