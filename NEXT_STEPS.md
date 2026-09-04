# Next Steps

## Family Voices (the dream feature)
Replace the robotic `el-GR` system voice with real human pronunciations
recorded by family members.

- Give each family member a list of the 148 words (`Resources/words.json`).
- Record each as a short `.wav` (one word per file, consistent naming —
  e.g. word key from `words.json` as the filename).
- Bundle the `.wav` files as app resources.
- On tap, play the matching `.wav` if present; fall back to
  `AVSpeechSynthesizer` (`el-GR`) if a recording is missing.
- Stretch: let the user pick *whose* voice they hear (a family member
  toggle/setting).

This is a big lift (recording + bundling + fallback logic) — biggest next
milestone after the current app is stable.

## Also planned (from README)
- Rule-based grammar engine for the Sentence builder (article field already
  encodes noun gender for this).
