-- vec CLASS

vec = {}

function vec:new(x, y, type)

        local obj = {
            _x = x,
            _y = y
        }
    
    setmetatable(obj, self)
    self.__index = self
    
    return obj
end

function vec:add(v)
    return vec:new(v._x + self._x, v._y + self._y)
end 

function vec:sub(v)
    return vec:new(v._x - self._x, v._y - self._y)
end 

function vec:x()
    return self._x
end 

function vec:y()
    return self._y
end 

function vec:neg()
    return vec:new(-self._x, -self._y)
end 

-- entity CLASS

entity = {}

function entity:new(x, y, type, health)

    local obj = {
        _x = x,
        _y = y,
        _type = type,
        _health = health
    }

    setmetatable(obj, self)
    self.__index = self

    -- Return the instance
    return obj
end


function entity:pos()
    return vec:new(self._x, self._y)
end

function entity:move(vec)
    local norm = math.sqrt(vec:x()^2 + vec:y()^2)
    local unit_vec = {vec:x()/norm, vec:y()/norm}
    self._x = unit_vec[1]
    self._y = unit_vec[2]
end

function entity:health()
    return self._health
end


function entity:type()
    return self._type
end

function entity:repr()
    print(
        'x:', self._x, 
        'y:', self._y , 
        'type:', self._type, 
        'health:', self._health
    )
end

player1 = entity:new(2, 2, 'player', 10)
player2 = entity:new(3, 5, 'player', 10)
player3 = entity:new(1, 5, 'player', 10)
player4 = entity:new(0, 0, 'player', 10)

print(player1:type())


local global_players = {
    player1, player2, player3, player4
}

-- hay que definirlo despues porque es imbecil
function entity:visible()
    return global_players
end

-- STRATEGY !!!!!!!!!

-- Global variables
local target = nil
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
    local dy = -self.trajectory():x()
    local directionVector = vec:new(dx, dy)
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
    
    return vec:new(x, y)
end

function furtherAlongLine(point1, point2, lineStart, lineDirection) -- returns true if point1 is farther along the line than point2
    local vecToPoint1 = point1:sub(lineStart)
    local vecToPoint2 = point2:sub(lineStart)
    local dotProduct1 = vecToPoint1:dot(lineDirection)
    local dotProduct2 = vecToPoint2:dot(lineDirection)
    return dotProduct1 >= dotProduct2 

end

-- Function to check for intersection between a circle and a line
-- Returns true if there is an intersection, false otherwise
function intersectionCircle(line, circleCenter)
    -- Find the distance from the center of the circle to the line
    local distance = math.abs(line.a * circleCenter.x + line.b * circleCenter.y + line.c) / math.sqrt(line.a * line.a + line.b * line.b)
  
    -- If the distance is greater than the radius of the circle, there is no intersection
    if distance > 1 then
      return false
    end
  
    -- Otherwise, there is an intersection
    return true
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

function purgeBullets()
    for i = 1, #bullets do
        if bulletTooFar(me, bullets[i].position, bullets[i].trajectory) or bulletPast(me, bullets[i].position, bullets[i].trajectory) then
            table.remove(bullets, i)
        end    
    end
end

function checkViablePosition(position) -- returns true if no intersect with bullet path, false otherwise
    purgeBullets()
    local changePosition = false
    for i = 1, #bullets do
        if intersectionCircle(bullets[i].trajectory, position) then
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
    if checkViablePosition() then
        me:move(position)
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
                if checkViablePosition(rotatedVector) then
                    me:move(rotatedVector:sub(me:pos()))
                    break
                end
            end
        end
    end
end

-- Initialize bot
function bot_init(me)
    local position
end

-- Main bot function
function bot_main(me)
    local me_pos = me:pos()


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
            for _, ally in ipairs(allies) do
                if _:visible():id() == ally:visible():id() then
                    attack = false
                end
            end
            closest_enemy = player
        end
    end

    -- If enemy is within range, melee, otherwise, projectile
    -- Set target to closest visible enemy
    local target = closest_enemy
    if target then
        local direction = {target:pos()}
        -- If target is within melee range and melee attack is not on cooldown, use melee attack
        if min_distance <= 2 and cooldowns[3] == 0 then
            me:cast(2, direction)
            cooldowns[3] = 50
            -- If target is not within melee range and projectile is not on cooldown, use projectile
        elseif cooldowns[1] == 0 then

            me:cast(0, direction)
            cooldowns[1] = 1
        end
        -- Move towards the center
        local direction = {250, 250}
        me:move(direction)
    end

end