tickrate = 30 -- 30 ticks por segundo
player_speed = 20
bullet_speed = 4*player_speed

function bulletInTable(bullet, table)
    for i, b in ipairs(table) do
        distancia = dist(bullet, b)
        if distancia > bullet_speed/tickrate - 3 and distancia < bullet_speed/tickrate + 3 then
            return i
        end
    end
    return -1
end

function calcularDirecciones(tablaAnterior, tablaNueva)
    
end