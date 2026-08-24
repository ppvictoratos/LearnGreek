#import <XCTest/XCTest.h>
#import "LGLanguageManager.h"

@interface LGLanguageManagerTests : XCTestCase
@property (nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation LGLanguageManagerTests

- (void)setUp {
    [super setUp];
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"LGLanguageManagerTests"];
    [self.defaults removePersistentDomainForName:@"LGLanguageManagerTests"];
}

- (void)tearDown {
    [self.defaults removePersistentDomainForName:@"LGLanguageManagerTests"];
    [super tearDown];
}

- (void)testDefaultLanguageIsSupported {
    LGLanguageManager *manager = [[LGLanguageManager alloc] initWithUserDefaults:self.defaults];
    XCTAssertTrue([LGLanguageManager.supportedLanguageCodes containsObject:manager.languageCode]);
}

- (void)testSetLanguagePersists {
    LGLanguageManager *manager = [[LGLanguageManager alloc] initWithUserDefaults:self.defaults];
    [manager setLanguageCode:@"fr"];
    XCTAssertEqualObjects(manager.languageCode, @"fr");

    LGLanguageManager *reloaded = [[LGLanguageManager alloc] initWithUserDefaults:self.defaults];
    XCTAssertEqualObjects(reloaded.languageCode, @"fr");
}

- (void)testCantoneseIsBehindAFeatureFlag {
    NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
    [standard removeObjectForKey:LGFeatureCantoneseKey];
    XCTAssertFalse([LGLanguageManager.supportedLanguageCodes containsObject:@"yue"]);
    XCTAssertTrue([LGLanguageManager.allLanguageCodes containsObject:@"yue"]);

    [standard setBool:YES forKey:LGFeatureCantoneseKey];
    XCTAssertTrue([LGLanguageManager.supportedLanguageCodes containsObject:@"yue"]);
    [standard removeObjectForKey:LGFeatureCantoneseKey];
}

- (void)testSetLanguagePostsNotification {
    LGLanguageManager *manager = [[LGLanguageManager alloc] initWithUserDefaults:self.defaults];
    NSString *target = [manager.languageCode isEqualToString:@"es"] ? @"fr" : @"es";
    [self expectationForNotification:LGLanguageDidChangeNotification object:manager handler:nil];
    [manager setLanguageCode:target];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSettingSameLanguageDoesNotNotify {
    LGLanguageManager *manager = [[LGLanguageManager alloc] initWithUserDefaults:self.defaults];
    __block BOOL notified = NO;
    id observer = [[NSNotificationCenter defaultCenter]
        addObserverForName:LGLanguageDidChangeNotification
                    object:manager
                     queue:nil
                usingBlock:^(NSNotification *note) { notified = YES; }];
    [manager setLanguageCode:manager.languageCode];
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
    XCTAssertFalse(notified);
}

- (void)testEverySupportedLanguageHasADisplayName {
    for (NSString *code in LGLanguageManager.allLanguageCodes) {
        XCTAssertTrue([LGLanguageManager displayNameForLanguageCode:code].length > 0);
    }
}

@end
