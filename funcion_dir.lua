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