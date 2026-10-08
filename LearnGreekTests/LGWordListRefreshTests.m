#import <XCTest/XCTest.h>
#import "LGCategory.h"
#import "LGDataStore.h"
#import "LGThemeManager.h"
#import "LGWord.h"
#import "LGWordListViewController.h"

@interface LGWordListRefreshTests : XCTestCase
@property (nonatomic, assign) BOOL savedPronunciation;
@property (nonatomic, assign) BOOL savedTranslation;
@end

@implementation LGWordListRefreshTests

- (void)setUp {
    [super setUp];
    self.savedPronunciation = LGThemeManager.sharedManager.showPronunciation;
    self.savedTranslation = LGThemeManager.sharedManager.showTranslation;
}

- (void)tearDown {
    if (LGThemeManager.sharedManager.showPronunciation != self.savedPronunciation) {
        [LGThemeManager.sharedManager togglePronunciation];
    }
    if (LGThemeManager.sharedManager.showTranslation != self.savedTranslation) {
        [LGThemeManager.sharedManager toggleTranslation];
    }
    [super tearDown];
}

- (UITableViewCell *)firstVisibleCellOf:(LGWordListViewController *)list {
    list.view.frame = CGRectMake(0, 0, 375, 812);
    [list.view layoutIfNeeded];
    UITableView *table = [list valueForKey:@"tableView"];
    return [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)testTogglingPronunciationUpdatesAnOpenWordListImmediately {
    if (!LGThemeManager.sharedManager.showPronunciation) {
        [LGThemeManager.sharedManager togglePronunciation];
    }
    LGCategory *category = LGDataStore.sharedStore.categories.firstObject;
    LGWord *word = category.words.firstObject;
    LGWordListViewController *list = [[LGWordListViewController alloc] initWithCategory:category];
    UILabel *detail = [[self firstVisibleCellOf:list] valueForKey:@"detailLabel"];
    XCTAssertTrue([detail.text containsString:word.transliteration]);

    [LGThemeManager.sharedManager togglePronunciation];

    detail = [[self firstVisibleCellOf:list] valueForKey:@"detailLabel"];
    XCTAssertFalse([detail.text containsString:word.transliteration]);
}

- (void)testTogglingTranslationUpdatesAnOpenWordListImmediately {
    if (!LGThemeManager.sharedManager.showTranslation) {
        [LGThemeManager.sharedManager toggleTranslation];
    }
    LGCategory *category = LGDataStore.sharedStore.categories.firstObject;
    LGWord *word = category.words.firstObject;
    NSString *english = [word translationForLanguage:@"en"];
    LGWordListViewController *list = [[LGWordListViewController alloc] initWithCategory:category];

    [LGThemeManager.sharedManager toggleTranslation];

    UILabel *detail = [[self firstVisibleCellOf:list] valueForKey:@"detailLabel"];
    XCTAssertFalse([detail.text containsString:english]);
}

@end
