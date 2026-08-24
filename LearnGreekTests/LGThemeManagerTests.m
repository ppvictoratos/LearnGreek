#import <XCTest/XCTest.h>
#import "LGThemeManager.h"

@interface LGThemeManagerTests : XCTestCase
@property (nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation LGThemeManagerTests

- (void)setUp {
    [super setUp];
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"LGThemeManagerTests"];
    [self.defaults removePersistentDomainForName:@"LGThemeManagerTests"];
}

- (void)tearDown {
    [self.defaults removePersistentDomainForName:@"LGThemeManagerTests"];
    [super tearDown];
}

- (void)testDefaultsToGreekTheme {
    LGThemeManager *manager = [[LGThemeManager alloc] initWithUserDefaults:self.defaults];
    XCTAssertEqual(manager.style, LGThemeStyleLight);
}

- (void)testToggleSwitchesAndPersists {
    LGThemeManager *manager = [[LGThemeManager alloc] initWithUserDefaults:self.defaults];
    [manager toggleTheme];
    XCTAssertEqual(manager.style, LGThemeStyleDark);

    LGThemeManager *reloaded = [[LGThemeManager alloc] initWithUserDefaults:self.defaults];
    XCTAssertEqual(reloaded.style, LGThemeStyleDark);

    [manager toggleTheme];
    XCTAssertEqual(manager.style, LGThemeStyleLight);
}

- (void)testTogglePostsNotification {
    LGThemeManager *manager = [[LGThemeManager alloc] initWithUserDefaults:self.defaults];
    [self expectationForNotification:LGThemeDidChangeNotification object:manager handler:nil];
    [manager toggleTheme];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testThemesHaveDistinctPalettes {
    LGThemeManager *manager = [[LGThemeManager alloc] initWithUserDefaults:self.defaults];
    UIColor *greekBackground = manager.backgroundColor;
    UIColor *greekAccent = manager.accentColor;
    [manager toggleTheme];
    XCTAssertNotEqualObjects(manager.backgroundColor, greekBackground);
    XCTAssertNotEqualObjects(manager.accentColor, greekAccent);
}

@end
