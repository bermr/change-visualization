-- Forest Fire Spread


-- uso da api:
-- dar o require
-- chamar changeMap(cspace, atributo)

require("changeApi")

STEPS = 100

FOREST     = 1
BURNING    = 2
BURNED     = 3
FIREBREAK  = 4

rand = Random{}

cell = Cell{
    water = 0,
    init = function(cell)
        if rand:number() > 0.1 then
            cell.cover = FOREST
        else
            cell.cover = FIREBREAK
        end
    end
}

cs = CellularSpace{
    xdim = 50,
    instance = cell,
    execute = function()
        forEachCell(cs, function(cell)
            if cell.past.cover == FOREST then
                forEachNeighbor(cell, function(neighbor)
                    if neighbor.past.cover == BURNING then
                        cell.cover = BURNING
                    end
                end)
            elseif cell.past.cover == BURNING then
                cell.cover = BURNED
                cell.water =  1
            end
        end)
    end
}

cs:createNeighborhood{
    strategy = "moore",
    self = false
}

cs:get(25, 25).cover = BURNING


map = Map{
    title = "Normal Map",
    target = cs,
    select = "cover",
    color = {"green", "red", "black", "white"},
    value = {FOREST, BURNING, BURNED, FIREBREAK},
}

changeMap{
    target = cs,
    select = {"cover"},
    type = "moment"
}

--[[changeMap{
    target = cs,
    select = "water"
}]]

t = Timer{
    Event{action = function()
        cs:synchronize()
        cs:execute()
    end},
    Event{action = map}
}

t:run(STEPS)
