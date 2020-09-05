local light_control = require("light_control")
local buttons = require("buttons")
local mqtt = require("mqtt")

local switch_state = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false}

function do_buttons()
    buttons_pressed = buttons.read_buttons()
    for i = 1, 16 do
        if buttons_pressed[i] then
            local payload
            if switch_state[i] then
                print('Turning off ' ..  i)
                payload = "OFF"
            else
                print('Turning on ' ..  i)
                payload = "ON"
            end

            m:publish(MQTT_TOPIC .. "/button" .. i .. "/state", payload, 0, 0)

            switch_state[i] = not switch_state[i]
            light_control.set_lights(switch_state)
        end
    end
end

function do_available()
  m:publish(MQTT_TOPIC .. "/availability", "online", 0, 0)
end

function on_post_done()
    local timer = tmr.create()

    light_control.set_lights(switch_state)

    local button_timer = tmr.create()
    button_timer:register(20, tmr.ALARM_AUTO, do_buttons)
    button_timer:start()

    local availability_timer = tmr.create()
    availability_timer:register(1000, tmr.ALARM_AUTO, do_available)
    availability_timer:start()
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

function handle_message(client, topic, message)
  local switch_number = tonumber(string.match(topic, "%d+"))
  switch_state[switch_number] = message == "ON"
  m:publish(MQTT_TOPIC .. "/button" .. switch_number .. "/state", message, 0, 0)
  light_control.set_lights(switch_state)
end

function mqtt_connected()
  print("Connected to MQTT");
  m:on("message", handle_message)
  for i = 1, 16 do
    local topic = MQTT_TOPIC .. "/button" .. i .. "/set"
    m:subscribe(topic, 0)
  end
  post()
end

m = mqtt.Client(MQTT_CLIENT_ID, MQTT_KEEPALIVE)
m:connect(MQTT_HOST, MQTT_PORT, mqtt_connected)
