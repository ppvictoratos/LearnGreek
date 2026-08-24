#import <XCTest/XCTest.h>
#import "LGCategory.h"
#import "LGDataStore.h"
#import "LGLanguageManager.h"
#import "LGWord.h"

@interface LGDataStoreTests : XCTestCase
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) LGDataStore *store;
@end

@implementation LGDataStoreTests

- (void)setUp {
    [super setUp];
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"LGDataStoreTests"];
    [self.defaults removePersistentDomainForName:@"LGDataStoreTests"];
    self.store = [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                                        userDefaults:self.defaults];
}

- (void)tearDown {
    [self.defaults removePersistentDomainForName:@"LGDataStoreTests"];
    [super tearDown];
}

- (void)testLoadsFourteenCategories {
    XCTAssertEqual(self.store.categories.count, 14u);
}

- (void)testEveryCategoryIsFullyPopulated {
    for (LGCategory *category in self.store.categories) {
        XCTAssertTrue(category.categoryID.length > 0);
        XCTAssertTrue(category.nameGreek.length > 0);
        XCTAssertTrue(category.symbolName.length > 0);
        XCTAssertGreaterThanOrEqual(category.words.count, 8u,
                                    @"category %@ is too thin", category.categoryID);
        for (LGWord *word in category.words) {
            XCTAssertTrue(word.greek.length > 0);
            XCTAssertTrue(word.transliteration.length > 0);
        }
    }
}

// Reads the raw JSON so the English fallback in LGWord can't mask a missing
// translation.
- (void)testEveryWordAndCategoryIsTranslatedIntoAllBaseLanguages {
    NSURL *url = [[NSBundle bundleForClass:[LGDataStore class]] URLForResource:@"words"
                                                                 withExtension:@"json"];
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url]
                                                         options:0
                                                           error:nil];
    for (NSDictionary *category in root[@"categories"]) {
        for (NSString *code in LGLanguageManager.allLanguageCodes) {
            XCTAssertTrue([category[@"names"][code] length] > 0,
                          @"category %@ missing %@ name", category[@"id"], code);
            for (NSDictionary *word in category[@"words"]) {
                XCTAssertTrue([word[code] length] > 0,
                              @"word %@ missing %@ translation", word[@"el"], code);
            }
        }
    }
}

- (void)testEveryCategorySymbolResolvesToAnSFSymbol {
    for (LGCategory *category in self.store.categories) {
        XCTAssertNotNil([UIImage systemImageNamed:category.symbolName],
                        @"category %@ has unknown SF Symbol %@",
                        category.categoryID, category.symbolName);
    }
}

- (void)testWordIDsAreUniqueAcrossCategories {
    NSMutableSet<NSString *> *seen = [NSMutableSet set];
    for (LGCategory *category in self.store.categories) {
        for (LGWord *word in category.words) {
            XCTAssertFalse([seen containsObject:word.wordID],
                           @"duplicate word %@", word.wordID);
            [seen addObject:word.wordID];
        }
    }
}

- (void)testFavoritesStartEmpty {
    XCTAssertEqual(self.store.favoriteWords.count, 0u);
}

- (void)testToggleFavoriteAddsAndRemoves {
    LGWord *word = self.store.categories.firstObject.words.firstObject;
    XCTAssertFalse([self.store isFavorite:word]);

    [self.store toggleFavorite:word];
    XCTAssertTrue([self.store isFavorite:word]);
    XCTAssertEqual(self.store.favoriteWords.count, 1u);
    XCTAssertEqualObjects(self.store.favoriteWords.firstObject.wordID, word.wordID);

    [self.store toggleFavorite:word];
    XCTAssertFalse([self.store isFavorite:word]);
    XCTAssertEqual(self.store.favoriteWords.count, 0u);
}

- (void)testFavoritesPersistAcrossStoreInstances {
    LGWord *word = self.store.categories.firstObject.words.firstObject;
    [self.store toggleFavorite:word];

    LGDataStore *reloaded =
        [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                               userDefaults:self.defaults];
    XCTAssertTrue([reloaded isFavorite:word]);
}

- (void)testToggleFavoritePostsNotification {
    LGWord *word = self.store.categories.firstObject.words.firstObject;
    [self expectationForNotification:LGFavoritesDidChangeNotification
                              object:self.store
                             handler:nil];
    [self.store toggleFavorite:word];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
