
-- @example A simple example with one Agent that moves randomly in space.
-- @image single-agent-change.bmp

import("change")

SingleAgent = Model{
    quantity = 1,
    dim = 25,
    finalTime = 500,
    init = function(model)
        model.cell =  Cell{
            color = "",
            getColor = function(self)
                if self:isEmpty() then
                    return "empty"
                else
                    return "full"
                end
            end
        }

        model.cs = CellularSpace{
            xdim = model.dim,
            instance = model.cell,
            execute = function(self)
                forEachCell(model.cs, function(cell)
                    cell.color = cell:getColor()
                end)
            end
        }

        model.cs:createNeighborhood()

        model.agent = Agent{
            execute = function(self)
                self:walkToEmpty()
            end
        }

        model.soc = Society{
            instance = model.agent,
            quantity = model.quantity
        }

        model.env = Environment{model.cs, model.soc}

        model.env:createPlacement{}

        model.map = Map{
            target = model.soc,
            background = "green",
            symbol = "turtle"
        }

        model.change_map = ChangeMap{
            target = model.cs,
            select = {"color"},
            type = "accumulation"
            --color = {"purple", "yellow"},
            --min = 0,
            --max = 10
        }

        model.timer = Timer{
            Event{action = function()
                model.cs:synchronize()
                model.cs:execute()
            end},
            Event{action = model.soc},
            Event{action = model.map},
            Event{action = model.change_map}
        }
    end
}

singleAgent = SingleAgent{finalTime = 100}

singleAgent:run()