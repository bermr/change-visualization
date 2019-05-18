return{
    ChangeMap = function(unitTest)
        -- simple test

        local cell = Cell{
            state = "dead",
            otherAttribute = "no",
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
                self.otherAttribute = "yes"
                elseif self.state == "dead" and n == 3 then
                    self.state = "alive"
                    self.otherAttribute = "yes"
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

        local lightspace_map = ChangeMap{
            target = cs,
            select = {"state"},
            type = "accumulation",
            max = 5
        }

        cs:init()
        local timer = Timer{
            Event{action = function()
                cs:synchronize()
                cs:execute()
            end},
            Event{action = lightspace_map}
        }

        unitTest:assertSnapshot(lightspace_map, "Change-map-1-begin.bmp", 0.1)

        timer:run(201)

        unitTest:assertSnapshot(lightspace_map, "Change-map-1-end.bmp", 0.1)

        --test two attributes

        local cell = Cell{
            state = "dead",
            otherAttribute = "no",
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
                self.otherAttribute = "yes"
                elseif self.state == "dead" and n == 3 then
                    self.state = "alive"
                    self.otherAttribute = "yes"
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

        local two_attributes_map = ChangeMap{
            target = cs,
            select = {"state", "otherAttribute"},
            type = "accumulation",
            max = 2,
            color = {"purple", "yellow"}
        }

        cs:init()

        local timer = Timer{
            Event{action = function()
                cs:synchronize()
                cs:execute()
            end},
            Event{action = two_attributes_map}
        }

        unitTest:assertSnapshot(two_attributes_map, "Change-map-2-begin.bmp", 0.1)

        timer:run(201)

        unitTest:assertSnapshot(two_attributes_map, "Change-map-2-end.bmp", 0.1)

        -- test moment change

        local cell = Cell{
            state = "dead",
            otherAttribute = "no",
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
                self.otherAttribute = "yes"
                elseif self.state == "dead" and n == 3 then
                    self.state = "alive"
                    self.otherAttribute = "yes"
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

        local moment_map = ChangeMap{
            target = cs,
            select = {"state"},
            type = "moment",
            max = 5
        }

        cs:init()
        local timer = Timer{
            Event{action = function()
                cs:synchronize()
                cs:execute()
            end},
            Event{action = moment_map}
        }

        unitTest:assertSnapshot(moment_map, "Change-map-3-begin.bmp", 0.1)

        timer:run(201)

        unitTest:assertSnapshot(moment_map, "Change-map-3-end.bmp", 0.1)

        -- test trail change

        local cell = Cell{
            state = "dead",
            otherAttribute = "no",
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
                self.otherAttribute = "yes"
                elseif self.state == "dead" and n == 3 then
                    self.state = "alive"
                    self.otherAttribute = "yes"
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

        local trail_map = ChangeMap{
            target = cs,
            select = {"state"},
            type = "trail",
            max = 5
        }

        cs:init()
        local timer = Timer{
            Event{action = function()
                cs:synchronize()
                cs:execute()
            end},
            Event{action = trail_map}
        }

        unitTest:assertSnapshot(trail_map, "Change-map-4-begin.bmp", 0.1)

        timer:run(201)

        unitTest:assertSnapshot(trail_map, "Change-map-4-end.bmp", 0.1)

        -- test min, max e colors

        local cell = Cell{
            state = "dead",
            otherAttribute = "no",
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
                self.otherAttribute = "yes"
                elseif self.state == "dead" and n == 3 then
                    self.state = "alive"
                    self.otherAttribute = "yes"
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

        local min_map = ChangeMap{
            target = cs,
            select = {"state"},
            type = "accumulation",
            max = 8,
            min = 3
        }

        cs:init()
        local timer = Timer{
            Event{action = function()
                cs:synchronize()
                cs:execute()
            end},
            Event{action = min_map}
        }

        unitTest:assertSnapshot(min_map, "Change-map-5-begin.bmp", 0.1)

        timer:run(201)

        unitTest:assertSnapshot(min_map, "Change-map-5-end.bmp", 0.1)
    end,
}