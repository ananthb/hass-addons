# Globalping

A [Globalping](https://globalping.io) probe. Running one contributes
measurement capacity to a community network that anyone can run ping,
traceroute, DNS, HTTP and MTR tests from, and earns you credits toward
higher API limits.

## Installation

1. Add this repository to the add-on store:
   **Settings → Add-ons → Add-on Store → ⋮ → Repositories** and add
   `https://github.com/ananthb/hass-addons`.
2. Install the **Globalping** add-on.
3. Optionally set an adoption token (below), then start the add-on.

The add-on is the upstream `ghcr.io/jsdelivr/globalping-probe` image plus
one wrapper script — nothing is compiled on your device.

## Adoption

A probe runs and serves measurements without any configuration. Adopting
it links it to your Globalping account, which is what earns credits and
lets you target the probe by name in your own tests.

1. Sign in at [dash.globalping.io](https://dash.globalping.io).
2. Copy the adoption token from **Probes → Adopt a probe**.
3. Paste it into the `adoption_token` option and restart the add-on.

Adoption also works from the dashboard over your local network without a
token — the probe listens on port 7201 for that, and the add-on's host
networking makes it reachable. The token is the reliable path; the
network flow needs the browser and the probe to be on the same LAN.

## Configuration

Option | Default | Description
------ | ------- | -----------
`adoption_token` | *(empty)* | Links the probe to your Globalping account. Leave empty to run an unadopted probe.

## Probe identity

The probe has a UUID, and adopting it binds your account to that UUID. It
is generated once and kept in `/data`, the only directory the Supervisor
preserves across restarts, updates and rebuilds — so an adopted probe
stays adopted.

Upstream keeps it in `/.globalping-probe-uuid`, at the root of the image's
writable layer, which a Home Assistant add-on discards on every rebuild.
That produced a new identity on each update and quietly dropped the probe
out of the account it had been adopted into. This add-on sets
`GP_PROBE_UUID` instead — upstream's own mechanism for read-only systems —
so the probe's logic is unchanged.

Uninstalling the add-on deletes `/data` and with it the UUID. Reinstalling
gives you a new probe that has to be adopted again.

## Versions and self-update

The add-on version is the upstream probe release plus a fourth component
for changes to the packaging: `0.52.0.1` is the first add-on revision of
probe `0.52.0`. It has to be a fourth number rather than the more usual
`-1` or `-r1` — the Supervisor compares versions with `awesomeversion`,
which reads a dash as a semver pre-release, so `0.52.0-1` sorts *below*
`0.52.0` and would never be offered as an update.

`build.yaml` pins the upstream image, so the add-on version tells you
which release you installed. It does not tell you what is running: the
probe checks for a newer release on every start and replaces itself in
place if it finds one. That is upstream's design, and this add-on keeps
it rather than pinning against it — a probe too far behind is dropped
from the network.

The practical consequence is that restarting the add-on can change the
probe version, and reinstalling drops back to the pinned release before
updating forward again.

## Networking

Host networking, so measurements leave over your real network path
rather than Docker's bridge. The probe needs `NET_RAW` for ICMP ping,
traceroute and MTR. It makes only outbound connections to the Globalping
API, apart from the local adoption listener on port 7201.

Because networking is shared with the host, this probe reports your home
IP address and approximate location to the Globalping network, and those
are visible to anyone who runs a measurement through it. That is what a
probe is; it is worth knowing before you start one.

## Support

Add-on issues: [github.com/ananthb/hass-addons](https://github.com/ananthb/hass-addons)

Probe issues: [github.com/jsdelivr/globalping-probe](https://github.com/jsdelivr/globalping-probe)
