local init_positions
local ticks = 0
local init_direction = vec.new(0.2001025104881063, 0.9797749666614051)
local tol = 10^(-5)
local team_ids = {}
function bot_init(me)
	for key, player in me:visible() do
		init_positions[player:id()] = player:pos()
	end
end

function bot_main(me)

	if ticks == 0 then
		me:move(init_direction)
	end

	if ticks == 1 then
		for key, player in me:visible() do
			for init_id, init_pos in init_positions do
				if player:id() == init_id then
					diff = player:pos():sub(init_pos)
					len = math.sqrt(diff:x()^2 + diff:y()^2)
					unit_x = diff:x() / len
					unit_y = diff:y() / len
					if math.fabs(init_direction:x() - unit_x) <= tol 
						and math.fabs(init_direction:y() - unit_y) <= tol then
						table.insert(team_ids, init_id)
					end
				end
			end
		end
	end
	ticks = ticks + 1
end
