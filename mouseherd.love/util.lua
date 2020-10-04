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

function make_quads(image)
    local image_w, image_h = image:getDimensions()
    local num_tiles_x = math.floor(image_w / SPRITE_W)
    local num_tiles_y = math.floor(image_h / SPRITE_H)
    local quads = {}
    for y = 1, num_tiles_y do
        quads[y] = {}
        for x = 1, num_tiles_x do
            quads[y][x] = love.graphics.newQuad(
                (x-1)*SPRITE_W, (y-1)*SPRITE_H,
                SPRITE_W, SPRITE_H,
                image_w, image_h
            )
        end
    end
    return quads
end

function clone(t)
    if type(t) == 'table' then
        local t2 = {}
        for k,v in pairs(t) do
            t2[k] = clone(v)
        end
        return t2
    else
        return t
    end
end

function round(x)
    return math.floor(x + 0.5)
end
