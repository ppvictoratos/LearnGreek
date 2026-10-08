#import <XCTest/XCTest.h>
#import "LGFunctionalHelpers.h"
#import "LGLanguageManager.h"
#import "LGPhrasesViewController.h"

@interface LGPhrasesViewController (LGTesting)
+ (NSString *)localizedTitle;
@end

@interface LGPhraseBankTests : XCTestCase
@property (nonatomic, copy) NSString *savedLanguage;
@end

@implementation LGPhraseBankTests

- (void)setUp {
    [super setUp];
    self.savedLanguage = LGLanguageManager.sharedManager.languageCode;
}

- (void)tearDown {
    [LGLanguageManager.sharedManager setLanguageCode:self.savedLanguage];
    [super tearDown];
}

- (void)testTitleReadsLearnGreekPhraseBankInEveryBaseLanguage {
    NSArray<NSString *> *codes = @[@"en", @"es", @"it", @"fr"];
    NSArray<NSString *> *titles = [codes lg_map:^id(NSString *code) {
        [LGLanguageManager.sharedManager setLanguageCode:code];
        return [LGPhrasesViewController localizedTitle];
    }];
    NSArray<NSString *> *withBrand = [titles lg_filter:^BOOL(NSString *title) {
        return [title containsString:@"LearnGreek"];
    }];
    XCTAssertEqual(withBrand.count, codes.count);
    XCTAssertEqual([NSSet setWithArray:titles].count, codes.count, @"each language should get its own title");
}

- (void)testEnglishTitleIsTheDefaultNameOfTheSection {
    [LGLanguageManager.sharedManager setLanguageCode:@"en"];
    XCTAssertEqualObjects([LGPhrasesViewController localizedTitle], @"LearnGreek Phrase Bank");
}

@end
