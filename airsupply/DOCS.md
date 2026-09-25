# airsupply

Monitors a ResMed AirMini CPAP over Bluetooth. Each machine becomes a device in
Home Assistant belonging to one of your people, with sensors for therapy hours,
when it was last used, what state it is in and the pressures it is set to. It
writes nothing to the machine.

The AirMini speaks Bluetooth Classic, not BLE, so none of Home Assistant's own
Bluetooth machinery reaches it and the host has to be within about ten metres.
In practice that means Home Assistant runs in the bedroom, or this add-on is
not the right thing to run.

## Before you install

**Install the Mosquitto broker add-on** if you have not already. That is how
the sensors reach Home Assistant. Without it the page still finds, pairs with
and reads a machine — nothing here needs a broker to work — but nothing
appears outside the page.

## Install

1. **Settings → Add-ons → Add-on Store → ⋮ → Repositories**, and add
   `https://github.com/ananthb/hass-addons`.
2. Install **airsupply**, start it, and open it from the sidebar.

The image already contains [libairmini][] built from a pinned commit, so
nothing is compiled on your device.

[libairmini]: https://github.com/psychoticbeef/libairmini

## Setting a machine up

Once per machine, with it in reach. Put the AirMini into **pairing mode**
first — it is neither discoverable nor connectable unless it is, and it leaves
pairing mode on its own after a short while, so the whole of this is quicker
than it reads.

**Look for machines,** and **Add** yours when it appears with a signal
strength. Worse than about −80 dBm and a session will not hold. If nothing
appears while it is in pairing mode, the host is out of range, which is worth
knowing early.

**Pair.** The Bluetooth pairing between the host and the machine. Press it
within a few seconds of the machine lighting up. On the firmware this has been
tried against it asks nothing and takes about a second; if yours does ask — a
PIN to type, or a code to confirm — the question appears on the page.

**Connect.** The machine's own pairing, which is a different thing: type the
PIN on its screen. Needed exactly once. What it buys is a key the add-on keeps
in its private data directory and uses for every connection after that — no
PIN, and nobody standing at the machine.

**Say whose it is.** Under **Machines**, pick the person each machine belongs
to from your Home Assistant people. The machine is stored against that person's
id rather than their name, so renaming them in Home Assistant does not orphan
it. A machine with nobody assigned still works; its device is just named after
the machine.

## What appears in Home Assistant

One device per machine, named for its person, carrying:

| | |
|---|---|
| Therapy hours | the therapy run meter, as hours |
| Machine hours | the machine run meter — diagnostic |
| Last used | when therapy last ran |
| Status | `Standby`, `Therapy`, and whatever else the machine reports |
| Therapy mode | `AutoSet`, `CPAP`, `HerAuto` |
| Minimum / Maximum / Set pressure | from the profile actually in force |
| In therapy | on while the machine is running |
| Last read | when the add-on last got an answer — diagnostic |

Only what your machine reports is created. A machine on AutoSet has no set
pressure, so no such sensor appears; switch it to CPAP and one turns up at the
next read.

Because these arrive by MQTT discovery they are real entities: rename them,
move them to an area, chart them, use them in automations. They survive a Home
Assistant restart, and they all go unavailable together if the add-on stops.

## Reading on a schedule

Every 15 minutes by default, which `read_every_minutes` changes. Each read
costs about ten seconds, and during it **ResMed's own app cannot reach the
machine** — the AirMini accepts one connection at a time. Several machines are
read one after another for the same reason.

The numbers only move while somebody is asleep, so there is nothing to gain
from reading often. If you use the phone app regularly, make the interval
longer.

## If it goes wrong

| what it says | what it usually means |
|---|---|
| Home Assistant has no Bluetooth adapter | the host has no Bluetooth, or BlueZ is not running |
| the machine never answered (*Page Timeout*) | it left pairing mode, or the host is out of range |
| ConnectProfile failed | the machine is asleep, out of range, or the phone app has it |
| NewConnection never arrived | Bluetooth connected but never handed over the channel — usually an AppArmor denial; check the Supervisor log |
| the handshake times out | the channel opened and the machine is not answering — set `log_level: debug` and send the log |
| No MQTT broker | install the Mosquitto add-on and restart this one |
| Home Assistant's people are not available | the add-on could not reach the core API; restarting it re-reads the list |

The reading, with the serial number taken out, is genuinely useful to
[ananthb/airsupply](https://github.com/ananthb/airsupply/issues): every AirMini
this has run against is one more than the protocol work had.

## What it deliberately does not do

Write. The configuration-write path in the underlying protocol library is
unverified upstream, this is a machine someone sleeps attached to, and the read
path comes first. The add-on will not send any method that is not a read, so
reaching a write means changing its source on purpose.
