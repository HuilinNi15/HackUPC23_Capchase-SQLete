-- Global variables
local target = nil
local cooldowns = {0, 0, 0}

-- Initialize bot
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

-- Main bot function
function bot_main(me)
	if #(closest(me, 30, "bullet")) > 0 then
        me:cast(0, vec.new(1, 1))
    end
end