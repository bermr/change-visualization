-- change api

-- recebe os dados e depois cria e inicia um atributo change
-- para cada select passado

function changeMap(data)
    verifyData(data)

    createElements(data)

    if(not data.target.synchronize_) then
        data.target:synchronize()
        updateSynchronize(data)
    end
    createMap(data)

end

-- sobrecarrega o synchronize do cellularspace passado,
-- adicionando o cálculo do change para cada atributo que
-- se deseja visualizar a mudança

function updateSynchronize(data)
    -- salva o synchronize inicial do cspace
    data.target.synchronize_ = data.target.synchronize
    -- sobrescreve o synchronize com o cálculo dos changes
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

-- cria um map para cada atributo change

function createMap(data)

    for i, v in pairs(data.target.change) do
        if (data.target.maps[v] ~= 1) then
            data.target.maps[v] = 1
            local change_ = v .. "Change"
            local mapname = "'"..v:sub(1,1):upper()..v:sub(2) .. " Change'"

            if (data.type == "moment") then
                change_map = Map{
                    title =  mapname,
                    target = data.target,
                    select = change_,
                    color = {"black", "white"},
                    value = {0,1}
                }
            elseif (data.type == "accumulation") then
                change_map = Map{
                    title =  mapname,
                    target = data.target,
                    select = change_,
                    color = {"blue", "red"},
                    min = 0,
                    max = 10,
                    slices = 10
                }
            elseif (data.type == "trail") then
                change_map = Map{
                    title =  mapname,
                    target = data.target,
                    select = change_,
                    color = {"blue",  "red"},
                    min = 0,
                    max = 50,
                    slices = 10
                }
            end
        end
    end
end

function verifyData(data)
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

function createElements(data)
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

function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end