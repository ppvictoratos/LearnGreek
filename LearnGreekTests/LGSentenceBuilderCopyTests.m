#import <XCTest/XCTest.h>
#import "LGLanguageManager.h"
#import "LGSentenceBuilderViewController.h"

@interface LGSentenceBuilderViewController (LGTesting)
+ (NSString *)string:(NSString *)key;
@end

@interface LGSentenceBuilderCopyTests : XCTestCase
@property (nonatomic, copy) NSString *savedLanguage;
@end

@implementation LGSentenceBuilderCopyTests

- (void)setUp {
    [super setUp];
    self.savedLanguage = LGLanguageManager.sharedManager.languageCode;
    [LGLanguageManager.sharedManager setLanguageCode:@"en"];
}

- (void)tearDown {
    [LGLanguageManager.sharedManager setLanguageCode:self.savedLanguage];
    [super tearDown];
}

- (void)testEmptyStateIsShortEnoughToFitOnAnIPhoneMini {
    NSString *copy = [LGSentenceBuilderViewController string:@"noFavorites"];
    XCTAssertLessThanOrEqual(copy.length, 32u);
    XCTAssertTrue([copy containsString:@"Star"]);
}

@end
