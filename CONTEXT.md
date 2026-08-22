# ScribeSense — Agent Context

## What this repo is
SIH1579 hackathon project. Two tracks: `/firmware` (linear, one hardware owner) and
`/app` (Flutter, five-person parallel software track).

## Current work: Software Phase S2 only
I am the Mobile App Lead. I own S1 (done) and S2 (in progress) ONLY.
- DO NOT touch S3, S4, S5, S6, S7, or S8 files/logic. Other teammates own those.
- DO NOT modify docs/integration-contract.md without flagging it to me first.

## Non-negotiable rules
- Run `dart format .` before every commit; Conventional Commits (feat:, fix:, docs:, chore:).
- Every commit message names the vertical it closes, e.g. "closes S2.1".
- BLE field names must match docs/integration-contract.md EXACTLY.

## Known gap
docs/integration-contract.md's Status characteristic only carries battery_mv, fw_version,
buffered_samples — NOT pressure thresholds. Use a local overridable constant with a
// TODO(contract-v1.1) comment, never invent a new BLE field.

## Style
- State management: provider package only — no Riverpod/Bloc.
- flutter_lints rules must pass.