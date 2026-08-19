# ScribeSense — Ethics & Data Privacy Notes

## The core rule
All raw session data (individual sensor samples, IMU traces, raw pressure
readings) stays on-device by default. Nothing leaves the phone without an
explicit reason tied to a feature the user asked for.

The only data ever sent to a cloud API (Gemini, Groq) is the aggregated
statistics defined in Software S5.2's input contract — never raw per-sample
traces, and never a child's name or other identifying detail.

## Why this matters specifically for the free-tier LLM calls
Google's Gemini free tier allows prompts and outputs to be used to improve
Google's models (confirmed on Google's own pricing page). Because this
product handles children's handwriting-practice data, raw session data or
anything child-identifying must never be sent to a free-tier cloud API.
Aggregated-only, always.

## Output framing
AI-generated output (exercise_plan, parent_note, therapist_note) must always
read as an educational suggestion, never a diagnosis or medical claim.
Enforced in the S5.2 prompt design and checked in S4.2's camera-assessment
disclaimer.

## Data deletion
A parent can delete all locally stored data at any time from Settings
(S1.1 scaffold task).
