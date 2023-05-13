function bot_init(me)
end
function closestN(me, radius, tipus)
	-- type either "player" or "bullet"
	local ret = {}

	for _, you in ipairs(me:visible()) do
		if you:type() == tipus and vec.distance(me:pos(), you:pos()) <= radius then
			table.insert(ret, you)
		end
	end
	return ret
end
function closest(me, list)
	local lowestDistance = 0
	local closer = nil
	for _, you in ipairs(list) do
		if vec.distance(me:pos(), you:pos()) <= lowestDistance then
			lowestDistance = vec.distance(me:pos(), you:pos())
			closer = you
		end
	end
	return closer
end

function bot_main(me)
    local tb = closestN(me, 500, "player")
    if #tb ~= 0 then
		local close = closest(me, tb)
        me:cast(0, close:pos():sub(me:pos()))
    end
end