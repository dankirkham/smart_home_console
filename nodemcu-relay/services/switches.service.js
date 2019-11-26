"use strict";

const HTTPClientService = require("moleculer-http-client");
require('dotenv').config();

module.exports = {
	name: "switches",
	mixins: [HTTPClientService],
	settings: {
    httpClient: { includeMethods: ["get", "post"] }
  },
	actions: {
		list: {
			async handler (ctx) {
				const response = await this.actions.get({
					url: process.env.SMARTTHINGS_URL + "/switches",
					opt: {
						headers: {
							"Authorization": "Bearer " + process.env.SMARTTHINGS_TOKEN
						}
					}
				});

				return JSON.parse(response.body);
			}
		},
		set: {
			async handler (ctx) {
				const {id, state} = ctx.params;

				const response = await this.actions.post({
					url: process.env.SMARTTHINGS_URL + "/switches/" + id + "/" + state,
					opt: {
						headers: {
							"Authorization": "Bearer " + process.env.SMARTTHINGS_TOKEN
						}
					}
				});

				return JSON.parse(response.body);
			}
		}
	}
};
