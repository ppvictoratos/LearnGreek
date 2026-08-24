#import <XCTest/XCTest.h>
#import "LGDataStore.h"

/// The lean-app guarantees: a tiny binary and a tiny data set. These run in CI
/// (plain `xcodebuild test`), so a dependency or asset creeping in fails the build.
@interface LGPerformanceBudgetTests : XCTestCase
@end

@implementation LGPerformanceBudgetTests

// Debug builds are bigger than Release; the budget is set well above today's
// Debug size but far below what any framework dependency would add.
- (void)testExecutableStaysUnderBudget {
    NSBundle *appBundle = [NSBundle bundleForClass:[LGDataStore class]];
    NSString *path = appBundle.executablePath;
    NSDictionary *attributes =
        [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    unsigned long long size = [attributes fileSize];
    XCTAssertGreaterThan(size, 0ull);
    XCTAssertLessThan(size, 256ull * 1024, @"app binary grew past 256 KB (%llu bytes)", size);
}

- (void)testWordDataStaysUnderBudget {
    NSBundle *appBundle = [NSBundle bundleForClass:[LGDataStore class]];
    NSString *path = [appBundle pathForResource:@"words" ofType:@"json"];
    NSDictionary *attributes =
        [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    XCTAssertLessThan([attributes fileSize], 512ull * 1024,
                      @"words.json grew past 512 KB");
}

- (void)testDataStoreLoadIsFast {
    [self measureBlock:^{
        LGDataStore *store =
            [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                                   userDefaults:[[NSUserDefaults alloc]
                                                    initWithSuiteName:@"LGPerfTests"]];
        XCTAssertEqual(store.categories.count, 14u);
    }];
}

@end
