# ScribeSense — Hardware ↔ Software Integration Contract
**Version:** 1.0
**Status:** Locked — any change requires a joint PR touching both /firmware
and /app together, with this version number bumped (Charter §6, §10).

## Device Identity
- Device name: `ScribeSense-XXXX` (XXXX = last 4 hex chars of the BLE MAC, uppercase)
- Service UUID: `4fafc201-1fb5-459e-8fcc-c5c9c331914b`

## Characteristics

| Characteristic | UUID | Permissions | Payload |
|---|---|---|---|
| Sensor Data | `4fafc202-1fb5-459e-8fcc-c5c9c331914b` | Notify | Compact JSON, ~50Hz: `t` (ms since boot, uint32), `p` (raw pressure, 0–4095), `ax`/`ay`/`az` (milli-g, int16), `pi`/`ro` (pitch/roll ×100, int16), `f` (flags bitmask), `b` (battery mV, uint16) |
| Control | `4fafc203-1fb5-459e-8fcc-c5c9c331914b` | Write | `{"cmd":"calibrate"}` / `{"cmd":"set_threshold","value":N}` / `{"cmd":"set_sensitivity","mode":"gentle"\|"normal"}` |
| Status | `4fafc204-1fb5-459e-8fcc-c5c9c331914b` | Read, Notify | `{"battery_mv":N,"fw_version":"x.y.z","buffered_samples":N}` — pushed after every accepted Control command |

## Flags bitmask (Sensor Data field `f`)
- bit0 — pen_down
- bit1 — vibration_active
- bit2 — low_battery
- bit3 — drop_event
- bit4 — upside_down

## MTU
Request 247 bytes post-connection. Packets are designed to stay well under
100 bytes so they still fit even on a lower negotiated MTU.

## Privacy rule
Raw per-sample data from this link stays on-device. Only aggregated session
statistics are ever sent to a cloud LLM API (see Software S5.2 and
`ethics-notes.md`).

## Change control
Any change to this file requires a single PR that updates `/firmware` and
`/app` together, in the same PR, with the version number above bumped.
Never a silent one-sided change on either side.
