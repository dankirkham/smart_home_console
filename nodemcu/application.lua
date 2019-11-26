local light_control = require("light_control")
local buttons = require("buttons")
local http = require("http")
-- local sjson = require("sjson")

function on_post_done()
    local timer = tmr.create()
    local switch_state = {}

    function do_buttons()
        buttons_pressed = buttons.read_buttons()
        local changed = false

        for i = 1, 16 do
            if buttons_pressed[i] then
                print("Button Pressed")
                changed = true
                switch_state[i] = not switch_state[i]
            end
        end

        if changed then
            light_control.set_lights(switch_state)
        end
    end

    function query_switches()
      headers = "Authorization: Bearer " .. API_TOKEN .. "\r\n"
      print(headers)
      http.get(API_ENDPOINT .. "/switches", headers, function (code, data)
        -- if code == 200 then
          -- buttons = sjson.decode(data)
          -- print(buttons)
          print(data)
        -- end
      end)

    end

    -- init
    switch_state = buttons.read_buttons()
    light_control.set_lights(switch_state)

    timer:register(20, tmr.ALARM_AUTO, do_buttons)
    timer:start()

    query_switches()
end

function post()
    blink_count = 1
    timer = tmr.create()

    function do_post()
        lights = {}
        lights[blink_count] = true

        light_control.set_lights(lights)

        blink_count = blink_count + 1
        if blink_count > 17 then
            timer:unregister()
            print("POSTed")
            on_post_done()
        end
    end

    timer:register(250, tmr.ALARM_AUTO, do_post)
    timer:start()
end

-- light_control.init_lights()
buttons.init_buttons()
post()
