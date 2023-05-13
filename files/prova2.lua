function bot_init(me)
end
function closest(me, radius, tipus)
	-- type either "player" or "bullet"
	local ret = {}

	for _, you in ipairs(me:visible()) do
		if you:type() == tipus and vec.distance(me:pos(), you:pos()) <= radius then
			table.insert(ret, you)
		end
	end
	return ret
end
function bot_main(me)
    local tb = closest(me, 500, "player")
    if #tb ~= 0 then
        me:cast(0, tb[1]:pos():sub(me:pos()))
    end
end