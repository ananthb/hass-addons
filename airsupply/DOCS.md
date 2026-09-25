# airsupply

Reads a ResMed AirMini CPAP from a page in the Home Assistant sidebar: the
machine's firmware, its clock, your therapy settings and the run meters. It
writes nothing to the machine, and it does not record anything over time yet —
there are no sensors and no history, only the last reading on the page.

The AirMini speaks Bluetooth Classic, not BLE, so none of Home Assistant's own
Bluetooth machinery reaches it and the host has to be within about ten metres
of the machine. In practice that means Home Assistant runs in the bedroom, or
this add-on is not the right thing to run.

## Install

1. **Settings → Add-ons → Add-on Store → ⋮ → Repositories**, and add
   `https://github.com/ananthb/hass-addons`.
2. Install **airsupply**, start it, and open it from the sidebar (or
   **Open Web UI** on the add-on page).

The image already contains [libairmini][] built from a pinned commit, so
nothing is compiled on your device. The add-on starts manually rather than on
boot.

[libairmini]: https://github.com/psychoticbeef/libairmini

## Setting it up

Once, in one pass, with the machine in reach. Put the AirMini into **pairing
mode** first — it is neither discoverable nor connectable unless it is, and it
leaves pairing mode on its own after a short while, so the whole of this is
quicker than it reads.

**Look for machines.** Anything AirMini-shaped is listed first, with its signal
strength. Worse than about −80 dBm and a session will not hold. Press **Use**
on the machine. If nothing appears while it is in pairing mode, the host is out
of range, which is worth knowing early.

**Pair.** The Bluetooth pairing between the host and the machine. Press it
within a few seconds of the machine lighting up. Bluetooth may ask a question —
a PIN to type, or a six-digit code to confirm — and it appears on the page.
What the AirMini actually asks is not yet known; please report what you see.

**Connect.** Now the machine's own pairing, which is a different thing: type
the PIN on its screen. Needed exactly once. What it buys is a key the add-on
keeps in its private data directory and uses for every connection after that —
no PIN, and nobody standing at the machine. The PIN itself is never stored and
never logged.

After that the page shows the machine, when it was last read, and the reading
itself. **Read now** takes a fresh one, and a reading also runs each time the
add-on starts. **Change machine** is where switching machines and **Forget**
live; forget it if the machine has been factory reset.

A read that fails says so on its own line rather than taking the others down
with it, so three of four is still a reading. **Activity** at the foot of the
page is the add-on's log, if you want to see what it is doing.

## If it goes wrong

| what it says | what it usually means |
|---|---|
| Home Assistant has no Bluetooth adapter | the host has no Bluetooth, or BlueZ is not running |
| the machine never answered (*Page Timeout*) | it left pairing mode, or the host is out of range |
| no pairing agent | BlueZ refused our agent; the log from start-up says why |
| AuthenticationFailed | the wrong answer to Bluetooth's question, or the machine left pairing mode mid-way |
| ConnectProfile failed | the machine is asleep, out of range, or already talking to the phone app |
| NewConnection never arrived | Bluetooth connected but never handed over the channel — usually an AppArmor denial; check the Supervisor log |
| the handshake times out | the channel opened and the machine is not answering — set `log_level: debug` and send the log |

The reading, with the serial number taken out, is genuinely useful to
[ananthb/airsupply](https://github.com/ananthb/airsupply/issues): every AirMini
this has run against is one more than the protocol work had.

## What it deliberately does not do

Write. The configuration-write path in the underlying protocol library is
unverified upstream, this is a machine someone sleeps attached to, and the read
path comes first. The add-on will not send any method that is not a read, so
reaching a write means changing its source on purpose. `docs/verify.md` in
ananthb/airsupply is where that case would have to be made.
