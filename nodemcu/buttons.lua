local gpio = require("gpio")

local lib = {}

PIN_COL0 = 1 -- GPIO5
PIN_COL1 = 2 -- GPIO4
PIN_COL2 = 3 -- GPIO0
PIN_COL3 = 4 -- GPIO2
PIN_ROW0 = 5 -- GPIO14
PIN_ROW1 = 6 -- GPIO12
PIN_ROW2 = 7 -- GPIO13
PIN_ROW3 = 8 -- GPIO15

local debounce_timers = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

function select_row(row)
    gpio.write(PIN_ROW0, gpio.HIGH)
    gpio.write(PIN_ROW1, gpio.HIGH)
    gpio.write(PIN_ROW2, gpio.HIGH)
    gpio.write(PIN_ROW3, gpio.HIGH)
    
    if row == 0 then
        gpio.write(PIN_ROW0, gpio.LOW)
    elseif row == 1 then
        gpio.write(PIN_ROW1, gpio.LOW)
    elseif row == 2 then
        gpio.write(PIN_ROW2, gpio.LOW)
    else
        gpio.write(PIN_ROW3, gpio.LOW)
    end
end

function lib.init_buttons()
    gpio.mode(PIN_COL0, gpio.INPUT)
    gpio.mode(PIN_COL1, gpio.INPUT)
    gpio.mode(PIN_COL2, gpio.INPUT)
    gpio.mode(PIN_COL3, gpio.INPUT)

    gpio.mode(PIN_ROW0, gpio.OPENDRAIN)
    gpio.mode(PIN_ROW1, gpio.OPENDRAIN)
    gpio.mode(PIN_ROW2, gpio.OPENDRAIN)
    gpio.mode(PIN_ROW3, gpio.OPENDRAIN)
end

function lib.read_buttons()
    -- Read Buttons
    local buttons = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}
    for row = 0, 3 do
        select_row(row)
        buttons[4 * row + 1] = not (gpio.read(PIN_COL0) == 1)
        buttons[4 * row + 2] = not (gpio.read(PIN_COL1) == 1)
        buttons[4 * row + 3] = not (gpio.read(PIN_COL2) == 1)
        buttons[4 * row + 4] = not (gpio.read(PIN_COL3) == 1)
    end

    -- Remap the buttons (transpose)
    buttons = {
        buttons[1],
        buttons[5],
        buttons[9],
        buttons[13],
        
        buttons[2],
        buttons[6],
        buttons[10],
        buttons[14],
        
        buttons[3],
        buttons[7],
        buttons[11],
        buttons[15],

        buttons[4],
        buttons[8],
        buttons[12],
        buttons[16],
    }

    -- Check for debounce
    local debounced_buttons = {}
    for i = 1, 16 do
        debounced_buttons[i] = false

        -- Check for press
        if buttons[i] and debounce_timers[i] == 0 then -- Button is pressed and not debounced
            debounced_buttons[i] = true
            debounce_timers[i] = 20
        end

        -- Tick debounce timers
        if debounce_timers[i] > 0 then
            debounce_timers[i] = debounce_timers[i] - 1
        end
    end

    return debounced_buttons
end

return lib
