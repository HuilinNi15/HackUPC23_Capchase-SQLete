local init_positions = {}
local ticks = 0
local init_direction = vec.new(0.2001025104881063, 0.9797749666614051)
local tol = 10^(-4)
local team_ids = {}

function bot_init(me)
end

function abs_(x)
	if x < 0 then
		return -x
	else 
		return x
	end
end

function bot_main(me)

	if ticks == 0 then
		for key, player in pairs(me:visible()) do
			init_positions[player:id()] = player:pos()
			print('ticks = 0', player:id(), player:pos(), player:type())
		end
		-- print('mi posicion', me:pos():x())
		me:move(init_direction)
		-- print('mi posicion', me:pos())


	end

	if ticks == 1 then
		for key, player in ipairs(me:visible()) do
			print('ticks = 1', player:id(), player:pos(), player:type())
			print()
			for init_id, init_pos in pairs(init_positions) do
				if player:id() == init_id then
					local diff = player:pos():sub(init_pos)
					local len = math.sqrt(diff:x()^2 + diff:y()^2)
					local unit_x = diff:x() / len
					local unit_y = diff:y() / len
					print('entro seguindo for')
					print(player:id())
					print(abs_(init_direction:x() - unit_x))
					if abs_(init_direction:x() - unit_x) <= tol and abs_(init_direction:y() - unit_y) <= tol then
						table.insert(team_ids, init_id)
					end
				end
			end
		end
	end
	print('printeo team')
	for _, player in pairs(team_ids) do
		print(player)
	end

	ticks = ticks + 1
end
