-- This package allows the user to view the
-- amount of change happening in the simulation.
-- @arg target A CellularSpace, Agent or Society
-- @arg select A table with the name of the attribute or attributes to be visualized.
-- @arg type The change visualization type: Moment, accumulation or trail
-- @arg data.color A table with the colors for the attributes. Colors can be described as strings
-- ("red", "green", "blue", "white", "black",
-- "yellow", "brown", "cyan", "gray", "magenta", "orange", "purple", and their light and dark
-- compositions, such as "lightGray" and "darkGray"), as tables with three integer numbers
-- representing RGB compositions, such as {0, 0, 0}, or even as a string with a ColorBrewer format
-- (see http://colorbrewer2.org/). The colors available and the maximum number of slices for each
-- of them are:
-- @tabular color
-- Name & Max \
-- Accent, Dark, Pastel2, Set2 & 8 \
-- Pastel1, Set1 & 9 \
-- BrBG, PRGn, RdYlGn, Spectral & 11 \
-- PiYG, PuOr, RdBu, RdGy, RdYlBu & 11 \
-- Paired, Set3 & 12 \
-- Blues, BuGn, BuPu, GnBu, Greens, Greys, Oranges, OrRd, PuBu, PuBuGn, PuRd, Purples, RdPu, Reds, YlGn, YlGnBu, YlOrBr, YlOrRd & 20 \
-- @arg min The minimum value of the attribute
-- @arg max The maximum value of the attribute
-- @usage cell = Cell{
--     cover = Random{min = 0, max = 50},
-- }
--
-- cs = CellularSpace{
--     xdim = 10,
--     instance = cell
-- }
--
-- change_map = ChangeMap{
--     target = cs,
--     select = {"cover"},
--     min = 0,
--     max = 50,
--     color = {"blue", "red"}
-- }
--
-- timer = Timer{
--     Event{action = function()
--         model.cs:synchronize()
--     end},
--     Event{action = model.change_map}
-- }

local function updateSynchronize(data)
    data.target.synchronize_ = data.target.synchronize
    data.target.synchronize = function(self)
        forEachCell(self, function(cell)
            for i, v in pairs(data.target.change) do
                local v_ = v .. "Change"
                local change = cell[v] ~= cell.past[v]
                if (change == true) then
                    if (data.type == "moment") then
                        cell[v_] = 1
                    elseif (data.type == "accumulation") then
                        cell[v_] = cell.past[v_] + 1
                    elseif (data.type == "trail") then
                        cell[v_] = 50
                    end
                else
                    if (data.type == "moment") then
                        cell[v_] = 0
                    elseif (data.type == "trail") then
                        if (cell.past[v_] > 0) then
                            cell[v_] = cell.past[v_] - 1
                        end
                    end
                end
            end
        end)
        data.target:synchronize_()
    end
end

local function setDefaultValues(data)
    if not data.min then
        data.min = 0
    end

    if not data.max then
        data.max = 25
    end

    if not data.color then
        data.color = {"blue",  "red"}
    end
end


local function createMap(data)
    setDefaultValues(data)
    for i, v in pairs(data.target.change) do
        if (data.target.maps[v] ~= 1) then
            data.target.maps[v] = 1
            local change_ = v .. "Change"
            local mapname = v:sub(1,1):upper()..v:sub(2).." Change"

            if (data.type == "moment") then
                change_map = Map{
                    title  =  mapname,
                    target = data.target,
                    select = change_,
                    color  = data.color,
                    value  = {0,1}
                }
            elseif (data.type == "accumulation") then
                change_map = Map{
                    title  =  mapname,
                    target = data.target,
                    select = change_,
                    color  = data.color,
                    min    = data.min,
                    max    = data.max,
                    slices = 10
                }
            elseif (data.type == "trail") then
                change_map = Map{
                    title =  mapname,
                    target = data.target,
                    select = change_,
                    color = data.color,
                    min = 0,
                    max = 10,
                    slices = 10
                }
            end
            return change_map
        end
    end
end

local function verifyData(data)
    verifyNamedTable(data)
    mandatoryTableArgument(data, "target")

    if not belong(type(data.target), {"CellularSpace", "Agent", "Society"}) then
        customError("Invalid type. Maps only work with CellularSpace, Agent, Society, got "..type(data.target)..".")
    end

    if type(data.target) == "CellularSpace" then
        if (data.target.xMin == 0 and data.target.xMax == 0) or (data.target.yMin == 0 and data.target.yMax == 0) then
            customError("It is not possible to create a Map from this CellularSpace as its objects do not have a valid (x, y) location.")
        end
    end

    local validArgs = {"type", "background", "color", "font", "grid", "grouping", "invert", "label", "max", "min",
    "precision", "select", "size", "slices", "stdColor", "stdDeviation", "symbol", "target", "value", "title"}

    verifyUnnecessaryArguments(data, validArgs)

    if type(data.target) == "Agent" then
        local s = Society{instance = Agent{}, quantity = 0}
        s:add(data.target)
        data.target = s
        return Map(data)
    end

    optionalTableArgument(data, "value", "table")
end

local function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function createElements(data)
    if (not data.target.change) then
        data.target.change = {}
    end
    if (not data.target.maps) then
        data.target.maps = {}
    end
    for i, v in pairs(data.select) do
        if (not hasValue(data.target.change, v)) then
            table.insert(data.target.change, v)
        end
    end

    forEachCell(data.target, function(cell)
        for i, v in pairs(data.target.change) do
            cell[v .. "Change"] = 0
        end
    end)
end

function ChangeMap(data)
    verifyData(data)

    createElements(data)

    if(not data.target.synchronize_) then
        data.target:synchronize()
        updateSynchronize(data)
    end
    return createMap(data)
end