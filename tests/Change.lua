return{
    ChangeMap = function(unitTest)
        local cell = Cell{
            state = "dead",
            countAlive = function(self)
                local count = 0
                forEachNeighbor(self, function(neigh)
                    if neigh.past.state == "alive" then
                        count = count + 1
                    end
                end)
                return count
            end,
            execute = function(self)
            local n = self:countAlive()
            if self.state == "alive" and (n > 3 or n < 2) then
                self.state = "dead"
                elseif self.state == "dead" and n == 3 then
                    self.state = "alive"
                else
                    self.state = self.past.state
                end
            end
        }

        local cs = CellularSpace{
            xdim = 100,
            instance = cell,
            init = function(self)
                self:get(95,50).state = "alive"
                self:get(99,50).state = "alive"
                self:get(94,51).state = "alive"
                self:get(94,52).state = "alive"
                self:get(94,53).state = "alive"
                self:get(95,53).state = "alive"
                self:get(96,53).state = "alive"
                self:get(97,53).state = "alive"
                self:get(98,52).state = "alive"
            end
        }

        cs:createNeighborhood()

        local change_map = ChangeMap{
            target = cs,
            select = {"state"},
            type = "accumulation",
            max = 5
        }

        cs:init()
        local timer = Timer{
            Event{action = function(ev)
            cs:synchronize()
            cs:execute()
            end},
            Event{action = change_map}
        }

        unitTest:assertSnapshot(change_map, "Change-map-1-begin.bmp", 0.1)

        timer:run(201)

        unitTest:assertSnapshot(change_map, "Change-map-1-end.bmp", 0.1)
    end,
}