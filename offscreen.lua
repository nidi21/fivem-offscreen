local function draw_line(first, second, width, color) 
    local x,y = GetActiveScreenResolution()
    DrawLine_2d(first.x / x, first.y / y, second.x / x, second.y / y, width, color.x,color.y,color.z,color.w)
end

local function sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

local function rotate_point(point, cos, sin)
    return vec2(point.x * cos - point.y * sin, point.x * sin + point.y * cos)
end

local function deg_to_rad(deg) return deg * math.pi / 180.0 end

local function get_camera_forward()
    local cam_rot = GetFinalRenderedCamRot(2)

    local heading = math.rad(cam_rot.z)
    local pitch = math.rad(cam_rot.x)

    return vec3(-math.sin(heading) * math.cos(pitch), math.cos(heading) * math.cos(pitch), math.sin(pitch))
end

local function draw_triangle(worldVec,width, color, ignoreScreen)
    local on_screen, screen_x, screen_y = GetScreenCoordFromWorldCoord(worldVec.x, worldVec.y, worldVec.z)
    if not on_screen and not ignoreScreen then return end

    local res_x, res_y = GetActiveScreenResolution()

    local res_center_x = res_x * 0.5
    local res_center_y = res_y * 0.5

    local player_position = GetEntityCoords(PlayerPedId())
    local delta = worldVec - player_position
    delta = norm(delta)
    local forward = get_camera_forward()

    local dotted = dot(delta, forward)
    local crossed = cross(delta, forward)
    local angle = math.atan2(#crossed, dotted)
    local sign = sign(crossed.z)

    angle = angle + 1.570796251
    if sign == 1 then angle = math.pi - angle print(angle) end
    
    local sin_angle = math.sin(angle)
    local cos_angle = math.cos(angle)

    local radius = 120.0
    local triangle_size = 14
    local triangle_center = vec2(res_center_x + radius * cos_angle, res_center_y - radius * sin_angle)

    local triangle_point_one = rotate_point(vec2(1.0, 0.0), cos_angle, -sin_angle) * triangle_size
    local triangle_point_two = rotate_point(vec2(-1.0, 0.75), cos_angle, -sin_angle) * triangle_size
    local triangle_point_three = rotate_point(vec2(-1.0, -0.75), cos_angle, -sin_angle) * triangle_size

    draw_line(triangle_center + triangle_point_one, triangle_center + triangle_point_two, width, color)
    draw_line(triangle_center + triangle_point_two, triangle_center + triangle_point_three, width, color)
    draw_line(triangle_center + triangle_point_three, triangle_center + triangle_point_one, width, color)
end

Citizen.CreateThread(function()
    local pos = vec3(2, 3, 70)
    local pos2 = vec3(5,10,70)
    local color = vec4(255,255,255,255)
    local width = 0.0005

    while 1 do
        draw_triangle(pos,width,color, true)
        draw_triangle(pos2,width,color, true)

        DrawLine(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z + 90.0, 255, 0, 0, 255)
        DrawLine(pos2.x, pos2.y, pos2.z, pos2.x, pos2.y, pos2.z + 90.0, 255, 0, 0, 255)
        Wait(1)
    end
end)