function bot_init(me)
end

local c = vec.new(250, 250)
function bot_main(me)
    me:move(c:sub(me:pos()))
end