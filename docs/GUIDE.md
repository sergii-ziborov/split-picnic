# Split Picnic guide

Split Picnic is an offline iPhone and iPad puzzle: make two picnic guests happy by dividing a pizza or berry pie with a single freehand swipe. No account or network connection is required.

## How to play

1. On first launch, watch two short animated lessons: a curved finger cut and the slices going to their guests. If you leave before finishing, the tutorial appears again on the next launch. You can replay it later from **Settings → How to Play**.
2. Read the guest cards above the dish. Ingredient icons show what each guest wants. `×2` or `×3` shows a quantity; the order text clarifies whether it is an exact count or a minimum. A crossed-out icon means that ingredient is forbidden.
3. Start near one edge of the dish, move your finger across it in a straight or curved path, and lift near the opposite edge. There is no ruler: the cut follows your gesture and separates the food immediately. Short taps and swipes that miss the dish are ignored.
4. The piece whose center lies further left goes to the left guest; the other piece goes to the right guest. Satisfy both orders to clear the level. If a cut fails, the result screen helps show which request was missed.

Later levels add two more challenges. **Fair portions** require the pieces to be close in area. A **clean cut** must avoid toppings; the live swipe trail turns red when it touches one. Exact counts and forbidden ingredients are shown in the guest orders.

### Hints and tutorials

Tap the lightbulb on a level to see a glowing, animated solution path for that specific dish. Tap it again to replay the same hint without spending another one. **Watch demo** opens both animated lessons and returns you to the same puzzle when you close them. Using a hint can lower your star rating.

With **Settings → Reduce Motion** (or the system Reduce Motion setting), tutorial scenes show their final frames instead of looping continuously.

### Progress

There are four picnics with 12 levels each. Their maps evolve as you play, while guests, tablecloths, and dishes change. A daily puzzle is available separately. Stars unlock collection items. Progress and settings stay on your device.

## Build on a Mac

You need macOS, Xcode with an iOS 18 or newer SDK, and an installed iPhone or iPad simulator. The Xcode project is checked in; there are no external package dependencies.

```bash
git clone https://github.com/sergii-ziborov/split-picnic.git
cd split-picnic
open SplitPicnic.xcodeproj
```

In Xcode, select the **SplitPicnic** scheme and a simulator, then choose Run. To build from Terminal:

```bash
xcodebuild -project SplitPicnic.xcodeproj -scheme SplitPicnic \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

For tests, find an installed simulator ID and use it in the destination:

```bash
xcrun simctl list devices available
export SIMULATOR_ID="YOUR_SIMULATOR_ID"
xcodebuild -project SplitPicnic.xcodeproj -scheme SplitPicnic \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test
```

If you change `project.yml`, install [XcodeGen](https://github.com/yonaskolb/XcodeGen) and run `./scripts/generate-project.sh`. Normal builds do not need project regeneration.

### Install on your own iPhone

Connect and unlock the phone, trust the Mac, and enable Developer Mode. You need your own Apple Developer team for signing. Find the device ID, then supply it and your Team ID:

```bash
xcrun devicectl list devices
export DEVICE_ID="YOUR_IPHONE_DEVICE_ID"
export DEVELOPMENT_TEAM="YOUR_APPLE_TEAM_ID"
./scripts/install-device.sh "$DEVICE_ID"
```

If the device is `unavailable`, check the cable or pairing, unlock the phone, confirm trust, and verify Developer Mode. The script contains no personal device or team identifiers and does not publish the app to the App Store.

## Project layout

- `SplitPicnic/Game/Engine` — freehand cut geometry, orders, level catalog, and evaluation.
- `SplitPicnic/Game/Food` and `Game/Guests` — dishes, toppings, guests, and effects.
- `SplitPicnic/Features` — game screens and tutorials.
- `SplitPicnic/Audio` — synthesized game sounds.
- `SplitPicnicTests` and `SplitPicnicUITests` — logic and interface tests.
- `docs/screenshots` — optimized JPGs for README; UI tests generate raw PNGs locally, but they are not committed.

The code is available for viewing and personal evaluation under the [Split Picnic Source License](../LICENSE). A public repository does **not** grant permission for commercial use, redistribution, or publishing your own version of the app.
