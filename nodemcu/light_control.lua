local gpio = require("gpio")

local lib = {}

PIN_DATA = 9 -- GPIO3
PIN_CLOCK = 10 -- GPIO1
PIN_LATCH = 0 -- GPIO0

function lib.set_lights(lights)
    gpio.write(PIN_DATA, gpio.LOW)
    gpio.write(PIN_CLOCK, gpio.LOW)
    gpio.write(PIN_LATCH, gpio.LOW)

    for i = 16, 1, -1 do
        if lights[i] == true then
            gpio.write(PIN_DATA, gpio.HIGH)
        else
            gpio.write(PIN_DATA, gpio.LOW)
        end

        gpio.write(PIN_CLOCK, gpio.HIGH)
        gpio.write(PIN_CLOCK, gpio.LOW)
    end

    gpio.write(PIN_LATCH, gpio.HIGH)
    gpio.write(PIN_LATCH, gpio.LOW)
end

function lib.init_lights(lights)
    gpio.mode(PIN_DATA, gpio.OUTPUT)
    gpio.mode(PIN_CLOCK, gpio.OUTPUT)
    gpio.mode(PIN_LATCH, gpio.OUTPUT)

    lib.set_lights({false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false})
end

return lib
