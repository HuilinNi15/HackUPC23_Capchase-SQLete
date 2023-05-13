tickrate = 30 -- 30 ticks por segundo
player_speed = 20
bullet_speed = 4*player_speed

function bulletInTable(bullet, table)
    for i, b in ipairs(table) do
        local distancia = dist(bullet, b)
        if distancia > bullet_speed/tickrate - 3 and distancia < bullet_speed/tickrate + 3 then
            return i
        end
    end
    return -1
end

function dir(ent1, ent2)
    local vec_dir = vec.new(ent2:pos():x() - ent1:pos():x(), ent2:pos():y() - ent1:pos():y())
    return vec_dir
end

function calcularDirecciones(tablaAnterior, tablaNueva)
    local ret_tabla = {}
    for i, ent in ipairs(tablaNueva) do
        local j = bulletInTable(ent, tablaAnterior)
        if j ~= -1 then
            if tablaAnterior[j][2] ~= nil then
                local dir = tablaAnterior[j][2]
            else
                local dir = dir(tablaAnterior[j][1], ent)
            end
        else
            local dir = nil
        end
        table.insert(ret_tabla, {ent, dir})
    end
    return ret_tabla
end