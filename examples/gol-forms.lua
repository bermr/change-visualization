-- Game of Life patterns
local arg={ ... }

require("changeApi")

PROBABILITY = 0.15
TURNS = 1000
TYPE = 'unnamed' --type of initial pattern

cell = Cell{
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

cs = CellularSpace{
xdim = 100,
instance = cell,
init = function(self)
    if TYPE == 'glider' then
        self:get(50,50).state = "alive"
        self:get(51,50).state = "alive"
        self:get(49,50).state = "alive"
        self:get(49,51).state = "alive"
        self:get(50,52).state = "alive"
    elseif TYPE == 'blinkers' then
        self:get(48,50).state = "alive"
        self:get(47,50).state = "alive"
        self:get(46,50).state = "alive"
        self:get(52,50).state = "alive"
        self:get(53,50).state = "alive"
        self:get(54,50).state = "alive"
    elseif TYPE == 'beacon' then
        self:get(50,50).state = "alive"
        self:get(51,50).state = "alive"
        self:get(50,49).state = "alive"
        self:get(51,49).state = "alive"
        self:get(52,48).state = "alive"
        self:get(53,48).state = "alive"
        self:get(52,47).state = "alive"
        self:get(53,47).state = "alive"
    elseif TYPE == 'unnamed' then         -- accumulation
        self:get(50,50).state = "alive"   -- celtic cross
        self:get(49,50).state = "alive"
        self:get(51,50).state = "alive"
        self:get(50,51).state = "alive"
    elseif TYPE == 'lightship' then       -- accumulation
        self:get(95,50).state = "alive"   -- straight line (lightsaber)
        self:get(99,50).state = "alive"
        self:get(94,51).state = "alive"
        self:get(94,52).state = "alive"
        self:get(94,53).state = "alive"
        self:get(95,53).state = "alive"
        self:get(96,53).state = "alive"
        self:get(97,53).state = "alive"
        self:get(98,52).state = "alive"
    elseif TYPE == 'f-pentomino' then     -- accumulation
        self:get(50,50).state = "alive"   -- this pattern stables
        self:get(51,50).state = "alive"   -- after a thousand iteractions
        self:get(50,51).state = "alive"
        self:get(50,52).state = "alive"
        self:get(49,51).state = "alive"
    elseif TYPE == 'gun' then
        self:get(20,50).state = "alive"   -- accumulation
        self:get(20,51).state = "alive"   -- mosquito
        self:get(21,50).state = "alive"
        self:get(21,51).state = "alive"

        self:get(30,50).state = "alive"   -- trail
        self:get(30,51).state = "alive"   -- fountain
        self:get(30,52).state = "alive"
        self:get(31,53).state = "alive"
        self:get(32,54).state = "alive"
        self:get(33,54).state = "alive"
        self:get(35,53).state = "alive"
        self:get(36,52).state = "alive"
        self:get(36,51).state = "alive"
        self:get(36,50).state = "alive"
        self:get(34,51).state = "alive"
        self:get(37,51).state = "alive"
        self:get(35,49).state = "alive"
        self:get(33,48).state = "alive"
        self:get(32,48).state = "alive"
        self:get(31,49).state = "alive"

        self:get(40,48).state = "alive"
        self:get(40,49).state = "alive"
        self:get(40,50).state = "alive"
        self:get(41,48).state = "alive"
        self:get(41,49).state = "alive"
        self:get(41,50).state = "alive"
        self:get(42,47).state = "alive"
        self:get(42,51).state = "alive"
        self:get(44,46).state = "alive"
        self:get(44,47).state = "alive"
        self:get(44,51).state = "alive"
        self:get(44,52).state = "alive"

        self:get(54,48).state = "alive"
        self:get(55,48).state = "alive"
        self:get(54,49).state = "alive"
        self:get(55,49).state = "alive"
    elseif TYPE == 'baker' then
        self:get(45,54).state = "alive"  -- weird
        self:get(46,54).state = "alive"
        self:get(46,55).state = "alive"
        self:get(47,54).state = "alive"
        self:get(48,53).state = "alive"
        self:get(49,52).state = "alive"
        self:get(50,51).state = "alive"
        self:get(51,50).state = "alive"
        self:get(52,49).state = "alive"
        self:get(53,48).state = "alive"
        self:get(54,47).state = "alive"
        self:get(55,46).state = "alive"
        self:get(56,45).state = "alive"
        self:get(57,44).state = "alive"
        self:get(58,43).state = "alive"
        self:get(59,42).state = "alive"
        self:get(60,42).state = "alive"
        self:get(60,43).state = "alive"
    end
end
}

cs:createNeighborhood()

map = Map{
title = "Normal Map",
target = cs,
select = "state",
color = {"black", "white"},
value = {"alive", "dead"}
}

changeMap{
    target = cs,
    select = {"state"},
    type = "accumulation"
}

t=0
cs:init()
timer = Timer{
Event{action = function(ev)
    t = t+1
    cs:synchronize()
    cs:execute()
    if t == 1 then io.stdin:read(1) end
end},
Event{action = map, period = 1}
}

timer:run(TURNS)