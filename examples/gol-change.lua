-- Game of Life model

--require("changeApi")

PROBABILITY = 0.15
TURNS = 1000

cell = Cell{
    change = 0,
    state = Random{alive = PROBABILITY, dead = 1 - PROBABILITY, seed = 142030}, --seed 123 monstro nordeste t 775
    --state = "dead",
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
        self.change = self.past.change + 1
        elseif self.state == "dead" and n == 3 then
            self.state = "alive"
            self.change = self.past.change + 1
        else
            self.state = self.past.state
        end
    end
}

cs = CellularSpace{
xdim = 100,
instance = cell,
init = function(self)
--[[    --glider
        self:get(50,50).state = "alive"
        self:get(51,50).state = "alive"
        self:get(49,50).state = "alive"
        self:get(49,51).state = "alive"
        self:get(50,52).state = "alive"

        self:get(50,54).state = "alive"
        self:get(50,53).state = "alive"
        self:get(50,52).state = "alive"

        self:get(50,48).state = "alive"
        self:get(50,47).state = "alive"
        self:get(50,46).state = "alive"
        ]]
--[[    blinkers
        self:get(48,50).state = "alive"
        self:get(47,50).state = "alive"
        self:get(46,50).state = "alive"

        self:get(52,50).state = "alive"
        self:get(53,50).state = "alive"
        self:get(54,50).state = "alive"
        ]]
--[[    --beacon
        self:get(50,50).state = "alive"
        self:get(51,50).state = "alive"
        self:get(50,49).state = "alive"
        self:get(51,49).state = "alive"

        self:get(52,48).state = "alive"
        self:get(53,48).state = "alive"
        self:get(52,47).state = "alive"
        self:get(53,47).state = "alive"
        ]]
    end
}

cs:createNeighborhood()

map = Map{
title = "Normal Map",
target = cs,
select = "state",
color = {"black", "lightGray"},
value = {"alive", "dead"}
}

map2 = Map{
target = cs,
select = "change",
color = {"blue", "red"},
min = 0,
max = 100,
slices = 10
}

--[[map3 = Map{
target = cs,
select = "change",
color = {"yellow", "purple", "green", "red", "brown", "blue", "orange", "gray","magenta", "black" },
min = 0,
max = 100,
slices = 10
}]]

cs:init()

t=0
timer = Timer{
Event{action = function(ev)
cs:synchronize()
cs:execute()
        --if t % 10 == 0 then map:save("scshots/glider_"..t..".bmp") end
        if t == 1 then io.stdin:read(1) end
        if t == 2 then io.stdin:read(1) end

        t = t + 1
        --print(t)
        --map2:save("gliderchange"..t..".bmp")

        --print(ev:getTime())
        --timer:notify()
        end},
        Event{action = map, period = 1},
        Event{action = map2, period = 1}
--        Event{action = map3, period = 2}
    }

--clk = Clock{target = timer}
timer:run(TURNS)
--colocar o clock
