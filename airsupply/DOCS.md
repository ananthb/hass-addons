# airsupply

**This add-on does not monitor anything yet.** It is a diagnostic. From a page
in the Home Assistant sidebar it finds your ResMed AirMini, bonds with it over
Bluetooth, pairs with it, and reads four things back: firmware version, the
machine's clock, your therapy settings, and the run meters. It writes nothing.

## Why a diagnostic first

The AirMini speaks Bluetooth Classic RFCOMM, not BLE, so none of the usual Home
Assistant Bluetooth machinery reaches it. Several things had to be true before
writing a monitor, and only one of them was answerable from a desk:

1. The Home Assistant host has to be within about ten metres of the machine.
2. An add-on container has to be allowed to use Bluetooth Classic at all.
3. The bond has to form, the serial channel has to open, and the handshake
   has to complete.
4. The reads have to reproduce on your machine, not just the one they were
   recovered from.

Number 2 is settled — see `docs/verify.md` in
[ananthb/airsupply](https://github.com/ananthb/airsupply). The page answers
1, 3 and 4 on your own hardware, in that order, and stops at whichever one it
cannot get past.

## Installation

1. Add this repository to the add-on store:
   **Settings → Add-ons → Add-on Store → ⋮ → Repositories** and add
   `https://github.com/ananthb/hass-addons`.
2. Install the **airsupply** add-on, start it, and open it from the sidebar
   (or **Open Web UI** on the add-on page).

The add-on image is assembled locally from `ghcr.io/ananthb/airsupply`, which
already contains [libairmini][] built from a pinned commit — nothing is
compiled on your device. It is set to start manually, not on boot, until it
has proven it can talk to the machine.

[libairmini]: https://github.com/psychoticbeef/libairmini

## The page

Four numbered steps. Each unlocks the next, and the activity log at the bottom,
newest first,
is the same text as the add-on log, so nothing has to be fished out of
**Log** any more.

### 1 — Find the machine

Put the AirMini into **pairing mode** — it does not stay discoverable — and
press **Scan**. Anything AirMini-shaped is listed first, with:

| | meaning |
|---|---|
| **Signal** | worse than about −80 dBm and a session will not hold |
| **Classic** | the transport is Bluetooth Classic, as expected. **BLE** means something is wrong with our understanding |
| **Serial** | the Serial Port service is advertised. *no SDP yet* is normal before the bond |

Press **Use** on the machine. If nothing AirMini-shaped appears while the
machine is in pairing mode, the host is out of range. That is a real answer:
the phone app has to be the one that reads, and Home Assistant gets the data
from there instead.

### 2 — Bluetooth bond

The link-layer pairing between the host and the machine, done once. Press
**Bond over Bluetooth**. BlueZ may ask a question — a PIN, or whether a
six-digit code matches — and it appears on the page under the button. Answer
within a minute. What the AirMini actually asks is not yet known; please
report it.

### 3 — Pair with the machine and read

This is the machine's own pairing, separate from step 2. With the machine in
pairing mode, type the number on its screen and press **Pair and read**.

The PIN is needed exactly once. What it buys is a `masterPairKey`, which the
add-on stores in its private data directory and uses for every connection
after that — no PIN, nobody standing at the machine. The PIN itself is never
stored and never logged. Once the key exists the page offers **Connect and
read** instead, and the reads also run on every add-on start.

**Forget this machine** removes the Bluetooth bond and the stored key. Use it
if the machine has been factory reset.

### 4 — Results

The four reads, each reported on its own, so three of four working is still a
result. A good run ends with all four green and the activity log saying:

```
All four reads returned. That is experiment 5 answered.
```

Please send that log — with the serial numbers taken out — to
[ananthb/airsupply](https://github.com/ananthb/airsupply/issues). It is the
evidence the rest of the project is waiting on.

### If it goes wrong

| symptom | likely cause |
|---|---|
| *No Bluetooth adapter is visible over D-Bus* | the host has no Bluetooth, or BlueZ is not running |
| *no pairing agent* | BlueZ refused our agent; the add-on log from start-up says why |
| bond fails with *AuthenticationFailed* | the wrong answer to BlueZ's question, or the machine left pairing mode |
| `ConnectProfile failed` | the machine is asleep, out of range, or already talking to the phone app |
| `NewConnection never arrived` | BlueZ accepted the connect but never handed over the fd — an AppArmor denial is the usual reason; check the Supervisor log |
| the handshake times out | the channel opened but the machine is not answering — set `log_level: debug` and capture the byte counts |

## What it deliberately does not do

Write. The `Set` path in the underlying protocol library is unverified upstream,
this is a medical device, and the read path has to be proven first. The add-on
refuses to send any method that is not a read, so getting to a write means
changing its source on purpose. See `docs/verify.md` in ananthb/airsupply for
the order the remaining experiments go in.
