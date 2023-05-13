entity = {}

function entity:new(x, y)

	local obj = {
		x = x,
		y = y,

	}

	setmetatable(obj, self)
    self.__index = self

    -- Return the instance
    return obj
end


function dist(me, you)
	local substract = me:pos():sub(you:pos())
	return math.sqrt(substract:x()^2 + substract:y()^2)
end

function closest(me, radius, type)
	-- type either "player" or "bullet"
	local ret = {}

	for _, you in ipairs(me:visible()) do
		if dist(me, you) <= radius then
			table.insert(ret, you)
		end
	end
	return ret
end