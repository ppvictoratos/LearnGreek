#import <XCTest/XCTest.h>
#import "LGFunctionalHelpers.h"
#import "LGHomeViewController.h"

static NSString *const LGTestTitle = @"Ελληνικά";

@interface LGHomeScreenTests : XCTestCase
@property (nonatomic, strong) LGHomeViewController *home;
@end

@implementation LGHomeScreenTests

- (void)setUp {
    [super setUp];
    self.home = [[LGHomeViewController alloc] init];
    self.home.view.frame = CGRectMake(0, 0, 375, 812);
    [self.home loadViewIfNeeded];
    [self.home.view layoutIfNeeded];
}

- (UICollectionView *)grid {
    return [self.home valueForKey:@"collectionView"];
}

- (NSArray<NSIndexPath *> *)allTileIndexPaths {
    NSInteger count = [[self grid] numberOfItemsInSection:0];
    NSMutableArray<NSNumber *> *indexes = [NSMutableArray arrayWithCapacity:(NSUInteger)count];
    for (NSInteger i = 0; i < count; i++) {
        [indexes addObject:@(i)];
    }
    return [indexes lg_map:^id(NSNumber *i) {
        return [NSIndexPath indexPathForItem:i.integerValue inSection:0];
    }];
}

- (void)testGridHasAnEvenNumberOfTilesSoColumnsAlign {
    NSInteger count = [[self grid] numberOfItemsInSection:0];
    XCTAssertEqual(count % 2, 0);
}

- (void)testGridHoldsSentencesThemeAndHelpThenEveryCategory {
    NSArray<NSString *> *identifiers = [[self allTileIndexPaths] lg_map:^id(NSIndexPath *path) {
        UICollectionViewCell *cell = [self.home performSelector:@selector(collectionView:cellForItemAtIndexPath:)
                                                     withObject:[self grid]
                                                     withObject:path];
        return cell.accessibilityIdentifier;
    }];
    XCTAssertEqualObjects([identifiers subarrayWithRange:NSMakeRange(0, 3)],
                          (@[@"home.tile.sentences", @"home.tile.theme", @"home.tile.help"]));
    NSArray<NSString *> *categoryTiles = [identifiers subarrayWithRange:NSMakeRange(3, identifiers.count - 3)];
    XCTAssertTrue([categoryTiles lg_filter:^BOOL(NSString *id) { return [id hasPrefix:@"home.tile."]; }].count
                  == categoryTiles.count);
    XCTAssertEqual(categoryTiles.count, 17u);
}

- (void)testEveryTileIsAtLeastAsTallAsItsContent {
    NSArray<NSNumber *> *heights = [[self allTileIndexPaths] lg_map:^id(NSIndexPath *path) {
        UICollectionViewLayoutAttributes *attributes =
            [[self grid].collectionViewLayout layoutAttributesForItemAtIndexPath:path];
        return @(attributes.frame.size.height);
    }];
    NSArray<NSNumber *> *tooShort = [heights lg_filter:^BOOL(NSNumber *height) { return height.doubleValue < 52; }];
    XCTAssertEqual(tooShort.count, 0u);
}

- (void)testTileWidthsMatchAcrossTheRow {
    NSArray<NSNumber *> *widths = [[self allTileIndexPaths] lg_map:^id(NSIndexPath *path) {
        return @([[self grid].collectionViewLayout layoutAttributesForItemAtIndexPath:path].frame.size.width);
    }];
    NSSet<NSNumber *> *distinct = [NSSet setWithArray:widths];
    XCTAssertEqual(distinct.count, 1u);
}

- (void)testTitleIsEllinikaAndTapSpeaksIt {
    UILabel *title = (UILabel *)self.home.navigationItem.titleView;
    XCTAssertTrue([title isKindOfClass:[UILabel class]]);
    XCTAssertEqualObjects(title.text, LGTestTitle);
    XCTAssertEqual(title.gestureRecognizers.count, 1u);
}

@end
