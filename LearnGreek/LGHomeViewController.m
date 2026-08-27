#import "LGHomeViewController.h"
#import "LGCategoryCell.h"
#import "LGCategory.h"
#import "LGDataStore.h"
#import "LGLanguageManager.h"
#import "LGThemeManager.h"
#import "LGWordListViewController.h"
#import "LGInfoViewController.h"
#import "LGSentenceBuilderViewController.h"

// Grid layout: 2 columns. The first two tiles are fixed (Favorites, theme
// toggle), then the word categories, then Help and Sentences close the grid.
static const NSInteger LGTileFavorites = 0;
static const NSInteger LGTileThemeToggle = 1;
static const NSInteger LGFixedTileCount = 2;
static const NSInteger LGTrailingTileCount = 2;  // Help, Sentences
static const NSInteger LGGridColumns = 2;
static const CGFloat LGGridSpacing = 10;

@interface LGHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation LGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Ελληνικά";

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = LGGridSpacing;
    layout.minimumLineSpacing = LGGridSpacing;
    layout.sectionInset = UIEdgeInsetsMake(LGGridSpacing, LGGridSpacing, LGGridSpacing, LGGridSpacing);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = NO;
    self.collectionView.accessibilityIdentifier = @"home.grid";
    [self.collectionView registerClass:[LGCategoryCell class]
            forCellWithReuseIdentifier:[LGCategoryCell reuseIdentifier]];

    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
    ]];

    UIBarButtonItem *languageButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"globe"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(languageButtonTapped)];
    languageButton.accessibilityIdentifier = @"home.languageButton";
    self.navigationItem.rightBarButtonItem = languageButton;

    [self applyTheme];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applyTheme)
                   name:LGThemeDidChangeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(languageDidChange)
                   name:LGLanguageDidChangeNotification
                 object:nil];
}

- (void)languageDidChange {
    [self.collectionView reloadData];
}

- (void)languageButtonTapped {
    UIAlertController *sheet =
        [UIAlertController alertControllerWithTitle:@"Base language"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *code in LGLanguageManager.supportedLanguageCodes) {
        NSString *name = [LGLanguageManager displayNameForLanguageCode:code];
        BOOL current = [LGLanguageManager.sharedManager.languageCode isEqualToString:code];
        NSString *title = current ? [NSString stringWithFormat:@"%@ ✓", name] : name;
        [sheet addAction:[UIAlertAction actionWithTitle:title
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
            [LGLanguageManager.sharedManager setLanguageCode:code];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    sheet.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)applyTheme {
    LGThemeManager *theme = LGThemeManager.sharedManager;
    self.view.backgroundColor = theme.backgroundColor;
    self.collectionView.backgroundColor = theme.backgroundColor;
    if (self.navigationController) {
        [theme applyToNavigationController:self.navigationController];
    }
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return LGFixedTileCount + (NSInteger)LGDataStore.sharedStore.categories.count +
           LGTrailingTileCount;
}

- (NSInteger)helpTileIndex {
    return LGFixedTileCount + (NSInteger)LGDataStore.sharedStore.categories.count;
}

- (NSInteger)sentencesTileIndex {
    return [self helpTileIndex] + 1;
}

+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)localizedTileStrings {
    return @{
        @"favorites" : @{ @"en" : @"Favorites", @"es" : @"Favoritos", @"it" : @"Preferiti",
                          @"fr" : @"Favoris", @"yue" : @"最愛" },
        @"help" : @{ @"en" : @"Help", @"es" : @"Ayuda", @"it" : @"Aiuto",
                     @"fr" : @"Aide", @"yue" : @"幫助" },
        @"sentences" : @{ @"en" : @"Sentences", @"es" : @"Frases", @"it" : @"Frasi",
                          @"fr" : @"Phrases", @"yue" : @"句子" },
    };
}

+ (NSString *)tileString:(NSString *)key {
    NSString *language = LGLanguageManager.sharedManager.languageCode;
    NSDictionary *entry = [self localizedTileStrings][key];
    return entry[language] ?: entry[@"en"];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LGCategoryCell *cell = [collectionView
        dequeueReusableCellWithReuseIdentifier:[LGCategoryCell reuseIdentifier]
                                  forIndexPath:indexPath];

    NSString *language = LGLanguageManager.sharedManager.languageCode;
    if (indexPath.item == LGTileFavorites) {
        [cell configureWithSymbolName:@"star.fill"
                           titleGreek:@"Αγαπημένα"
                             subtitle:[[self class] tileString:@"favorites"]];
        cell.accessibilityIdentifier = @"home.tile.favorites";
    } else if (indexPath.item == LGTileThemeToggle) {
        // The tile names the mode you are in, not the one you'd switch to.
        BOOL isDark = LGThemeManager.sharedManager.style == LGThemeStyleDark;
        [cell configureWithSymbolName:@"circle.lefthalf.filled"
                           titleGreek:@"Θέμα"
                             subtitle:(isDark ? @"Dark mode" : @"Light mode")];
        cell.accessibilityIdentifier = @"home.tile.theme";
    } else if (indexPath.item == [self helpTileIndex]) {
        [cell configureWithSymbolName:@"questionmark.circle.fill"
                           titleGreek:@"Βοήθεια"
                             subtitle:[[self class] tileString:@"help"]];
        cell.accessibilityIdentifier = @"home.tile.help";
    } else if (indexPath.item == [self sentencesTileIndex]) {
        [cell configureWithSymbolName:@"wand.and.stars"
                           titleGreek:@"Προτάσεις"
                             subtitle:[[self class] tileString:@"sentences"]];
        cell.accessibilityIdentifier = @"home.tile.sentences";
    } else {
        LGCategory *category =
            LGDataStore.sharedStore.categories[(NSUInteger)(indexPath.item - LGFixedTileCount)];
        [cell configureWithSymbolName:category.symbolName
                           titleGreek:category.nameGreek
                             subtitle:[category nameForLanguage:language]];
        cell.accessibilityIdentifier =
            [NSString stringWithFormat:@"home.tile.%@", category.categoryID];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize bounds = collectionView.bounds.size;
    NSInteger items = [self collectionView:collectionView numberOfItemsInSection:0];
    NSInteger rows = (items + LGGridColumns - 1) / LGGridColumns;
    CGFloat width = (bounds.width - LGGridSpacing * (LGGridColumns + 1)) / LGGridColumns;
    CGFloat height = (bounds.height - LGGridSpacing * (rows + 1)) / rows;
    return CGSizeMake(floor(width), floor(MAX(height, 58)));
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == LGTileThemeToggle) {
        [LGThemeManager.sharedManager toggleTheme];
        return;
    }
    if (indexPath.item == [self helpTileIndex]) {
        [self.navigationController pushViewController:[[LGInfoViewController alloc] init]
                                             animated:YES];
        return;
    }
    if (indexPath.item == [self sentencesTileIndex]) {
        [self.navigationController
            pushViewController:[[LGSentenceBuilderViewController alloc] init]
                      animated:YES];
        return;
    }

    LGWordListViewController *list;
    if (indexPath.item == LGTileFavorites) {
        list = [[LGWordListViewController alloc] initWithFavorites];
    } else {
        LGCategory *category =
            LGDataStore.sharedStore.categories[(NSUInteger)(indexPath.item - LGFixedTileCount)];
        list = [[LGWordListViewController alloc] initWithCategory:category];
    }
    [self.navigationController pushViewController:list animated:YES];
}

@end
