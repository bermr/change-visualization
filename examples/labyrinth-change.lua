-- @example Change visualization of an agent trying to exit from a labyrinth.
-- @image labyrinth-change.png

import("logo")
import("changesmap")

local patterns = {}

local labyrinths = filesByExtension("logo", "labyrinth")

forEachElement(labyrinths, function(_, file)
    local _, name = file:split()
    table.insert(patterns, name)
end)

patterns.default = "maze"

Labyrinth = Model{
    quantity = 1,
    finalTime = 2000,
    labyrinth = "maze",
    random = true,
    init = function(model)
        model.cs = getLabyrinth(model.labyrinth)
        model.cs:createNeighborhood()

        model.background = Map{
            target = model.cs,
            select = "state",
            value = {"wall", "exit", "empty", "found"},
            color = {"black", "red", "white", "green"}
        }

        model.agent = Agent{
            execute = function(agent)
                local empty = {}
                local exit
                local thisCell

                forEachNeighbor(agent:getCell(), function(neigh)
                    thisCell = agent:getCell()
                    if neigh.state == "exit" then
                        exit = neigh
                    elseif neigh.state == "empty" then
                        table.insert(empty, neigh)
                    end
                end)

                if exit then
                    exit.state = "found"
                    agent:leave() -- TODO: replace by die() in the future
                    agent.execute = function() end
                else
                    local cell = (Random(empty):sample())
                    cell.state = "agent"
                    thisCell.state = "empty"
                    agent:move(cell)
                end
            end
        }

        model.soc = Society{
            instance = model.agent,
            quantity = model.quantity
        }

        model.env = Environment{model.cs, model.soc}

        model.env:createPlacement()

        model.map = Map{
            target = model.soc,
            background = model.background,
            symbol = "turtle"
        }

        model.change_map = ChangeMap{
            target = model.cs,
            select = {"state"},
            type = "accumulation",
            color = {"purple", "yellow"}
        }

        model.timer = Timer{
            Event{action = model.soc},
            Event{action = model.map},
            Event{action = model.change_map},
            Event{action = function()
                model.cs:synchronize()
            end}
        }
    end
}


lab = Labyrinth{}

lab:run()

