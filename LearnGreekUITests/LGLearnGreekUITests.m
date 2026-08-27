#import <XCTest/XCTest.h>

// End-to-end flows: browse a category, hear-a-word tap, favorite/unfavorite,
// favorites list round trip, and the theme toggle.
@interface LGLearnGreekUITests : XCTestCase
@property (nonatomic, strong) XCUIApplication *app;
@end

@implementation LGLearnGreekUITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    self.app = [[XCUIApplication alloc] init];
    self.app.launchArguments = @[ @"--uitest-reset" ];
    [self.app launch];
}

- (void)testHomeShowsEighteenTiles {
    XCUIElement *grid = self.app.collectionViews[@"home.grid"];
    XCTAssertTrue([grid waitForExistenceWithTimeout:5]);
    XCTAssertEqual(grid.cells.count, 18u);
    XCTAssertTrue(grid.cells[@"home.tile.favorites"].exists);
    XCTAssertTrue(grid.cells[@"home.tile.theme"].exists);
    XCTAssertTrue(grid.cells[@"home.tile.mythology"].exists);
    XCTAssertTrue(grid.cells[@"home.tile.astrology"].exists);
    XCTAssertTrue(grid.cells[@"home.tile.help"].exists);
    XCTAssertTrue(grid.cells[@"home.tile.sentences"].exists);
}

- (void)testHelpTileOpensInfoPageWithBlurbAndCredits {
    XCUIElement *grid = self.app.collectionViews[@"home.grid"];
    XCTAssertTrue([grid waitForExistenceWithTimeout:5]);
    [grid.cells[@"home.tile.help"] tap];

    XCTAssertTrue([self.app.staticTexts[@"info.blurb"] waitForExistenceWithTimeout:5]);
    XCTAssertTrue(self.app.staticTexts[@"credits.name"].exists);
    XCTAssertTrue(self.app.staticTexts[@"credits.quote"].exists);
    XCTAssertTrue(self.app.staticTexts[@"credits.quoteTranslation"].exists);
}

- (void)testSentenceBuilderStringsFavoritedWords {
    XCUIElement *grid = self.app.collectionViews[@"home.grid"];
    XCTAssertTrue([grid waitForExistenceWithTimeout:5]);

    // Favorite two mythology words.
    [grid.cells[@"home.tile.mythology"] tap];
    XCUIElement *wordTable = self.app.tables[@"wordList.table"];
    XCTAssertTrue([wordTable waitForExistenceWithTimeout:5]);
    [wordTable.cells[@"word.Ο Δίας"].buttons[@"word.favoriteButton"] tap];
    [wordTable.cells[@"word.Η Αθηνά"].buttons[@"word.favoriteButton"] tap];
    [self.app.navigationBars.buttons.firstMatch tap];

    // Build a chain from them.
    [grid.cells[@"home.tile.sentences"] tap];
    XCUIElement *table = self.app.tables[@"sentence.table"];
    XCTAssertTrue([table waitForExistenceWithTimeout:5]);
    [table.cells[@"word.Ο Δίας"] tap];
    [table.cells[@"word.Η Αθηνά"] tap];

    XCUIElement *chain = self.app.staticTexts[@"sentence.chain"];
    XCTAssertEqualObjects(chain.label, @"Ο Δίας Η Αθηνά");

    [self.app.buttons[@"sentence.play"] tap];
    XCTAssertTrue(chain.exists);

    [self.app.buttons[@"sentence.clear"] tap];
    XCTAssertEqualObjects(chain.label, @"…");
}

- (void)testCategoryOpensWordListAndSpeaksOnTap {
    XCUIElement *grid = self.app.collectionViews[@"home.grid"];
    XCTAssertTrue([grid waitForExistenceWithTimeout:5]);
    [grid.cells[@"home.tile.mythology"] tap];

    XCUIElement *table = self.app.tables[@"wordList.table"];
    XCTAssertTrue([table waitForExistenceWithTimeout:5]);
    XCUIElement *zeus = table.cells[@"word.Ο Δίας"];
    XCTAssertTrue(zeus.exists);
    // Tapping a row triggers speech; the assertable effect is that nothing
    // navigates away and the row stays present.
    [zeus tap];
    XCTAssertTrue(table.exists);
    XCTAssertTrue(zeus.exists);
}

- (void)testFavoriteRoundTrip {
    XCUIElement *grid = self.app.collectionViews[@"home.grid"];
    XCTAssertTrue([grid waitForExistenceWithTimeout:5]);

    // Favorites starts empty.
    [grid.cells[@"home.tile.favorites"] tap];
    XCTAssertTrue([self.app.staticTexts[@"wordList.empty"] waitForExistenceWithTimeout:5]);
    [self.app.navigationBars.buttons.firstMatch tap];

    // Favorite Zeus from the mythology list.
    [grid.cells[@"home.tile.mythology"] tap];
    XCUIElement *table = self.app.tables[@"wordList.table"];
    XCTAssertTrue([table waitForExistenceWithTimeout:5]);
    XCUIElement *zeus = table.cells[@"word.Ο Δίας"];
    [zeus.buttons[@"word.favoriteButton"] tap];
    [self.app.navigationBars.buttons.firstMatch tap];

    // He shows up in favorites.
    [grid.cells[@"home.tile.favorites"] tap];
    XCTAssertTrue([table waitForExistenceWithTimeout:5]);
    XCUIElement *favoritedZeus = table.cells[@"word.Ο Δίας"];
    XCTAssertTrue([favoritedZeus waitForExistenceWithTimeout:5]);

    // Unfavoriting from the favorites list removes him and shows the empty state.
    [favoritedZeus.buttons[@"word.favoriteButton"] tap];
    XCTAssertTrue([self.app.staticTexts[@"wordList.empty"] waitForExistenceWithTimeout:5]);
}

- (void)testLanguageSwitchUpdatesTileSubtitles {
    XCUIElement *grid = self.app.collectionViews[@"home.grid"];
    XCTAssertTrue([grid waitForExistenceWithTimeout:5]);
    XCUIElement *mythologyTile = grid.cells[@"home.tile.mythology"];
    XCTAssertTrue(mythologyTile.staticTexts[@"Mythology"].exists);

    [self.app.navigationBars.buttons[@"home.languageButton"] tap];
    [self.app.sheets.buttons[@"Español"] tap];
    XCTAssertTrue([mythologyTile.staticTexts[@"Mitología"] waitForExistenceWithTimeout:5]);

    // Word translations follow the base language too.
    [mythologyTile tap];
    XCUIElement *table = self.app.tables[@"wordList.table"];
    XCTAssertTrue([table waitForExistenceWithTimeout:5]);
    XCUIElement *god = table.cells[@"word.Ο θεός"];
    NSPredicate *containsDios = [NSPredicate predicateWithFormat:@"label CONTAINS 'Dios'"];
    NSUInteger matches = [god.staticTexts matchingPredicate:containsDios].count;
    XCTAssertGreaterThan(matches, 0u);
}

- (void)testThemeToggleFlipsTileLabel {
    XCUIElement *grid = self.app.collectionViews[@"home.grid"];
    XCTAssertTrue([grid waitForExistenceWithTimeout:5]);

    XCUIElement *themeTile = grid.cells[@"home.tile.theme"];
    XCTAssertTrue(themeTile.staticTexts[@"Dark mode"].exists);

    [themeTile tap];
    XCTAssertTrue([themeTile.staticTexts[@"Light mode"] waitForExistenceWithTimeout:5]);

    [themeTile tap];
    XCTAssertTrue([themeTile.staticTexts[@"Dark mode"] waitForExistenceWithTimeout:5]);
}

@end
