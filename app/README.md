# ScribeSense — Flutter App

## Structure
- `lib/screens`   — Home/Live Session, History, AI Coach, Settings
- `lib/services`  — `BleService` (S1.2), `DbService` + `SessionRepository` (S1.3)
- `lib/models`    — `SensorSample`, `DeviceStatus` (S1.2)
- `lib/providers` — `SessionProvider` (S2.2) — session state + throttled live data
- `lib/widgets`   — gauges, charts, indicators (S2+)

## Prerequisites
1. **Flutter SDK** (stable) — `flutter --version` ≥ 3.44.0. Run `flutter doctor` and fix any `[✗]`.
2. **IDE** — Google Antigravity (open the repo root, not just `app/`) or Android Studio/VS Code.
3. **Android SDK** — accept licenses: `flutter doctor --android-licenses`
4. **A device**: either a physical Android phone (USB debugging enabled) for real BLE testing,
   or an Android emulator (`android emulator create medium_phone` then `android emulator start medium_phone`)
   for UI-only work — emulators cannot do Bluetooth.
5. **`.env` file** — `cp .env.example .env` (app crashes on boot without it).
6. `flutter pub get`

## Verify Setup