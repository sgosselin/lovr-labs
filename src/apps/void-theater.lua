--
-- Void Theater
--
-- Video playback in a void environment with a screen whose position is to be always
-- in front of the viewer.
--

-- Expected distance from viewer to display.
DISTANCE = 4

local gDispPos = lovr.math.newVec3(0, 0, 0)

local function draw_origin()
    lovr.graphics.setShader()
    lovr.graphics.setColor(1, 0, 0)
    lovr.graphics.line(0, 0, 0, 1, 0, 0)
    lovr.graphics.setColor(0, 1, 0)
    lovr.graphics.line(0, 0, 0, 0, 1, 0)
    lovr.graphics.setColor(0, 0, 1)
    lovr.graphics.line(0, 0, 0, 0, 0, 1)
end

function lovr.load()
    gEnvShader = lovr.graphics.newShader([[
        vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
        return projection * transform * vertex;
        }
    ]], [[
        const float gridSize = 25.;
        const float cellSize = .5;

        vec4 color(vec4 gcolor, sampler2D image, vec2 uv) {
            // Distance-based alpha (1. at the middle, 0. at edges)
            float alpha = 1. - smoothstep(.15, .50, distance(uv, vec2(.5)));

            // Grid coordinate
            uv *= gridSize;
            uv /= cellSize;
            vec2 c = abs(fract(uv - .5) - .5) / fwidth(uv);
            float line = clamp(1. - min(c.x, c.y), 0., 1.);
            vec3 value = mix(vec3(.01, .01, .011), (vec3(.04)), line);

            return vec4(vec3(value), alpha);
        }
    ]], { flags = { highp = true } })
end

function lovr.draw()
    -- Determine the display target position.
    local headPos = vec3(lovr.headset.getPosition('head'))
    local headDir = vec3(quat(lovr.headset.getOrientation('head')):direction()):normalize()
    local targetPos = headPos + headDir * DISTANCE

    -- Make the display moves closer to its target.
    gDispPos:set(targetPos:lerp(gDispPos, 0.95))

    -- Make the display orientation the same than the camera.
    angle, ax, ay, az = lovr.headset.getOrientation('head')

    -- origin
    draw_origin()

    -- environment
    lovr.graphics.setShader(gEnvShader)
    lovr.graphics.plane('fill', 0, 0, 0, 25, 25, -math.pi / 2, 1, 0, 0)
    lovr.graphics.setShader()

    -- display
    lovr.graphics.setColor(1, 0, 0)
    lovr.graphics.plane('fill', gDispPos.x, gDispPos.y, gDispPos.z, 3, 2, angle, ax, ay, az)
end

