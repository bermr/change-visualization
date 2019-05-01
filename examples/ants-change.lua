
-- @example TerraME Ants model with change visualization.
-- @image ants-change.bmp

import("change")

Ants = Model{
    dimension = 50,
    finalTime = 450,
    initialFood = 100,
    societySize = Choice{min = 10, max = 500},
    rateDiffusion = Choice{1, 2, 3, 4, 5, 6, 7, 8, 9, 10},    -- 3,  4
    rateEvaporation = Choice{min = 0.000001, max = 0.999999, default = 0.2}, -- 0.5,  0.75
    init = function(model)
        local icell = Cell{
            cover = "empty",
            chemical = 0,
            execute = function(cell) -- chemical evaporation
                if cell.chemical > 0 then
                    cell.chemical = cell.chemical - model.rateEvaporation
                end

                if cell.chemical <= 0 and (cell.cover == "chemical" or cell.cover == "lesschem") then
                    cell.cover = "empty"
                elseif cell.chemical < 1 and cell.cover == "chemical" then
                    cell.cover = "lesschem"
                end
            end,
            getNextCoordinateTowardDestiny = function(cell, destiny)
                -- Search next coordinate X to come bak to the nest
                local new_x
                local new_y

                if cell.x < destiny.x then
                    new_x = cell.x + 1
                elseif cell.x > destiny.x then
                    new_x = cell.x - 1
                else
                    new_x = cell.x
                end

                -- Search next coordinate Y to come bak to the nest
                if cell.y < destiny.y then
                    new_y = cell.y + 1
                elseif cell.y > destiny.y then
                    new_y = cell.y - 1
                else
                    new_y = cell.y
                end

                return {x = new_x, y = new_y}
            end
        }

        model.cs = CellularSpace{
            xdim = model.dimension,
            instance = icell,
            food = model.initialFood
        }

        model.cs:createNeighborhood{}

        local center = math.floor(model.dimension / 2)
        local nest_cell = model.cs:get(center, center)
        nest_cell.cover = "nest"
        forEachNeighbor(nest_cell, function(neigh)
            neigh.cover = "nest"
        end)

        -- Prepare the start cells for the ANTS
        local right = {x = nest_cell.x + 2, y = nest_cell.y}
        local left =  {x = nest_cell.x - 2, y = nest_cell.y}
        local up =    {x = nest_cell.x,     y = nest_cell.y - 2}
        local down =  {x = nest_cell.x,     y = nest_cell.y + 2}

        local nest_cell_right = model.cs:get(right.x, right.y)
        local nest_cell_left  = model.cs:get(left.x,  left.y)
        local nest_cell_up    = model.cs:get(up.x,    up.y)
        local nest_cell_down  = model.cs:get(down.x,  down.y)

        local function drawFood(x, y)
            local cell = model.cs:get(math.floor(x), math.floor(y))
            cell.cover = "food"
            forEachNeighbor(cell, function(neigh)
                neigh.cover = "food"
                forEachNeighbor(neigh, function(neigh2)
                    neigh2.cover = "food"
                end)
            end)
        end

        drawFood(model.dimension / 8, model.dimension / 8)
        drawFood(model.dimension / 7, model.dimension * 3 / 4)
        drawFood(model.dimension * 3 / 4, model.dimension / 3)
        drawFood(model.dimension * 3 / 4, model.dimension * 4 / 5)

        local familyAnt = Agent{
            -- initialize the agent internal state
            init = function(self)
                self.state = "searching"
                self.dest = nil
            end,
            search_food = function(agent)
                if agent:findFood() then return end

                local cell = agent:getCell()
                local any_chem = false

                -- If "ant" find chemical or lesschemical go there
                forEachNeighbor(cell, function(neigh)
                    if belong(neigh.cover, {"chemical", "lesschem"}) and not any_chem and neigh:isEmpty() then
                        agent:move(neigh)
                        any_chem = true
                        return false
                    end
                end)

                if any_chem == false then
                    if agent.dest ~=nil then
                        agent:goto_cell()
                    else
                        agent.dest = model.cs:sample()
                        agent:goto_cell()
                    end
                end
            end,
            bring_food = function(agent)
                if agent:findNest() then return end

                local cell = agent:getCell()
                local new_coord = cell:getNextCoordinateTowardDestiny(nest_cell)
                local new_cell = model.cs:get(new_coord.x, new_coord.y)
                if new_cell.cover ~= "food" and new_cell.cover ~= "nest" then
                    agent:getCell().cover = "chemical"
                    agent:getCell().chemical = agent:getCell().chemical + model.rateDiffusion

                    forEachNeighbor(cell, function(neigh)
                        if neigh.cover ~= "food" and neigh.cover ~= "nest" and neigh.cover ~= "chemical" then
                            neigh.chemical = neigh.chemical + (model.rateDiffusion / 2)
                            if neigh.chemical > 0 and neigh.chemical <= 1 then
                                neigh.cover = "lesschem"
                            elseif neigh.chemical > 1 then
                                neigh.cover = "chemical"
                            end
                        end
                    end)
                end

                agent:move(new_cell)
            end,
            execute = function(agent)
                if agent.state == "searching" then
                    agent:search_food()
                elseif agent.state == "bringing" then
                    agent:bring_food()
                end
            end,
            findFood = function(agent)
                local cell = agent:getCell()
                forEachNeighbor(cell, function(neigh)
                    if neigh.cover ~= "food" then return end

                    neigh.cover = "chemical"

                    cell = agent:getCell()
                    forEachNeighbor(cell, function(neigh2)
                        if neigh2.cover ~= "food" and neigh2.cover ~= "nest" then
                            neigh2.cover = "chemical"
                            neigh2.chemical = neigh2.chemical + model.rateDiffusion
                            forEachNeighbor(neigh2, function(neigh3)
                                if neigh3.cover ~= "food" and neigh3.cover ~= "nest" then
                                    neigh3.cover = "lesschem"
                                    neigh3.chemical = neigh3.chemical + model.rateDiffusion / 2
                                end
                            end)
                        end
                    end)

                    agent.state = "bringing"
                    model.cs.food = model.cs.food - 1
                    return true
                end)

                return false
            end,
            findNest = function(agent)
                local cell = agent:getCell()
                forEachNeighbor(cell, function(neigh)
                    if neigh.cover == "nest" then
                        agent.state = "searching"
                        return true
                    end
                end)

                return false
            end,
            goto_cell = function(agent)
                local dest = agent.dest
                local cell = agent:getCell()

                local new_coord = cell:getNextCoordinateTowardDestiny(dest)
                local new_cell = model.cs:get(new_coord.x, new_coord.y)

                if new_cell.cover ~= "food" and new_cell.cover ~= "nest" and new_cell:isEmpty() then
                    agent:move(new_cell)
                else
                    new_cell = agent:getCell():getNeighborhood():sample()
                    if new_cell.cover ~= "food" and new_cell.cover ~= "nest" and new_cell:isEmpty() then
                        agent:move(new_cell)
                    end
                end

                if new_cell == dest then
                    agent.dest = nil
                end
            end,
            random_start = function(agent)
                local random = math.random(1, 4)

                if random == 1 then
                    agent:enter(nest_cell_right)
                elseif random == 2 then
                    agent:enter(nest_cell_left)
                elseif random == 3 then
                    agent:enter(nest_cell_up)
                elseif random == 4 then
                    agent:enter(nest_cell_down)
                end
            end
        }

        model.soc = Society{
            instance = familyAnt,
            quantity = model.societySize
        }

        model.map = Map{
            target = model.cs,
            select = "cover",
            value = {"empty", "food", "nest", "chemical", "lesschem"},
            color = {"brown", "blue", "red", "green", "darkGreen"}
        }

        model.env = Environment{model.cs, model.soc}

        model.env:createPlacement{
            strategy = "void"
        }

        model.soc:random_start()

        -- if I put this Map before random_start, it stops with a bad error message.
        model.map = Map{
            target = model.soc,
            symbol = "ant",
            color = "yellow",
            background = model.map,
            size = 10
        }

        model.change_map = ChangeMap{
            target = model.cs,
            select = {"cover"},
            type = "accumulation",
            max = 20
        }

        model.timer = Timer{
            Event{action = model.soc},
            Event{action = model.cs},
            Event{action = model.map},
            Event{action = model.change_map}
        }
    end
}

ants = Ants{
    societySize = 50,
    rateDiffusion = 5,
    rateEvaporation = 0.5,
    finalTime = 100
}

ants:run()