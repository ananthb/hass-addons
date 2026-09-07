# Home Assistant add-ons

Ananth's Home Assistant add-ons.

[![Add repository to your Home Assistant instance](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fananthb%2Fhass-addons)

Add `https://github.com/ananthb/hass-addons` to your Home Assistant instance.


## Add-ons

Add-on | Source
------ | ------------
[Starla](starla/DOCS.md) | [ananthb/starla](https://github.com/ananthb/starla).
[Globalping](globalping/DOCS.md) | [jsdelivr/globalping-probe](https://github.com/jsdelivr/globalping-probe).
[airsupply](airsupply/DOCS.md) | [ananthb/airsupply](https://github.com/ananthb/airsupply).


## How these are built

Every add-on here is a thin wrapper over a published container.
This repository holds the real build instructions.
The only thing CI here checks is that the image tag for an add-on actually exists.


## Licence

AGPL-3.0-or-later. See [LICENSE](LICENSE).

The upstream projects keep their own licences: starla is AGPL-3.0-or-later,
the Globalping probe is ISC, airsupply is GPL-3.0-only.
