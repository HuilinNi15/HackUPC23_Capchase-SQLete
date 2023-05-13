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

-- TESTING vec class

random_vec = vec:new(1, 2)
print(random_vec:y())

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
	local x = self._x
	local y = self._y 
	local type = self._type
	local health = self._health
	
	print(
		'x:', x, 
		'y:', y, 
		'type:', type, 
		'health:', health
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

-- testing ENTITY
print(player1:visible()[1])
for key, player in ipairs(player1:visible()) do
	player:repr()
end


player1:move(vec:new(250,250))
player1:repr()