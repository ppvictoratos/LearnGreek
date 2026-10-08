#import <XCTest/XCTest.h>
#import "LGFunctionalHelpers.h"
#import "LGWordCell.h"

@interface LGWordCell (LGTesting)
+ (NSString *)detailTextForTransliteration:(NSString *)transliteration
                                translation:(NSString *)translation
                          showPronunciation:(BOOL)showPronunciation
                            showTranslation:(BOOL)showTranslation;
@end

@interface LGWordCellTests : XCTestCase
@end

@implementation LGWordCellTests

- (void)testDetailTextFollowsBothToggles {
    NSArray<NSNumber *> *flags = @[@YES, @NO];
    NSArray<NSArray<NSNumber *> *> *combinations = [flags lg_flatMap:^NSArray *(NSNumber *pronunciation) {
        return [flags lg_map:^id(NSNumber *translation) { return @[pronunciation, translation]; }];
    }];
    NSArray<NSString *> *actual = [combinations lg_map:^id(NSArray<NSNumber *> *pair) {
        return [LGWordCell detailTextForTransliteration:@"se"
                                            translation:@"in/at"
                                      showPronunciation:pair[0].boolValue
                                        showTranslation:pair[1].boolValue];
    }];
    NSArray<NSString *> *expected = @[@"se · in/at", @"se", @"in/at", @""];
    XCTAssertEqualObjects(actual, expected);
}

- (void)testDetailTextSkipsMissingPieces {
    NSString *text = [LGWordCell detailTextForTransliteration:@""
                                                  translation:@"hello"
                                            showPronunciation:YES
                                              showTranslation:YES];
    XCTAssertEqualObjects(text, @"hello");
}

@end
