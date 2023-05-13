-- STRATEGY !!!!!!!!!

-- Global variables
local cooldowns = {0, 0, 0}
--Allies
local allies = {}
local bullets = {}

function rotationMatrix(angle)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    return {
        {cos, -sin},
        {sin, cos}
    }
end

Vec2 = {}

function Vec2:new(position, trajectory)
    local obj = {}
    obj.position = position
    obj._trajectory = trajectory
    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- hacer que Vec2 se comporte como entity
function Vec2:pos()
    return self.position
end

function  Vec2:trajectory()
    return self._trajectory
end

-- Define a method to calculate the perpendicular line passing through a point
function Vec2:perpendicular(point)
    local dx = self:trajectory():y()
    local dy = -self:trajectory():x()
    local directionVector = vec.new(dx, dy)
    return Vec2:new(point, directionVector)
end

-- Calculate the distance between two points
function pointDistance(p1, p2)
    local dx = p2:x() - p1:x()
    local dy = p2:y() - p1:y()
    return math.sqrt(dx^2 + dy^2)
end

-- Define a method to calculate the intersection point of two lines
function intersection(line1, line2)
    local x1, y1 = line1:pos():x(), line1:pos():y()
    local x2, y2 = line2:pos():x(), line2:pos():y()
    local dx1, dy1 = line1:trajectory():x(), line1:trajectory():y()
    local dx2, dy2 = line2:trajectory():x(), line2:trajectory():y()
    
    local det = dx1 * dy2 - dx2 * dy1
    if det == 0 then
        return nil  -- The lines are parallel
    end
    
    local t1 = (dy2 * (x1 - x2) - dx2 * (y1 - y2)) / det
    local t2 = (dy1 * (x1 - x2) - dx1 * (y1 - y2)) / det
    
    local x = x1 + dx1 * t1
    local y = y1 + dy1 * t1
    
    return vec.new(x, y)
end

function furtherAlongLine(bullet, intersectionPoint) -- returns true if the bullet is further along the line than the intersection point
    local aux_vec = bullet:pos():sub(intersectionPoint)
    local dx = bullet:trajectory():x() / aux_vec.x()
    local dy = bullet:trajectory():y() / aux_vec.y()
    if dx == dy and dx > 0 then
        return true
    else
        return false
    end
end

-- Function to check for intersection between a circle and a line
-- Returns true if there is an intersection, false otherwise
function intersectionCircle(line, circleCenter)
    -- Check the closest point to the circle center
    local closestPoint = intersection(line, line:perpendicular(circleCenter))
    if pointDistance(closestPoint, circleCenter) <= 0.5 then
        return true
    else
        return false
    end
end


function bulletTooFar(me, bulletPosition, bulletTrajectory)
    local mePosition = me:pos()
    local perpendicular = bulletTrajectory:perpendicular(mePosition)
    local intersectionPoint = intersection(bulletTrajectory, perpendicular)
    if pointDistance(bulletPosition, intersectionPoint) < 4 * pointDistance(mePosition, intersectionPoint)  then
        return true
    else
        return false
    end
end

function bulletPast(me, bulletPosition, bulletTrajectory)
    local mePosition = me:pos()
    local perpendicular = bulletTrajectory:perpendicular(mePosition)
    local intersectionPoint = intersection(bulletTrajectory, perpendicular)
    if fartherAlongLine(bulletPosition, intersectionPoint) then
        return true
    else
        return false
    end
end

function purgeBullets(me)
    for i = 1, #bullets do
        if bulletTooFar(me, bullets[i]:pos(), bullets[i]:trajectory()) or bulletPast(me, bullets[i]:pos(), bullets[i]:trajectory()) then
            table.remove(bullets, i)
        end    
    end
end

function checkViablePosition(me, position) -- returns true if no intersect with bullet path, false otherwise
    purgeBullets(me)
    for i = 1, #bullets do
        if intersectionCircle(bullets[i]:trajectory(), position) then
            return false
        end
    end
    return true
end

function normalize_vector(vector)
    local norm = math.sqrt(vector:x()^2 + vector:y()^2)
    return vec.new(vector:x()/norm, vector:y()/norm)
end

step = 5

function tryMove(me, vector_dir) --given the objective position, goes there if possible, else the nearest place
    local norm_dir_vec = normalize_vector(vector_dir)
    local objectivePosition = vec.new(me:pos():x() + norm_dir_vec:x()*step, me:pos():y() + norm_dir_vec:y()*step)
    if checkViablePosition(me, objectivePosition) then
        me:move(objectivePosition)
    else
        for i = 1, 180, 5 do
            for j = -1, 1, 2 do
                -- make the rotation matrix
                local angle = math.rad(j*i) -- rotate one degree to the right
                local rotation = rotationMatrix(angle)
                local rotatedVector = {
                    rotation[1][1] * norm_dir_vec[1] + rotation[1][2] * norm_dir_vec[2],
                    rotation[2][1] * norm_dir_vec[1] + rotation[2][2] * norm_dir_vec[2]
                }
                if checkViablePosition(me, rotatedVector) then
                    me:move(rotatedVector:sub(me:pos()))
                    break
                end
            end
        end
    end
end

local tickrate = 30 -- 30 ticks por segundo
local player_speed = 20
local bullet_speed = 4*player_speed

function bulletInTable(bullet, table)
    for i, b in ipairs(table) do
        local distancia = dist(bullet, b)
        if distancia > bullet_speed/tickrate - 3 and distancia < bullet_speed/tickrate + 3 then
            return i
        end
    end
    return -1
end

function calc_dir(vec1, vec2)
    local vec_dir = vec:new(vec2:x() - vec1:x(), vec2:y() - vec1:y())
    return vec_dir
end

function calcularDirecciones(tablaAnterior, tablaNueva)
    if tablaAnterior == {} then
        return tablaNueva
    end
    local ret_tabla = {}
    local dir
    for i, ent in ipairs(tablaNueva) do
        local j = bulletInTable(ent, tablaAnterior)
        if j ~= -1 then
            if tablaAnterior[j]:trajectory() ~= nil then
                dir = tablaAnterior[j]:trajectory()
            else
                dir = calc_dir(tablaAnterior[j], ent:pos())
            end
        else
            dir = nil
        end
        table.insert(ret_tabla, Vec2.new(ent:pos(), dir))
    end
    return ret_tabla
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

-- Initialize bot
function bot_init(me)
    bullets = calcularDirecciones({}, closestN(me, 35, "bullet"))

end

-- Main bot function
function bot_main(me)
    local me_pos = me:pos()

    bullets = calcularDirecciones(bullets, closestN(me, 35, "bullet"))

    -- Update cooldowns
    for i = 1, 3 do
        if cooldowns[i] > 0 then
            cooldowns[i] = cooldowns[i] - 1
        end
    end

    -- Attack logic
    local closest_enemy = nil
    local min_distance = math.huge
    for _, player in ipairs(me:visible()) do
        local dist = vec.distance(me_pos, player:pos())
        if dist < min_distance then
            min_distance = dist
            local attack = true
            for i, ally in ipairs(allies) do
                if player:id() == ally:id() then
                    attack = false
                end
            end
            if attack then
                closest_enemy = player
            end
        end
    end

    -- If enemy is within range, melee, otherwise, projectile
    -- Set target to closest visible enemy
    local target = closest_enemy
    if target then
        local direction = target:pos():sub(me:pos())
        -- If target is within melee range and melee attack is not on cooldown, use melee attack
        if min_distance <= 2 and cooldowns[3] == 0 then
            me:cast(2, direction)
            cooldowns[3] = 50
            -- If target is not within melee range and projectile is not on cooldown, use projectile
        elseif cooldowns[1] == 0 then

            me:cast(0, target:pos():sub(me:pos()))
            cooldowns[1] = 1
        end
    end
    -- Move towards the center
        if ticks > 50 and ticks < 400 then
            me:tryMove(me,center:sub(me:pos()))
        else 
            me:tryMove(me,vec.new(0,0))
        end
        if ticks > 400 and ticks < 475 then 
            me:tryMove(me,vec.new(220, 220):sub(me:pos()))
        end 
        if ticks > 475 and ticks < 550 then 
            me:tryMove(me,center:sub(me:pos()))
        end 
        if ticks > 550 and ticks < 600 then 
            me:tryMove(me,vec.new(260, 260):sub(me:pos()))
        end 
        if ticks > 600 and ticks < 750 then 
            me:tryMove(me,center:sub(me:pos()))
        end 

end