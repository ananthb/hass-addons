# Changelog

## 0.4.2

- Really fixes the page breaking after an update with "the add-on is not
  answering". 0.4.1 asked your browser not to keep the old page, which does
  nothing for a browser that already had it; the page's address now carries
  the version, so an old one cannot be loaded against a new add-on.

## 0.4.1


- The page no longer breaks after an update with "the add-on is not
  answering". Your browser could keep the previous version's page and run it
  against the new one; a hard refresh used to be the cure and is no longer
  needed.
- The log no longer repeats "Carried 1 machine(s) over from the previous
  format" for ever.

## 0.4.0


- Several machines, each with its own pairing key and its own readings.
- Each machine belongs to one of your Home Assistant people, and becomes a
  device named for them with sensors for therapy hours, last used, status,
  therapy mode and the pressures in force. Published over MQTT, so install the
  Mosquitto broker add-on if you have not.
- Reads on a schedule instead of on a button. `read_every_minutes` sets how
  often; every read costs the phone app the machine for about ten seconds.
- Starts on boot.
- The page leads with the few things a reading is about; everything the machine
  said is one disclosure below.

## 0.3.3

- The PIN is needed once, as it always claimed. The key the machine hands back
  was being dropped, so every connection asked for the PIN again and the
  reading on start-up never ran.
- Two rows on the page no longer read "Software application identifier" with
  different values; each is named by the part of the machine it came from.

## 0.3.2

- No change you can see.

## 0.3.1

- Run meters read as hours and dates read as dates, rather than as the
  machine's own `PT2591392S`.

## 0.3.0

- A page instead of a lab notebook: the machine, what it is doing, and what it
  last read.

## 0.2.1

- The Bluetooth pairing stops failing with *Page Timeout* when pressed while
  the add-on is still scanning.

## 0.2.0

- Find, pair and read from a page in the sidebar.
