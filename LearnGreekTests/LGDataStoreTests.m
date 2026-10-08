#import <XCTest/XCTest.h>
#import "LGCategory.h"
#import "LGDataStore.h"
#import "LGFunctionalHelpers.h"
#import "LGLanguageManager.h"
#import "LGSentence.h"
#import "LGPhrase.h"
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

- (void)testLoadsSeventeenCategories {
    XCTAssertEqual(self.store.categories.count, 17u);
}

- (void)testEveryCategoryIsFullyPopulated {
    for (LGCategory *category in self.store.categories) {
        XCTAssertTrue(category.categoryID.length > 0);
        XCTAssertTrue(category.nameGreek.length > 0);
        XCTAssertTrue(category.symbolName.length > 0);
        XCTAssertGreaterThanOrEqual(category.words.count, 6u,
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

// Articles live in their own field so the UI can teach the noun first.
- (void)testArticlesAreSplitFromNouns {
    // "Τα" is deliberately absent: in "Τα λέμε" it's a pronoun, not an article.
    NSSet<NSString *> *articles = [NSSet setWithArray:@[ @"Ο", @"Η", @"Το", @"Οι" ]];
    NSUInteger articleCount = 0;
    for (LGCategory *category in self.store.categories) {
        for (LGWord *word in category.words) {
            NSString *firstToken =
                [word.greek componentsSeparatedByString:@" "].firstObject;
            XCTAssertFalse([articles containsObject:firstToken],
                           @"word %@ still leads with an article", word.greek);
            if (word.article.length > 0) {
                articleCount++;
                XCTAssertTrue([articles containsObject:word.article]);
                NSString *expected =
                    [NSString stringWithFormat:@"%@ %@", word.article, word.greek];
                XCTAssertEqualObjects(word.fullPhrase, expected);
                XCTAssertEqualObjects(word.wordID, expected,
                                      @"wordID must stay the full phrase for favorites compat");
            } else {
                XCTAssertEqualObjects(word.fullPhrase, word.greek);
            }
        }
    }
    XCTAssertGreaterThan(articleCount, 100u, @"most nouns should carry an article");
}

- (void)testEveryCategorySymbolResolvesToAnSFSymbol {
    for (LGCategory *category in self.store.categories) {
        XCTAssertNotNil([UIImage systemImageNamed:category.symbolName],
                        @"category %@ has unknown SF Symbol %@",
                        category.categoryID, category.symbolName);
    }
}

- (void)testOnlyTheKnownSharedPhraseRepeatsAcrossCategories {
    NSArray<LGWord *> *allWords = [self.store.categories lg_flatMap:^NSArray *(LGCategory *category) {
        return category.words;
    }];
    NSArray<NSString *> *ids = [allWords lg_map:^id(LGWord *word) { return word.wordID; }];
    NSArray<NSString *> *repeated = [[NSSet setWithArray:ids].allObjects lg_filter:^BOOL(NSString *identifier) {
        return [ids filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", identifier]].count > 1;
    }];
    XCTAssertEqualObjects(repeated, @[@"Είμαι καλά"]);
}

- (void)testRepeatedWordsShareOneTranslation {
    NSArray<LGWord *> *allWords = [self.store.categories lg_flatMap:^NSArray *(LGCategory *category) {
        return category.words;
    }];
    NSArray<LGWord *> *repeated = [allWords lg_filter:^BOOL(LGWord *word) {
        return [word.greek isEqualToString:@"Είμαι καλά"];
    }];
    NSArray<NSString *> *translations = [repeated lg_map:^id(LGWord *word) {
        return [word translationForLanguage:@"en"];
    }];
    XCTAssertEqual([NSSet setWithArray:translations].count, 1u);
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

#pragma mark - Saved sentences

- (void)testSavedSentencesStartEmpty {
    XCTAssertEqual(self.store.savedSentences.count, 0u);
}

- (void)testSaveSentencePersistsAndDeduplicates {
    [self.store saveSentence:@"Ο Δίας Η Αθηνά"];
    XCTAssertEqualObjects(self.store.savedSentences, (@[ @"Ο Δίας Η Αθηνά" ]));

    // Same sentence again, and a blank one, are both ignored.
    [self.store saveSentence:@"Ο Δίας Η Αθηνά"];
    [self.store saveSentence:@"   "];
    XCTAssertEqual(self.store.savedSentences.count, 1u);

    LGDataStore *reloaded =
        [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                               userDefaults:self.defaults];
    XCTAssertEqualObjects(reloaded.savedSentences, (@[ @"Ο Δίας Η Αθηνά" ]));
}

- (void)testSentencesKeepInsertionOrderAndDelete {
    [self.store saveSentence:@"Καλημέρα"];
    [self.store saveSentence:@"Καληνύχτα"];
    XCTAssertEqualObjects(self.store.savedSentences, (@[ @"Καλημέρα", @"Καληνύχτα" ]));

    [self.store deleteSentence:@"Καλημέρα"];
    XCTAssertEqualObjects(self.store.savedSentences, (@[ @"Καληνύχτα" ]));

    // Deleting something absent is a no-op.
    [self.store deleteSentence:@"Καλημέρα"];
    XCTAssertEqual(self.store.savedSentences.count, 1u);
}

- (void)testSaveSentencePostsNotification {
    [self expectationForNotification:LGSentencesDidChangeNotification object:self.store handler:nil];
    [self.store saveSentence:@"Ο ήλιος"];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testToggleFavoritePostsNotification {
    LGWord *word = self.store.categories.firstObject.words.firstObject;
    [self expectationForNotification:LGFavoritesDidChangeNotification
                              object:self.store
                             handler:nil];
    [self.store toggleFavorite:word];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAddPhraseStoresItAndPostsNotification {
    XCTAssertEqual(self.store.phrases.count, 0u);
    [self expectationForNotification:LGPhrasesDidChangeNotification object:self.store handler:nil];
    [self.store addPhrase:[[LGPhrase alloc] initWithText:@"Good morning" language:LGPhraseLanguageEnglish]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(self.store.phrases.count, 1u);
    XCTAssertEqualObjects(self.store.phrases.firstObject.text, @"Good morning");
}

- (void)testPhrasesSurviveReload {
    [self.store addPhrase:[[LGPhrase alloc] initWithText:@"Καλημέρα" language:LGPhraseLanguageGreek]];
    LGDataStore *reloaded = [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                                                   userDefaults:self.defaults];
    XCTAssertEqual(reloaded.phrases.count, 1u);
    XCTAssertEqualObjects(reloaded.phrases.firstObject.text, @"Καλημέρα");
    XCTAssertEqual(reloaded.phrases.firstObject.language, LGPhraseLanguageGreek);
}

- (void)testUpdatePhraseReplacesMatchingID {
    LGPhrase *phrase = [[LGPhrase alloc] initWithText:@"Thanks" language:LGPhraseLanguageEnglish];
    [self.store addPhrase:phrase];
    LGPhrase *edited = [[LGPhrase alloc] initWithText:@"Thank you" language:LGPhraseLanguageEnglish];
    edited.phraseID = phrase.phraseID;
    [self.store updatePhrase:edited];
    XCTAssertEqual(self.store.phrases.count, 1u);
    XCTAssertEqualObjects(self.store.phrases.firstObject.text, @"Thank you");
}

- (void)testDeletePhraseRemovesIt {
    LGPhrase *phrase = [[LGPhrase alloc] initWithText:@"Bye" language:LGPhraseLanguageEnglish];
    [self.store addPhrase:phrase];
    [self.store deletePhrase:phrase];
    XCTAssertEqual(self.store.phrases.count, 0u);
}

- (void)testDeleteAllPhrasesClearsEveryPhrase {
    [self.store addPhrase:[[LGPhrase alloc] initWithText:@"One" language:LGPhraseLanguageEnglish]];
    [self.store addPhrase:[[LGPhrase alloc] initWithText:@"Ena" language:LGPhraseLanguageGreek]];
    [self.store deleteAllPhrases];
    XCTAssertEqual(self.store.phrases.count, 0u);
}

#pragma mark - Home screen pins

- (NSArray<LGSentence *> *)addSentencesNamed:(NSArray<NSString *> *)names {
    return [names lg_map:^id(NSString *name) {
        LGSentence *sentence = [[LGSentence alloc] initWithText:name iconSymbolName:@"ellipsis.bubble"];
        [self.store addSentence:sentence];
        return sentence;
    }];
}

- (NSArray<NSString *> *)textsOf:(NSArray<LGSentence *> *)sentences {
    return [sentences lg_map:^id(LGSentence *sentence) { return sentence.text; }];
}

- (void)testPinningMovesSentenceOffSavedList {
    LGSentence *sentence = [self addSentencesNamed:@[@"Καλημέρα"]].firstObject;
    [self.store addSentenceToHomeScreen:sentence];
    XCTAssertEqual(self.store.savedSentencesWithIcons.count, 0u);
    XCTAssertEqualObjects([self textsOf:self.store.homeScreenSentences], @[@"Καλημέρα"]);
}

- (void)testFifthPinReturnsTheOldestPinnedSentenceToSaved {
    NSArray<LGSentence *> *sentences = [self addSentencesNamed:@[@"A", @"B", @"C", @"D", @"E"]];
    for (LGSentence *sentence in sentences) {
        [self.store addSentenceToHomeScreen:sentence];
    }
    XCTAssertEqualObjects([self textsOf:self.store.homeScreenSentences], (@[@"B", @"C", @"D", @"E"]));
    XCTAssertEqualObjects([self textsOf:self.store.savedSentencesWithIcons], @[@"A"]);

    LGDataStore *reloaded = [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                                                   userDefaults:self.defaults];
    XCTAssertEqualObjects([self textsOf:reloaded.savedSentencesWithIcons], @[@"A"]);
}

- (void)testUnpinReturnsSentenceToSavedList {
    NSArray<LGSentence *> *sentences = [self addSentencesNamed:@[@"One", @"Two"]];
    [sentences lg_map:^id(LGSentence *sentence) {
        [self.store addSentenceToHomeScreen:sentence];
        return nil;
    }];
    [self.store removeSentenceFromHomeScreen:sentences.firstObject.sentenceID];
    XCTAssertEqualObjects([self textsOf:self.store.homeScreenSentences], @[@"Two"]);
    XCTAssertEqualObjects([self textsOf:self.store.savedSentencesWithIcons], @[@"One"]);
}

- (void)testSavedListHasNoLimit {
    NSArray<NSString *> *names = [@[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10]
        lg_map:^id(NSNumber *n) { return [NSString stringWithFormat:@"Sentence %@", n]; }];
    [self addSentencesNamed:names];
    XCTAssertEqual(self.store.savedSentencesWithIcons.count, 10u);
    XCTAssertEqual(self.store.homeScreenSentences.count, 0u);
}

- (void)testPinningTheSameSentenceTwiceDoesNotDuplicateIt {
    LGSentence *sentence = [self addSentencesNamed:@[@"Once"]].firstObject;
    [self.store addSentenceToHomeScreen:sentence];
    [self.store addSentenceToHomeScreen:sentence];
    XCTAssertEqual(self.store.homeScreenSentences.count, 1u);
}

- (void)testDeletingAPinnedSentenceRemovesItFromHome {
    LGSentence *sentence = [self addSentencesNamed:@[@"Gone"]].firstObject;
    [self.store addSentenceToHomeScreen:sentence];
    [self.store deleteSentenceWithID:sentence];
    XCTAssertEqual(self.store.homeScreenSentences.count, 0u);
    XCTAssertEqual(self.store.savedSentencesWithIcons.count, 0u);
}

- (void)testPinsSurviveReload {
    LGSentence *sentence = [self addSentencesNamed:@[@"Stay"]].firstObject;
    [self.store addSentenceToHomeScreen:sentence];
    LGDataStore *reloaded = [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                                                   userDefaults:self.defaults];
    XCTAssertEqualObjects([self textsOf:reloaded.homeScreenSentences], @[@"Stay"]);
}

- (void)testTranslationIsStoredOnTheSentenceAndSurvivesReload {
    LGSentence *sentence = [[LGSentence alloc] initWithText:@"Καλημέρα" iconSymbolName:@"sun.max"];
    sentence.translation = @"good morning";
    [self.store addSentence:sentence];
    LGDataStore *reloaded = [[LGDataStore alloc] initWithBundle:[NSBundle bundleForClass:[LGDataStore class]]
                                                   userDefaults:self.defaults];
    XCTAssertEqualObjects(reloaded.savedSentencesWithIcons.firstObject.translation, @"good morning");
}

- (void)testDeleteAllSentencesClearsSavedAndPinned {
    NSArray<LGSentence *> *sentences = [self addSentencesNamed:@[@"x", @"y"]];
    [self.store addSentenceToHomeScreen:sentences.firstObject];
    [self.store deleteAllSentences];
    XCTAssertEqual(self.store.savedSentencesWithIcons.count, 0u);
    XCTAssertEqual(self.store.homeScreenSentences.count, 0u);
}

@end
