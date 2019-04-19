-- Cabeca de Boi runoff model

local init = function(model)
    model.cell = Cell{
        momChange = 0,
        accChange = 0,
        init = function(cell)
            if cell.height > 200 then
                cell.water = 10 * cell:area()
            else
                cell.water = 0
            end
        end,
        on_synchronize = function(cell)
            cell.water = 0
        end,
        execute = function(cell)
            local neighbors = #cell:getNeighborhood()
            cell.momChange = math.abs(cell.water - cell.past.water)

            if neighbors == 0 then
                cell.water = cell.water + cell.past.water
            else
                forEachNeighbor(cell, function(neigh)
                    neigh.water = neigh.water + cell.past.water / neighbors
                    cell.accChange = cell.past.accChange + cell.past.water/10000
                end)
            end
        end,
        water100000 = function(cell)
            if cell.water > 100000 then
                return 100000
            else
                return cell.water
            end
        end
    }

    model.cs = CellularSpace{
        file = filePath("cabecadeboi.shp", "gis"),
        instance = model.cell
    }

    model.cs:createNeighborhood{
        strategy = "mxn",
        filter = function(cell, neigh)
            return cell.height >= neigh.height  --só ficam na vizinhança os vizinhos com altura menor
        end
    }

    model.map1 = Map{
        target = model.cs,
        select = "height",
        min = 0,
        max = 255,
        slices = 8,
        invert = true,
        color = "Grays"
    }

    model.map2 = Map{
        target = model.cs,
        select = "water100000",
        min = 0,
        max = 100000,
        slices = 8,
        color = "Blues"
    }

    model.momentChange = Map{
        target = model.cs,
        select = "momChange",
        min = 0,
        max = 100000,
        slices = 10,
        color = "Reds"
    }

    model.accChange = Map{
        target = model.cs,
        select = "accChange",
        min = 0,
        max = 1000,
        slices = 20,
        color = {"white", "black"}
    }

    model.timer = Timer{
        Event{action = model.cs},
        Event{action = model.map1},
        Event{action = model.map2},
        Event{action = model.momentChange},
        Event{action = model.accChange}
    }
end

Runoff = Model{
    finalTime = 100,
    init = init
}

Runoff:run()

