# LearnGreek

A no-ads, no-cost, no-fluff Greek vocabulary app. Open it, hear some Greek, close
it, lock the phone. Written in Objective-C + programmatic UIKit — no storyboards,
no dependencies, no network. Target device: iPhone 12 mini.

## What it does

- **2×8 home grid, 16 tiles**: Favorites, a light/dark mode toggle, and 14 word
  categories (Greetings, Conversation, Mythology, Astrology, Transportation,
  Sports, Food, Numbers, Colors, Days & Time, Family, Nature, Animals,
  Emergency). Tiles use SF Symbols.
- **Base languages** — English, Español, Italiano, Français, auto-detected from
  the device and switchable via the globe button. Cantonese (廣東話) is fully
  translated in the data set but held behind a feature flag
  (`LGFeatureCantonese` bool in NSUserDefaults) until it ships.
- **Tap a word to hear it** pronounced via the system `el-GR` voice
  (`AVSpeechSynthesizer`) — works offline, zero audio assets.
- **Star words to favorite them**; favorites persist in `NSUserDefaults`.
- **Light mode** — Aegean blue (`#0D5EAF`) on white. **Dark mode** — neon green
  (`#00FF41` / `#00CC33`) on deep green (`#04150C`), monospaced type.

## Layout

- `LearnGreek/` — app sources (`LG` prefix). `Resources/words.json` holds all
  148 words (`el` / `translit` + `en`/`es`/`it`/`fr`/`yue` per word). Add words
  there; no code changes needed. A unit test fails if any translation is missing.
- `LearnGreekTests/` — unit tests: data store, favorites persistence, theme and
  language managers, feature flags, and the **performance budgets** (binary
  ≤ 1.5 MB, data ≤ 512 KB, data-store load time).
- `LearnGreekUITests/` — XCUITest e2e: grid layout, category browsing, favorite
  round trip, language switch, theme toggle, and **cold-launch time** measured
  with `XCTApplicationLaunchMetric` over 5 launches. The app resets state when
  launched with `--uitest-reset`.

## Building (no Xcode GUI needed)

Project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```
xcodegen generate
xcodebuild -project LearnGreek.xcodeproj -scheme LearnGreek \
  -destination 'platform=iOS Simulator,name=iPhone 12 mini' test
```
