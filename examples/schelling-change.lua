-- schelling

NDIM = 50
NAGTS = 0.9
PREFERENCE = 3
MAX_TURNS = 600

agent = Agent{
    color = Random{"red", "black"},
    isUnhappy = function(agent)
        local likeme = 0

        forEachNeighborAgent(agent, function(other)
            if other.color == agent.color then
                likeme = likeme + 1
            end
        end)

        return likeme < PREFERENCE
    end
}

cell = Cell{
    change = 0,
    color = function(self)
        if self:isEmpty() then return "empty" end
        return self:getAgent().color
    end
}

cells = CellularSpace{
    xdim = NDIM,
    instance = cell
}

cells:createNeighborhood{}

society = Society {
    instance = agent,
    quantity = math.ceil(NAGTS * NDIM * NDIM),
    unhappy_agents = function(self)
        if not self.ua then
            self.ua = Group {
                target = self,
                select = function(agent)
                    return agent:isUnhappy()
                end
            }
        else
            self.ua:rebuild()
        end

        return self.ua
    end,
    unhappy = function(self) return #self:unhappy_agents() end
}

env = Environment{
    cells, society
}

env:createPlacement{}

empty_cells = Trajectory{
    target = cells,
    select = function(cell)
        return cell:isEmpty()
    end
}

map = Map{
    target = cells,
    select = "color",
    value = {"empty", "black", "red"},
    color = {"lightGray", "black", "red"}
}

changeMap = Map{
    target = cells,
    select = "change",
    min = 0,
    max = 5,
    slices = 5,
    color = "Reds"
}

timer = Timer{
    Event{action = function()
        unhappy_agents = society:unhappy_agents()
        empty_cells:rebuild()

        if #unhappy_agents > 0 then
            local myagent = unhappy_agents:sample()
            local mycell  = empty_cells:sample()
            myagent:move(mycell)
            mycell.change = mycell.change + 1
        else
            return false
        end
    end},
    Event{action = map},
    Event{action = changeMap}
}

timer:run(MAX_TURNS)
