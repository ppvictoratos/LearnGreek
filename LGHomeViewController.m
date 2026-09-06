#import "LGHomeViewController.h"
#import "LGCategoryCell.h"
#import "LGCategory.h"
#import "LGDataStore.h"
#import "LGLanguageManager.h"
#import "LGThemeManager.h"
#import "LGWordListViewController.h"
#import "LGInfoViewController.h"
#import "LGSentenceBuilderViewController.h"
#import "LGSentence.h"
#import "LGSpeechService.h"
#import <objc/runtime.h>

// Grid layout: 2 columns. The first two tiles are fixed (Favorites, theme
// toggle), then the word categories, then Help and Sentences close the grid.
static const NSInteger LGTileFavorites = 0;
static const NSInteger LGTileThemeToggle = 1;
static const NSInteger LGTileSentences = 2;
static const NSInteger LGTileHelp = 3;
static const NSInteger LGFixedTileCount = 4;
static const NSInteger LGGridColumns = 2;
static const CGFloat LGGridSpacing = 10;

@interface LGHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *homeScreenSentencesContainer;
@end

@implementation LGHomeViewController

- (void)viewDidLoad {
    NSLog(@"[LGHomeViewController] viewDidLoad called");
    [super viewDidLoad];
    self.title = @"Ελληνικά";
    NSLog(@"[LGHomeViewController] Accessing LGDataStore.sharedStore.categories.count...");

    // Home screen sentences container
    self.homeScreenSentencesContainer = [[UIView alloc] init];
    self.homeScreenSentencesContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.homeScreenSentencesContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.homeScreenSentencesContainer];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.homeScreenSentencesContainer.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.homeScreenSentencesContainer.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [self.homeScreenSentencesContainer.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [self.homeScreenSentencesContainer.heightAnchor constraintEqualToConstant:120]
    ]];

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
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.homeScreenSentencesContainer.bottomAnchor],
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
    [self populateHomeScreenSentences];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applyTheme)
                   name:LGThemeDidChangeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(languageDidChange)
                   name:LGLanguageDidChangeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(populateHomeScreenSentences)
                   name:LGSentencesDidChangeNotification
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

#pragma mark - Home Screen Sentences

- (void)populateHomeScreenSentences {
    NSLog(@"[LGHomeViewController] populateHomeScreenSentences called");

    // Clear any existing subviews
    [self.homeScreenSentencesContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    LGDataStore *store = [LGDataStore sharedStore];
    NSSet<NSString *> *homeScreenIDs = store.sentencesOnHomeScreen;

    NSLog(@"[LGHomeViewController] Home screen sentence count: %lu", (unsigned long)homeScreenIDs.count);

    if (homeScreenIDs.count == 0) {
        NSLog(@"[LGHomeViewController] No home screen sentences to display");
        return;
    }

    // Create stack view for static layout (no scroll)
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 10;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.layoutMargins = UIEdgeInsetsMake(8, 16, 8, 16);
    stackView.layoutMarginsRelativeArrangement = YES;
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self.homeScreenSentencesContainer addSubview:stackView];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.homeScreenSentencesContainer.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.homeScreenSentencesContainer.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.homeScreenSentencesContainer.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.homeScreenSentencesContainer.bottomAnchor]
    ]];

    // Build buttons for each home screen sentence
    NSArray<LGSentence *> *allSentences = store.savedSentencesWithIcons;
    for (LGSentence *sentence in allSentences) {
        if ([homeScreenIDs containsObject:sentence.sentenceID]) {
            [self createTileButton:sentence inStackView:stackView];
        }
    }
}

- (void)createTileButton:(LGSentence *)sentence inStackView:(UIStackView *)stackView {
    NSLog(@"[LGHomeViewController] Creating tile for sentence: %@", sentence.text);

    // Container button
    UIButton *tileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    tileButton.translatesAutoresizingMaskIntoConstraints = NO;
    tileButton.backgroundColor = [UIColor systemGreenColor];
    tileButton.tintColor = [UIColor whiteColor];
    tileButton.layer.cornerRadius = 8;
    tileButton.clipsToBounds = YES;
    [tileButton addTarget:self action:@selector(tileButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(tileButton, "sentence", sentence, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // Internal layout: icon (left) + text stack (right)
    UIStackView *contentStack = [[UIStackView alloc] init];
    contentStack.axis = UILayoutConstraintAxisHorizontal;
    contentStack.spacing = 8;
    contentStack.alignment = UIStackViewAlignmentCenter;
    contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [tileButton addSubview:contentStack];

    // Icon view (left third)
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.tintColor = [UIColor whiteColor];
    if (sentence.iconSymbolName && sentence.iconSymbolName.length > 0) {
        iconView.image = [UIImage systemImageNamed:sentence.iconSymbolName];
    }
    [contentStack addArrangedSubview:iconView];
    [iconView.widthAnchor constraintEqualToConstant:28].active = YES;
    [iconView.heightAnchor constraintEqualToConstant:28].active = YES;

    // Text stack (name + translation)
    UIStackView *textStack = [[UIStackView alloc] init];
    textStack.axis = UILayoutConstraintAxisVertical;
    textStack.spacing = 2;
    textStack.alignment = UIStackViewAlignmentLeading;
    textStack.translatesAutoresizingMaskIntoConstraints = NO;

    // Bold sentence text
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = sentence.text;
    nameLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.numberOfLines = 2;
    [textStack addArrangedSubview:nameLabel];

    // Smaller translation (placeholder)
    UILabel *translationLabel = [[UILabel alloc] init];
    translationLabel.text = @"Greek sentence";
    translationLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightRegular];
    translationLabel.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    translationLabel.numberOfLines = 1;
    [textStack addArrangedSubview:translationLabel];

    [contentStack addArrangedSubview:textStack];

    // Layout content in button
    [NSLayoutConstraint activateConstraints:@[
        [contentStack.leadingAnchor constraintEqualToAnchor:tileButton.leadingAnchor constant:8],
        [contentStack.trailingAnchor constraintEqualToAnchor:tileButton.trailingAnchor constant:-8],
        [contentStack.topAnchor constraintEqualToAnchor:tileButton.topAnchor constant:8],
        [contentStack.bottomAnchor constraintEqualToAnchor:tileButton.bottomAnchor constant:-8]
    ]];

    [stackView addArrangedSubview:tileButton];

    // Set minimum height so button isn't collapsed
    [tileButton.heightAnchor constraintGreaterThanOrEqualToConstant:80].active = YES;
}

- (void)tileButtonTapped:(UIButton *)button {
    LGSentence *sentence = objc_getAssociatedObject(button, "sentence");
    if (sentence) {
        NSLog(@"[LGHomeViewController] Playing audio for: %@", sentence.text);
        [[LGSpeechService sharedService] speakText:sentence.text];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return LGFixedTileCount + (NSInteger)LGDataStore.sharedStore.categories.count;
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
    } else if (indexPath.item == LGTileSentences) {
        [cell configureWithSymbolName:@"wand.and.stars"
                           titleGreek:@"Προτάσεις"
                             subtitle:[[self class] tileString:@"sentences"]];
        cell.accessibilityIdentifier = @"home.tile.sentences";
        // Hot pink for sentences
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:0.1 blue:0.6 alpha:1.0];
    } else if (indexPath.item == LGTileHelp) {
        [cell configureWithSymbolName:@"questionmark.circle.fill"
                           titleGreek:@"Βοήθεια"
                             subtitle:[[self class] tileString:@"help"]];
        cell.accessibilityIdentifier = @"home.tile.help";
        // Purple for help
        cell.backgroundColor = [UIColor colorWithRed:0.5 green:0.0 blue:1.0 alpha:1.0];
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
    if (indexPath.item == LGTileHelp) {
        [self.navigationController pushViewController:[[LGInfoViewController alloc] init]
                                             animated:YES];
        return;
    }
    if (indexPath.item == LGTileSentences) {
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
