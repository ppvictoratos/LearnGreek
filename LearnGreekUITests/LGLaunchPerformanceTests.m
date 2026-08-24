#import <XCTest/XCTest.h>

/// Cold-launch time, measured with Apple's launch metric across 5 launches.
/// The number lands in the xcresult bundle and the CI log.
@interface LGLaunchPerformanceTests : XCTestCase
@end

@implementation LGLaunchPerformanceTests

- (void)testColdLaunchPerformance {
    XCTMeasureOptions *options = [[XCTMeasureOptions alloc] init];
    options.iterationCount = 5;
    [self measureWithMetrics:@[ [[XCTApplicationLaunchMetric alloc] init] ]
                     options:options
                       block:^{
        XCUIApplication *app = [[XCUIApplication alloc] init];
        [app launch];
        [app terminate];
    }];
}

@end
