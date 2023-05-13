local act_radius = 100

function calc_dir(vec1, vec2)
    return vec:new(vec2:x() - vec1:x(), vec2:y() - vec1:y())
end

function closestN(me, radius, tipus)
	local ret = {}
	for _, you in ipairs(me:visible()) do
		if you:type() == tipus and vec.distance(me:pos(), you:pos()) <= radius then
			
			table.insert(ret, you)
		end
	end
	return ret
end

function closest(me, tab)
    local ret = tab[1]
    for _, ent in ipairs(tab) do
        if vec.distance(me:pos(), ent:pos()) < vec.distance(me:pos(), ret:pos()) then
            ret = ent
        end
    end
    return ret
end

function angle_between_vectors(vec1, vec2)
    return math.atan(vec1:x() * vec2:y() - vec1:y() * vec2:x(), vec1:x() * vec2:x() + vec1:y() * vec2:y())
end

function rotationMatrix(angle)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    return {
        {cos, -sin},
        {sin, cos}
    }
end

function rotateVector(vect, angle)
    local rotation = rotationMatrix(angle)
    local rotatedVector = {
        rotation[1][1] * vect[1] + rotation[1][2] * vect[2],
        rotation[2][1] * vect[1] + rotation[2][2] * vect[2]
    }
    return rotatedVector
end

function tryGo(me, dir)
    local players = closestN(me, 100, "player")
    if #players == 0 then
        me:move(dir)
    else
        local closest_entity = closest(me, players)
        local dir_to_closest = calc_dir(me:pos(), closest_entity:pos())
        local angle_to_closest = angle_between_vectors(dir, dir_to_closest)
        local dist_to_closest = vec.distance(me:pos(), closest_entity:pos())
        local circle_of_death = me:cod()
        local dist_to_center = 0
        local level = 0
        local weight = 0
        local min_angle = 160
        if circle_of_death.x() == -1 then
            dist_to_center = vec.distance(me:pos(), vec.new(250, 250))
            level = dist_to_center / (250 * math.sqrt(2))
            weight = 0.2
        else
            dist_to_center = vec.distance(me:pos(), vec.new(circle_of_death:x(), circle_of_death:y()))
            if dist_to_center > circle_of_death:radius() then
                level = 1
            else
                level = dist_to_center / circle_of_death:radius()
            end
            weight = 0.6
        end    
        min_angle = min_angle - (160 * level * weight)

        weight = 0.8
        level = 1/math.sqrt(dist_to_closest)
        if dist_to_closest < 1 then
            level = 1
        end
        min_angle = min_angle + (160 * level * weight)

        if math.abs(angle_to_closest) > min_angle then
            me:move(dir)
        else
            local final_rotation = 0
            if angle_to_closest > 0 then
                final_rotation = -(min_angle - angle_to_closest)
            else
                final_rotation = min_angle + angle_to_closest
            end
            local rotated_dir = rotateVector(dir, final_rotation)
            me:move(rotated_dir)
        end
    end
end


function bot_init()
end

function bot_main()
    
end

