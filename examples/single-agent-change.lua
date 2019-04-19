-- @example A simple example with one Agent that moves randomly in space.
-- @image single-agent.png
require("changeApi")

singleFooAgent = Agent{
    execute = function(self)
        self:walk()
    end
}

cell = Cell{
    color = "",
    getColor = function(self)
        if self:isEmpty() then
            return "empty"
        else
            return "full"
        end
    end
}

cs = CellularSpace{
    xdim = 50,
    instance = cell,
    execute = function(self)
        forEachCell(cs, function(cell)
                cell.color = cell:getColor()
        end)
    end
}

cs:createNeighborhood()

e = Environment{
    cs,
    singleFooAgent
}

e:createPlacement()

map = Map{
    target = cs,
    select = "color",
    value = {"empty", "full"},
    color = {"white", "black"}
}

changeMap{
    target = cs,
    select = {"color"},
    type = "trail"
}

t = Timer{
    Event{action = function()
        cs:synchronize()
        cs:execute()
    end},
    Event{action = singleFooAgent},
    Event{action = map}
}

t:run(1000)

