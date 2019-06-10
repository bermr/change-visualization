-- @example Fire spread example with change visualization
-- @image single-agent-change.png

import("changesmap")

STEPS = 100

FOREST     = 1
BURNING    = 2
BURNED     = 3
FIREBREAK  = 4

rand = Random{}

cell = Cell{
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

change_map = ChangeMap{
    target = cs,
    select = {"cover"},
    type = "moment",
    color = {"white", "red"},
    min = 0,
    max = 2
}

t = Timer{
    Event{action = function()
        cs:synchronize()
        cs:execute()
    end},
    Event{action = map},
    Event{action = change_map}
}

t:run(STEPS)
