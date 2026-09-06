# Home Assistant add-ons

Network measurement probes, packaged as Home Assistant add-ons.

[![Add repository to your Home Assistant instance](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fananthb%2Fhass-addons)

Add `https://github.com/ananthb/hass-addons` under **Settings → Add-ons →
Add-on Store → ⋮ → Repositories**, then install what you want.

## Add-ons

Add-on | What it does
------ | ------------
[**Starla**](starla/DOCS.md) | An unofficial [RIPE Atlas](https://atlas.ripe.net) software probe, written in Rust. Source: [ananthb/starla](https://github.com/ananthb/starla).
[**Globalping**](globalping/DOCS.md) | A [Globalping](https://globalping.io) probe. Source: [jsdelivr/globalping-probe](https://github.com/jsdelivr/globalping-probe).

Both run with host networking so measurements leave over your real
network path, and both make your home IP address and approximate
location visible to the measurement network they join. That is the point
of a probe, and it is worth knowing before you start one.

## How these are built

Every add-on here is a thin wrapper over an image somebody else already
publishes — `ghcr.io/ananthb/starla` and
`ghcr.io/jsdelivr/globalping-probe`. The Supervisor assembles each one on
your device at install time, which costs a pull and a `COPY`; nothing is
compiled locally.

So this repository holds the real build contexts rather than references
to prebuilt add-on images. There is no release pipeline here and no
version to keep in lockstep across repositories — the only thing CI
checks is that the image tag an add-on names actually exists.

## Licence

AGPL-3.0-or-later. See [LICENSE](LICENSE).

The upstream images keep their own licences: starla is AGPL-3.0-or-later,
the Globalping probe is ISC.
