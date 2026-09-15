# Home Screen Sentences Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move sentences from the saved list view to home screen tiles, solving the cramped UI problem and creating a new place to manage sentence-specific settings.

**Architecture:** Sentences exist in one of two states: in the saved sentences list, or on the home screen. Add a `sentencesOnHomeScreen` NSMutableSet tracking which sentence IDs live on the home screen. When a user swipes-right on a saved sentence, a green "+" button moves it to home screen, removing it from the saved list. Home screen display shows these sentences as tiles that play audio on tap. Editing (icons, text) is deferred to Phase 3.

**Tech Stack:** Objective-C, UIKit, NSUserDefaults, NSMutableSet

**Spec:** Design approved in chat; sentences move from list to home screen via swipe-right + button tap.

---

## Global Constraints

- Objective-C only, no Swift
- No external dependencies (UIKit only)
- Sentences moved to home screen are removed from saved list (no duplication)
- Persistence: save/load sentencesOnHomeScreen from NSUserDefaults like savedSentencesWithIcons
- Deferred to Phase 3: editing icon, editing text, delete from home screen tiles

---

### Task 1: Add sentencesOnHomeScreen data model to LGDataStore

**Files:**
- Modify: `LGDataStore.h:34-39` (add public property and methods)
- Modify: `LGDataStore.m:12-18` (add private mutable property)
- Modify: `LGDataStore.m:35-53` (init: load sentencesOnHomeScreen from defaults)
- Create: persistence methods in `LGDataStore.m`

**Interfaces:**
- Consumes: NSUserDefaults (already available)
- Produces: 
  - `@property (nonatomic, copy, readonly) NSSet<NSString *> *sentencesOnHomeScreen;` (returns sentence IDs)
  - `- (void)addSentenceToHomeScreen:(LGSentence *)sentence;` (moves sentence from saved to home screen)
  - `- (void)removeSentenceFromHomeScreen:(NSString *)sentenceID;` (moves sentence from home screen to saved)

- [ ] **Step 1: Add public property and methods to LGDataStore.h**

After line 38 (`- (void)deleteSentenceWithID:(LGSentence *)sentence;`), add:

```objc
/// Sentences pinned to home screen, by ID
@property (nonatomic, copy, readonly) NSSet<NSString *> *sentencesOnHomeScreen;

/// Move sentence from saved list to home screen
- (void)addSentenceToHomeScreen:(LGSentence *)sentence;

/// Move sentence from home screen back to saved list (Phase 3)
- (void)removeSentenceFromHomeScreen:(NSString *)sentenceID;
```

- [ ] **Step 2: Add private mutable property to LGDataStore.m**

After line 16 (`@property (nonatomic, strong) NSMutableArray<LGSentence *> *savedSentencesWithIconsMutable;`), add:

```objc
@property (nonatomic, strong) NSMutableSet<NSString *> *sentencesOnHomeScreenMutable;
```

- [ ] **Step 3: Add constants for persistence key in LGDataStore.m**

After line 10 (`static NSString *const LGSentencesDefaultsKey = @"LGSavedSentences";`), add:

```objc
static NSString *const LGHomeScreenSentencesDefaultsKey = @"LGHomeScreenSentences";
```

- [ ] **Step 4: Load sentencesOnHomeScreen in init**

In the `initWithBundle:userDefaults:` method, after line 49 (`[self loadSavedSentencesWithIcons];`), add:

```objc
NSLog(@"[LGDataStore] Loading home screen sentences...");
[self loadHomeScreenSentences];
NSLog(@"[LGDataStore] Loaded %lu home screen sentences", (unsigned long)_sentencesOnHomeScreenMutable.count);
```

- [ ] **Step 5: Implement loadHomeScreenSentences method**

Add this new method in the `#pragma mark - Saved sentences with icons` section, after `persistSentencesWithIcons`:

```objc
- (void)loadHomeScreenSentences {
    NSLog(@"[LGDataStore] loadHomeScreenSentences called");
    _sentencesOnHomeScreenMutable = [NSMutableSet set];
    NSArray *saved = [self.defaults arrayForKey:LGHomeScreenSentencesDefaultsKey];
    if (saved) {
        _sentencesOnHomeScreenMutable = [NSMutableSet setWithArray:saved];
        NSLog(@"[LGDataStore] Loaded %lu home screen sentence IDs", (unsigned long)_sentencesOnHomeScreenMutable.count);
    }
}
```

- [ ] **Step 6: Implement sentencesOnHomeScreen getter**

Add this method after `loadHomeScreenSentences`:

```objc
- (NSSet<NSString *> *)sentencesOnHomeScreen {
    if (!self.sentencesOnHomeScreenMutable) {
        _sentencesOnHomeScreenMutable = [NSMutableSet set];
    }
    return [self.sentencesOnHomeScreenMutable copy];
}
```

- [ ] **Step 7: Implement persistHomeScreenSentences helper**

Add this method after the getter:

```objc
- (void)persistHomeScreenSentences {
    NSLog(@"[LGDataStore] persistHomeScreenSentences called, count: %lu", (unsigned long)self.sentencesOnHomeScreenMutable.count);
    [self.defaults setObject:self.sentencesOnHomeScreenMutable.allObjects forKey:LGHomeScreenSentencesDefaultsKey];
    [self.defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:LGSentencesDidChangeNotification object:self];
}
```

- [ ] **Step 8: Implement addSentenceToHomeScreen**

Add this method after `persistHomeScreenSentences`:

```objc
- (void)addSentenceToHomeScreen:(LGSentence *)sentence {
    NSLog(@"[LGDataStore] addSentenceToHomeScreen: %@", sentence.sentenceID);
    
    // Add to home screen set
    [self.sentencesOnHomeScreenMutable addObject:sentence.sentenceID];
    
    // Remove from saved sentences
    [self deleteSentenceWithID:sentence];
    
    // Persist
    [self persistHomeScreenSentences];
    NSLog(@"[LGDataStore] Moved sentence to home screen");
}
```

- [ ] **Step 9: Implement removeSentenceFromHomeScreen**

Add this method after `addSentenceToHomeScreen`:

```objc
- (void)removeSentenceFromHomeScreen:(NSString *)sentenceID {
    NSLog(@"[LGDataStore] removeSentenceFromHomeScreen: %@", sentenceID);
    [self.sentencesOnHomeScreenMutable removeObject:sentenceID];
    [self persistHomeScreenSentences];
}
```

- [ ] **Step 10: Commit data model changes**

```bash
git add LGDataStore.h LGDataStore.m
git commit -m "feat: add sentencesOnHomeScreen data model with persistence"
```

---

### Task 2: Add leading swipe-right action to LGSentenceBuilderViewController

**Files:**
- Modify: `LGSentenceBuilderViewController.m` (add leading swipe action)

**Interfaces:**
- Consumes: `LGDataStore.addSentenceToHomeScreen:`
- Produces: UITableView leading swipe action with green "+" button

- [ ] **Step 1: Add leading swipe action to table view**

Open `LGSentenceBuilderViewController.m`. In the `UITableViewDelegate` section where `trailingSwipeActionsConfigurationForRowAtIndexPath:` is implemented, add this method before or after it:

```objc
- (UISwipeActionsConfiguration *)leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Only add swipe for saved sentences section
    if (indexPath.section != LGSectionSaved) {
        return nil;
    }
    
    UIContextualAction *addAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                             title:@"+" handler:^(UIContextualAction * _Nonnull action,
                                                                                                   UIView * _Nonnull sourceView,
                                                                                                   void (^ _Nonnull completionHandler)(BOOL)) {
        LGSentence *sentence = self.savedSentences[indexPath.row];
        NSLog(@"[LGSentenceBuilder] Adding sentence to home screen: %@", sentence.text);
        [[LGDataStore sharedStore] addSentenceToHomeScreen:sentence];
        completionHandler(YES);
    }];
    
    addAction.backgroundColor = [UIColor systemGreenColor];
    addAction.image = [UIImage systemImageNamed:@"plus"];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[addAction]];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}
```

- [ ] **Step 2: Verify the section constant exists**

Check that `LGSectionSaved` is defined. Open the file and search for the enum/constants defining sections. If you see:

```objc
typedef NS_ENUM(NSInteger, LGSentenceSection) {
    LGSectionSaved = 0,
    // ...
};
```

Then you're good. If not, add it.

- [ ] **Step 3: Run and test the swipe action**

Build and run the app:

```bash
xcodebuild -scheme LearnGreek -configuration Debug | xcpretty
```

Expected: App builds without errors.

- [ ] **Step 4: Commit swipe action**

```bash
git add LGSentenceBuilderViewController.m
git commit -m "feat: add leading swipe-right (green +) to move sentences to home screen"
```

---

### Task 3: Update LGHomeViewController to display home screen sentences

**Files:**
- Modify: `LGHomeViewController.m` (add display logic for home screen sentences)

**Interfaces:**
- Consumes: `LGDataStore.sentencesOnHomeScreen`, `LGDataStore.savedSentencesWithIcons`
- Produces: UIView displaying home screen sentences as tiles

- [ ] **Step 1: Check current LGHomeViewController structure**

Read the implementation to see how the grid is structured:

```bash
head -50 LGHomeViewController.m
```

Expected output will show the view controller's current layout. Look for a UICollectionView or UIStackView structure.

- [ ] **Step 2: Add home screen sentences container**

In `LGHomeViewController.m`, find the `viewDidLoad` method. After the grid setup, add a new container for home screen sentences:

```objc
// Create container for home screen sentences
UIView *homeScreenContainer = [[UIView alloc] init];
homeScreenContainer.translatesAutoresizingMaskIntoConstraints = NO;
homeScreenContainer.backgroundColor = [UIColor clearColor];
[self.view addSubview:homeScreenContainer];

// Position below the main grid
[NSLayoutConstraint activateConstraints:@[
    [homeScreenContainer.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:400], // Adjust Y as needed
    [homeScreenContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [homeScreenContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    [homeScreenContainer.heightAnchor constraintEqualToConstant:150]
]];

// Call method to populate home screen sentences
[self populateHomeScreenSentences:homeScreenContainer];
```

- [ ] **Step 3: Implement populateHomeScreenSentences helper**

Add this method to the implementation:

```objc
- (void)populateHomeScreenSentences:(UIView *)container {
    NSLog(@"[LGHomeViewController] populateHomeScreenSentences called");
    
    // Clear any existing subviews
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    LGDataStore *store = [LGDataStore sharedStore];
    NSSet<NSString *> *homeScreenIDs = store.sentencesOnHomeScreen;
    
    NSLog(@"[LGHomeViewController] Home screen sentence count: %lu", (unsigned long)homeScreenIDs.count);
    
    if (homeScreenIDs.count == 0) {
        NSLog(@"[LGHomeViewController] No home screen sentences to display");
        return;
    }
    
    // Create horizontal scroll view for tiles
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [container addSubview:scrollView];
    
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:container.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:container.bottomAnchor]
    ]];
    
    // Create stack view for horizontal layout
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 12;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.layoutMargins = UIEdgeInsetsMake(8, 16, 8, 16);
    stackView.isLayoutMarginsRelativeArrangement = YES;
    [scrollView addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:scrollView.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:scrollView.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor],
        [stackView.heightAnchor constraintEqualToAnchor:scrollView.heightAnchor]
    ]];
    
    // Build buttons for each home screen sentence
    NSArray<LGSentence *> *allSentences = store.savedSentencesWithIcons;
    for (LGSentence *sentence in allSentences) {
        if ([homeScreenIDs containsObject:sentence.sentenceID]) {
            [self createTileButton:sentence inStackView:stackView];
        }
    }
}

- (void)createTileButton:(LGSentence *)sentence inStackView:(UIStackView *)stackView {
    NSLog(@"[LGHomeViewController] Creating tile for sentence: %@", sentence.text);
    
    UIButton *tileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    tileButton.translatesAutoresizingMaskIntoConstraints = NO;
    [tileButton setTitle:sentence.text forState:UIControlStateNormal];
    tileButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    tileButton.backgroundColor = [UIColor systemBlueColor];
    tileButton.tintColor = [UIColor whiteColor];
    tileButton.layer.cornerRadius = 8;
    tileButton.clipsToBounds = YES;
    
    // Add SF Symbol image if available
    if (sentence.iconSymbolName && sentence.iconSymbolName.length > 0) {
        UIImage *icon = [UIImage systemImageNamed:sentence.iconSymbolName];
        if (icon) {
            [tileButton setImage:icon forState:UIControlStateNormal];
            tileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4);
        }
    }
    
    // Handle tap to play audio
    [tileButton addTarget:self action:@selector(tileButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    tileButton.tag = [sentence.sentenceID hash]; // Store reference (Phase 3: replace with proper ID storage)
    
    // Store sentence data for later access
    objc_setAssociatedObject(tileButton, "sentence", sentence, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [stackView addArrangedSubview:tileButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [tileButton.widthAnchor constraintEqualToConstant:120],
        [tileButton.heightAnchor constraintEqualToConstant:100]
    ]];
}

- (void)tileButtonTapped:(UIButton *)button {
    LGSentence *sentence = objc_getAssociatedObject(button, "sentence");
    if (sentence) {
        NSLog(@"[LGHomeViewController] Playing audio for: %@", sentence.text);
        // Play audio using existing speech service
        [[LGSpeechService sharedService] speakText:sentence.text];
    }
}
```

- [ ] **Step 4: Add observer for sentence changes**

In `viewDidLoad`, after setting up the home screen container, add:

```objc
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(sentencesDidChange:)
                                             name:LGSentencesDidChangeNotification
                                           object:nil];
```

- [ ] **Step 5: Implement sentencesDidChange notification handler**

Add this method:

```objc
- (void)sentencesDidChange:(NSNotification *)notification {
    NSLog(@"[LGHomeViewController] Sentences changed, refreshing display");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view setNeedsLayout];
        // Re-populate home screen container
        for (UIView *subview in self.view.subviews) {
            if ([subview.class isEqual:NSClassFromString(@"UIView")] && subview.tag == 999) { // Mark container with tag
                [self populateHomeScreenSentences:subview];
                break;
            }
        }
    });
}
```

- [ ] **Step 6: Build and verify**

```bash
xcodebuild -scheme LearnGreek -configuration Debug | xcpretty
```

Expected: Builds without errors.

- [ ] **Step 7: Commit home screen display**

```bash
git add LGHomeViewController.m
git commit -m "feat: display home screen sentences as tiles with audio playback"
```

---

### Task 4: End-to-end testing

**Files:**
- Test: Manual testing on device

- [ ] **Step 1: Clean build and install**

```bash
cd ~/Desktop/tech/kodikas/LearnGreek
xcodebuild clean
xcodebuild -scheme LearnGreek -configuration Debug build
```

Expected: Clean build succeeds.

- [ ] **Step 2: Deploy to device**

```bash
ios-deploy --bundle ./build/LearnGreek.app --id YOUR_DEVICE_ID
```

Or use Xcode directly: Product → Run.

- [ ] **Step 3: Test the flow**

1. Create a sentence by chaining favorite words
2. Save the sentence (should appear in saved list)
3. Swipe RIGHT on the sentence
4. Tap the green "+" button
5. Verify:
   - Sentence disappears from saved list
   - Sentence appears on home screen as a tile
   - Tap the tile to play audio
6. Close and reopen the app
7. Verify: Home screen sentence is still there (persistence works)

- [ ] **Step 4: Test edge cases**

- Create multiple sentences and move 3+ to home screen
- Verify all appear on home screen
- Restart app and verify all persist
- Create sentence → add to home screen → restart → verify tile still playable

- [ ] **Step 5: Document any issues**

If something doesn't work:
- Check console logs (Xcode Window → Devices & Simulators → Console)
- Look for `[LGHomeViewController]` and `[LGDataStore]` logs
- Take screenshots

---

### Task 5: Final commit and push

- [ ] **Step 1: Review changes**

```bash
git status
git log --oneline -5
```

Expected output:
```
On branch main
Your branch is ahead of 'origin/main' by 3 commits.

c55b92b feat: display home screen sentences as tiles
113437f feat: add leading swipe-right (green +) to move sentences to home screen
5ff58b8 feat: add sentencesOnHomeScreen data model with persistence
```

- [ ] **Step 2: Push to GitHub**

```bash
git push origin main
```

Expected: All 3 commits push successfully.

- [ ] **Step 3: Verify on GitHub**

Open https://github.com/YOUR_USERNAME/LearnGreek and verify the commits appear.

---

## Summary

**What's Complete:**
- ✅ Sentences move from saved list to home screen via swipe-right + green button
- ✅ Home screen shows sentences as tiles
- ✅ Tapping tiles plays audio
- ✅ Persistence: home screen sentences survive app restart
- ✅ No more cramped saved list view

**What's Deferred to Phase 3:**
- ❌ Editing sentence text from home screen tiles
- ❌ Editing icon from home screen tiles
- ❌ Delete from home screen (long-press or swipe-left)
- ❌ "Remove from home screen" to move back to saved list
