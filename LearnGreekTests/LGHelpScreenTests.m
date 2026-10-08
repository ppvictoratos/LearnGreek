#import <XCTest/XCTest.h>
#import "LGFunctionalHelpers.h"
#import "LGInfoViewController.h"
#import "LGThemeManager.h"

@interface LGHelpScreenTests : XCTestCase
@property (nonatomic, strong) LGInfoViewController *help;
@property (nonatomic, assign) BOOL savedTranslation;
@property (nonatomic, assign) BOOL savedPronunciation;
@end

@implementation LGHelpScreenTests

- (void)setUp {
    [super setUp];
    LGThemeManager *theme = LGThemeManager.sharedManager;
    self.savedTranslation = theme.showTranslation;
    self.savedPronunciation = theme.showPronunciation;
    self.help = [[LGInfoViewController alloc] init];
    self.help.view.frame = CGRectMake(0, 0, 375, 812);
    [self.help loadViewIfNeeded];
}

- (void)tearDown {
    LGThemeManager *theme = LGThemeManager.sharedManager;
    if (theme.showTranslation != self.savedTranslation) {
        [theme toggleTranslation];
    }
    if (theme.showPronunciation != self.savedPronunciation) {
        [theme togglePronunciation];
    }
    [super tearDown];
}

- (UISwitch *)switchNamed:(NSString *)key {
    return [self.help valueForKey:key];
}

- (void)testTranslationSwitchStartsMatchingThePreference {
    XCTAssertEqual([self switchNamed:@"translationToggle"].on, LGThemeManager.sharedManager.showTranslation);
}

- (void)testPronunciationSwitchStartsMatchingThePreference {
    XCTAssertEqual([self switchNamed:@"pronunciationToggle"].on, LGThemeManager.sharedManager.showPronunciation);
}

- (void)testSwitchesTintFollowTheTheme {
    NSArray<UISwitch *> *switches = @[[self switchNamed:@"pronunciationToggle"], [self switchNamed:@"translationToggle"]];
    NSArray<NSNumber *> *matches = [switches lg_map:^id(UISwitch *toggle) {
        return @([toggle.onTintColor isEqual:LGThemeManager.sharedManager.accentColor]);
    }];
    XCTAssertEqual([matches lg_filter:^BOOL(NSNumber *m) { return !m.boolValue; }].count, 0u);
}

- (void)testTogglingTranslationSwitchFlipsAndPersistsThePreference {
    BOOL before = LGThemeManager.sharedManager.showTranslation;
    UISwitch *toggle = [self switchNamed:@"translationToggle"];
    toggle.on = !before;
    [toggle sendActionsForControlEvents:UIControlEventValueChanged];
    XCTAssertEqual(LGThemeManager.sharedManager.showTranslation, !before);
}

- (void)testTogglingPronunciationSwitchFlipsThePreference {
    BOOL before = LGThemeManager.sharedManager.showPronunciation;
    UISwitch *toggle = [self switchNamed:@"pronunciationToggle"];
    toggle.on = !before;
    [toggle sendActionsForControlEvents:UIControlEventValueChanged];
    XCTAssertEqual(LGThemeManager.sharedManager.showPronunciation, !before);
}

- (void)testBlurbExplainsTheGreekArticles {
    UILabel *blurb = [self.help valueForKey:@"blurbLabel"];
    XCTAssertTrue([blurb.text containsString:@"masculine"]);
    XCTAssertTrue([blurb.text containsString:@"feminine"]);
}

@end
