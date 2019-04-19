-- Barros urban dynamics model

P_POOR   = 0.65
P_MIDDLE = 0.30
P_RICH   = 0.05
DIM      = 51
AGENTS   = 500


cell = Cell{
    accChange = 0,
    momChange = 0,
    state = function(self)
        if self:isEmpty() then
            return "empty"
        else
            return self:getAgent().class
        end
    end
}

cellspace = CellularSpace{
    xdim = DIM,
    instance = cell
}

cellspace:createNeighborhood{
    strategy = "vonneumann"
}

mid = (DIM - 1) / 2
centralCell = cellspace:get(mid, mid)

citizen = Agent{
    class = Random{poor = P_POOR, middle = P_MIDDLE, rich = 1 - P_POOR - P_MIDDLE},
    execute = function(self)
        self:findPlace(centralCell)
    end,
    higherClass = function(self, other)
        local classes = {
            rich = 3,
            middle = 2,
            poor = 1
        }

        return classes[self.class] > classes[other.class]
    end,
    -- a citizen tries to move to a cell he can stay
    findPlace = function(self, place)
        local occupant = place:getAgent()

        if not occupant then
            self:enter(place)
        elseif self:higherClass(occupant) then
            occupant:leave()
            self:enter(place)
            occupant:findPlace(place)
            place.accChange = place.accChange + 1
        else
            self:findPlace(place:getNeighborhood():sample())
        end
    end
}

society = Society{
    instance = citizen,
    quantity = AGENTS
}

env = Environment{cellspace, society}
env:createPlacement{strategy = "void"}

accMap = Map{
    target = cellspace,
    select = "accChange",
    min = 0,
    max = 5,
    slices = 5,
    color = "Reds"
}

momMap = Map{
    target = cellspace,
    select = "state",
    value = {"empty", "poor", "middle", "rich"},
    color = {"black", "blue", "yellow", "red"}
}

forEachAgent(society, function(agent)
    agent:execute()
    accMap:update()
    momMap:update()
end)

