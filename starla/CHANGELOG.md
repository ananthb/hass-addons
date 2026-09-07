# Changelog

## 0.8.0

Starla [0.8.0](https://github.com/ananthb/starla/releases/tag/v0.8.0).

- The probe's public key is now printed in a clearly marked banner in the
  add-on log, and repeated every 30 minutes until the probe is registered.
  There is no need to restart the add-on to see it any more.
- The **Log level** option now takes effect. It was silently ignored before
  and the probe always logged at `info`.
- Log output is plain text instead of JSON.
- An unregistered probe logs one line per connection attempt with the actual
  error, instead of six warnings.
