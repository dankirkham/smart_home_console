import React from 'react';
import {
  AppBar,
  Box,
  Button,
  Container,
  Grid,
  Paper,
  Switch,
  Table,
  TableBody,
  TableCell,
  TableRow,
  Toolbar,
  Typography,
} from '@material-ui/core';
import {useInterval} from "react-use";
import superagent from "superagent";

const LIGHTS = [
  {
    name: "Computer Room",
    id: "d41e29f1-2637-4374-8d24-2871d6047e20"
  },
  null,
  null,
  {
    name: "Cat Room",
    id: "b87d4981-0a2c-4a1a-98df-f3e415bcf7cb"
  },
  {
    name: "Downstairs Hall Light 1",
    id: "7df74b1c-b5c0-42bd-b4d4-289c2d445027"
  },
  {
    name: "Downstairs Hall Light 2",
    id: "41d80e06-69e2-41aa-a72d-8416edfc0f13"
  },
  null,
  null,
  {
    name: "Dan's Lamp",
    id: "b4d43e94-140e-4aee-bd6e-c0990b1bb0c5"
  },
  null,
  {
    name: "Living Room Lamp 2",
    id: "c50d7ecb-9d79-4ca0-8b66-ee846883fdff"
  },
  {
    name: "Living Room Light",
    id: "00dae423-8033-4227-81dc-1781d710b557"
  },
  null,
  {
    name: "Bedroom Light",
    id: "77975a0d-f358-4c39-96d6-ae70c768d204"
  },
  null,
  {
    name: "Living Room Lamp",
    id: "86ed625c-11ea-4997-b7d2-e0583866000b"
  }
]

const LightSwitch = ({light, state}) => {
  const {name, id} = light;

  const toggle = () => {
    superagent.post('/api/switches/set', {
      id,
      state: state === "on" ? "off" : "on"
    });
  };

  return <Container fixed>
    {name}
    <Switch color="primary" checked={state === "on"} onClick={toggle} />
  </Container>;
}

export default () => {
  const [switchStates, setSwitchStates] = React.useState({});

  useInterval(() => {
    superagent.get('/api/switches/list')
      .then(switches => {
        if (!switches || !Array.isArray(switches)) return;

        const newState = {};
        switches.map(s => {
          newState[s.id] = s.state;
        });

        setSwitchStates(newState);
      })
  }, 1000);

  const turnOffAllLights = () => {
    for (let id in switchStates) {
      if (switchStates[id] === "on") {
        superagent.post('/api/switches/set', {
          id,
          state: "off"
        });
      }
    }
  };

  return <Box>
    <AppBar position="static">
      <Toolbar>
        <Typography>
          The Weird Blue House
        </Typography>
      </Toolbar>
    </AppBar>
    <Container>
      <Paper>
        <Button variant="contained" color="primary" onClick={turnOffAllLights} >
          Turn off all lights
        </Button>
      </Paper>
      <Paper>
        <Table>
          <TableBody>
            <TableRow>
              {
                LIGHTS.slice(0, 4).map(
                  light => <TableCell>
                    {light && <LightSwitch light={light} state={switchStates[light.id]} />}
                  </TableCell>
                )
              }
            </TableRow>
            <TableRow>
              {
                LIGHTS.slice(4, 8).map(
                  light => <TableCell>
                    {light && <LightSwitch light={light} state={switchStates[light.id]} />}
                  </TableCell>
                )
              }
            </TableRow>
            <TableRow>
              {
                LIGHTS.slice(8, 12).map(
                  light => <TableCell>
                    {light && <LightSwitch light={light} state={switchStates[light.id]} />}
                  </TableCell>
                )
              }
            </TableRow>
            <TableRow>
              {
                LIGHTS.slice(12, 16).map(
                  light => <TableCell>
                    {light && <LightSwitch light={light} state={switchStates[light.id]} />}
                  </TableCell>
                )
              }
            </TableRow>
          </TableBody>
        </Table>
      </Paper>
    </Container>
  </Box>;
}
