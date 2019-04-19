--amazonia deforestation
require("changeApi")

local function calculatePotNeighborhood(cs)
    local total_pot = 0

    forEachCell(cs, function(cell)
        cell.pot = 0
        local countNeigh = 0
        local potential = 0

        forEachNeighbor(cell, function(neigh)
            -- The potential of change for each cell is
            -- the average of neighbors deforestation.
            -- fully deforested cells have zero potential
            potential = potential + neigh.defor
            countNeigh = countNeigh + 1
        end)

        if cell.defor < 1.0 then
            -- increment the total potential
            cell.pot = potential / countNeigh
            total_pot = total_pot + cell.pot
        end
    end)

    return total_pot
end

local function calculatePotRegression(cs)
    local total_pot = 0
    local expected

    -- The potential for change is the residue of a
    -- linear regression between the cell's
    -- current and expected deforestation
    forEachCell(cs, function(cell)
        cell.pot = 0

        expected = - 0.150 * math.log(cell.distroads)
                   - 0.048 * cell.protected
                   - 0.060 * math.log(cell.distports)
                   + 2.7

        if expected > 1 then expected = 1 end

        if cell.defor < 1.0 and expected > cell.defor then
            cell.pot = expected - cell.defor
            total_pot = total_pot + cell.pot
        end
    end)

    return total_pot
end

local function calculatePotMixed(cs)
    local total_pot = 0
    local expected

    forEachCell(cs, function(cell)
        cell.pot = 0
        cell.ave_neigh = 0

        -- Calculate the average deforestation
        local countNeigh = 0
        forEachNeighbor(cell, function(neigh)
            -- The potential of change for each cell is
            -- the average of neighbors' deforestation.
            cell.ave_neigh = cell.ave_neigh + neigh.defor
            countNeigh = countNeigh + 1
        end)

        -- find the average deforestation
        cell.ave_neigh = cell.ave_neigh / countNeigh

        -- Potential for change
        expected =   1.056 * cell.ave_neigh
                   - 0.035 * math.log(cell.distroads)
                   + 0.018 * math.log(cell.distports)
                   - 0.051 * cell.protected
                   + 0.059

        if expected > 1 then expected = 1 end

        if expected > cell.defor then
            cell.pot = expected - cell.defor
            total_pot = total_pot + cell.pot
        end
    end)

    return total_pot
end

Amazonia = Model{
    finalTime = 2040,
    allocation = 10000, -- km^2
    area = 50 * 50, -- km^2
    limit = 30, -- km^2
    potential = Choice{
        mixed = calculatePotMixed,
        neighborhood = calculatePotNeighborhood,
        regression = calculatePotRegression
    },
    init = function(model)
        model.cell = Cell{
            change = 0,
            init = function(cell)
                cell.defor = cell.defor / 100
            end
        }

        model.amazonia = CellularSpace{
            file = filePath("amazonia.shp"),
            instance = model.cell,
            as = {
                defor = "prodes_10"
            }
        }

        model.amazonia:synchronize()

        model.amazonia:createNeighborhood()

        model.map = Map{
            target = model.amazonia,
            select = "defor",
            slices = 10,
            min = 0,
            max = 1,
            color = "RdYlGn",
            invert = true,
            title = model:title()
        }

        model.changeMap = Map{
            target = model.amazonia,
            select = "change",
            slices = 10,
            min = 0,
            max = 10,
            color = {"blue", "red"}
        }

        model.deforest = function(cs, total_pot)
            -- ajust the demand for each cell so that
            -- the maximum demand for change is 100%
            -- adjust the demand so that excess demand is
            -- allocated to the remaining cells
            -- there is an error limit (30 km2 as default)
            local total_demand = model.allocation
            local newarea, excess

            while total_demand > model.limit do
                forEachCell(cs, function(cell)
                    newarea = (cell.pot / total_pot) * total_demand
                    cellPastDefor = cell.defor
                    cell.defor = cell.defor + newarea / model.area
                    if cell.defor >= 1 then
                        total_pot = total_pot - cell.pot
                        cell.pot = 0
                        excess = (cell.defor - 1) * model.area
                        cell.defor = 1
                    else
                        excess = 0
                    end

                    -- adjust the total demand
                    total_demand = total_demand - (newarea - excess)

                    if (math.abs(cell.defor - cell.past.defor)) > 0.005 then
                        cell.change = 10
                    else
                        if cell.past.change > 0 then
                            cell.change = cell.past.change - 1
                        end
                    end
                end)
            end
            cs:synchronize()
        end

        model.traj = Trajectory{
            target = model.amazonia,
            select = function(cell) return cell.pot > 0 end,
            greater = function(cell1, cell2) return cell1.pot > cell2.pot end,
            build = false
        }
        t = 0
        model.timer = Timer{
            Event{start = 1900, action = function()
                local total_pot = model.potential(model.amazonia)
                model.traj:rebuild()
                model.deforest(model.traj, total_pot)
                if t % 10 == 0 then model.changeMap:save("scshots/amazonia_"..t..".bmp") end
                t = t + 1
                --io.stdin:read(1)
            end},
            Event{start = 1900, action = model.map}
        }
    end
}

env = Environment{
    --Amazonia{potential = "neighborhood"}
    --Amazonia{potential = "regression"}
    Amazonia{potential = "mixed"}
}

env:run()

