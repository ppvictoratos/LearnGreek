#import <XCTest/XCTest.h>
#import "LGCategory.h"
#import "LGDataStore.h"
#import "LGFunctionalHelpers.h"
#import "LGWord.h"

@interface LGCategoryDataTests : XCTestCase
@property (nonatomic, copy) NSArray<LGCategory *> *categories;
@end

@implementation LGCategoryDataTests

- (void)setUp {
    [super setUp];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"LGCategoryDataTests"];
    LGDataStore *store = [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                                                userDefaults:defaults];
    self.categories = store.categories;
}

- (NSArray<NSString *> *)categoryIDs {
    return [self.categories lg_map:^id(LGCategory *category) { return category.categoryID; }];
}

- (NSArray<NSString *> *)greekWordsIn:(LGCategory *)category {
    return [category.words lg_map:^id(LGWord *word) { return word.greek; }];
}

- (LGCategory *)categoryWithID:(NSString *)identifier {
    return [[self.categories lg_filter:^BOOL(LGCategory *category) {
        return [category.categoryID isEqualToString:identifier];
    }] firstObject];
}

- (void)testVerbsSitRightBeforeEmergency {
    NSArray<NSString *> *ids = [self categoryIDs];
    NSUInteger verbs = [ids indexOfObject:@"verbs"];
    XCTAssertEqualObjects(ids[verbs + 1], @"emergency");
}

- (void)testVerbsUsePlayIcon {
    XCTAssertEqualObjects([self categoryWithID:@"verbs"].symbolName, @"play.fill");
}

- (void)testPrepositionsAndAdverbsAreSeparateCategories {
    XCTAssertNil([self categoryWithID:@"prepositions_adverbs"]);
    XCTAssertNotNil([self categoryWithID:@"prepositions"]);
    XCTAssertNotNil([self categoryWithID:@"adverbs_connectors"]);
}

- (void)testPrepositionsHoldTheSpatialWords {
    NSArray<NSString *> *words = [self greekWordsIn:[self categoryWithID:@"prepositions"]];
    NSArray<NSString *> *expected = @[@"κάτω", @"πάνω", @"μέσα", @"έξω"];
    NSArray<NSNumber *> *present = [expected lg_map:^id(NSString *word) { return @([words containsObject:word]); }];
    XCTAssertEqual([present lg_filter:^BOOL(NSNumber *p) { return !p.boolValue; }].count, 0u);
}

- (void)testOnlyTheKnownSharedPhraseAppearsInTwoCategories {
    NSArray<NSString *> *allGreek = [self.categories lg_flatMap:^NSArray *(LGCategory *category) {
        return [self greekWordsIn:category];
    }];
    NSArray<NSString *> *repeated = [[NSSet setWithArray:allGreek].allObjects lg_filter:^BOOL(NSString *greek) {
        return [allGreek filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", greek]].count > 1;
    }];
    XCTAssertEqualObjects(repeated, @[@"Είμαι καλά"]);
}

- (void)testEveryCategoryHasAnEnglishNameAndIcon {
    NSArray<LGCategory *> *incomplete = [self.categories lg_filter:^BOOL(LGCategory *category) {
        return category.symbolName.length == 0 || [category nameForLanguage:@"en"].length == 0;
    }];
    XCTAssertEqual(incomplete.count, 0u);
}

@end
