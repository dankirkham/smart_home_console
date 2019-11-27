local light_control = require("light_control")
local buttons = require("buttons")
local http = require("http")
local sjson = require("sjson")

function on_post_done()
    local timer = tmr.create()
    local switch_state = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}

    function do_buttons()
        buttons_pressed = buttons.read_buttons()

        for i = 1, 16 do
            if buttons_pressed[i] then
                local data
                if switch_state[i] then
                    print('Turning off ' ..  ID_MAP[i])
                    data = '{"id":"' .. ID_MAP[i] .. '","state":"off"}'
                else
                    print('Turning on ' ..  ID_MAP[i])
                    data = '{"id":"' .. ID_MAP[i] .. '","state":"on"}'
                end
                http.post(API_ENDPOINT .. "/switches/set",
                  'Content-Type: application/json\r\n',
                  data,
                  function(code, data)
                    if (code < 0) then
                      print("HTTP request failed")
                    else
                      print(code, data)
                    end
                  end)
            end
        end
    end

    function query_switches()
      headers = "Authorization: Bearer " .. API_TOKEN .. "\r\n"
      http.get(API_ENDPOINT .. "/switches/list", headers, function (code, data)
        if code == 200 then
          switches = sjson.decode(data)
          local changed = false

          for i = 1, #switches do
            local id = switches[i]['id']
            local switch = SWITCH_MAP[id]
            local newstate = (switches[i]['value'] == 'on')

            if switch_state[switch] ~= newstate then
              if newstate then
                print(id .. " is now on")
              else
                print(id .. " is now off")
              end
              switch_state[switch] = newstate
              changed = true
            end
          end

          if changed then
              light_control.set_lights(switch_state)
          end
        end
      end)

    end

    -- init
    switch_state = buttons.read_buttons()
    light_control.set_lights(switch_state)

    local button_timer = tmr.create()
    button_timer:register(20, tmr.ALARM_AUTO, do_buttons)
    button_timer:start()

    local query_timer = tmr.create()
    query_timer:register(1000, tmr.ALARM_AUTO, query_switches)
    query_timer:start()
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

light_control.init_lights()
buttons.init_buttons()
post()
