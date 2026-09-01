#import "LGWordListViewController.h"
#import "LGCategory.h"
#import "LGDataStore.h"
#import "LGLanguageManager.h"
#import "LGSpeechService.h"
#import "LGThemeManager.h"
#import "LGWord.h"
#import "LGWordCell.h"

@interface LGWordListViewController () <UITableViewDataSource, UITableViewDelegate, LGWordCellDelegate>
@property (nonatomic, strong, nullable) LGCategory *category;
@property (nonatomic, assign) BOOL showsFavorites;
@property (nonatomic, copy) NSArray<LGWord *> *words;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@end

@implementation LGWordListViewController

- (instancetype)initWithCategory:(LGCategory *)category {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _category = category;
        _showsFavorites = NO;
    }
    return self;
}

- (instancetype)initWithFavorites {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _showsFavorites = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.showsFavorites ? @"Αγαπημένα" : self.category.nameGreek;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 72;
    self.tableView.accessibilityIdentifier = @"wordList.table";
    [self.tableView registerClass:[LGWordCell class]
           forCellReuseIdentifier:[LGWordCell reuseIdentifier]];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"Tap ☆ on a word to save it here.";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.accessibilityIdentifier = @"wordList.empty";
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.emptyLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.emptyLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
    ]];

    [self reloadWords];
    [self applyTheme];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(favoritesDidChange)
                   name:LGFavoritesDidChangeNotification
                 object:nil];
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
    [self.tableView reloadData];
}

- (void)reloadWords {
    self.words = self.showsFavorites ? LGDataStore.sharedStore.favoriteWords : self.category.words;
    self.emptyLabel.hidden = !(self.showsFavorites && self.words.count == 0);
    [self.tableView reloadData];
}

- (void)favoritesDidChange {
    if (self.showsFavorites) {
        [self reloadWords];
    }
}

- (void)applyTheme {
    LGThemeManager *theme = LGThemeManager.sharedManager;
    self.view.backgroundColor = theme.backgroundColor;
    self.tableView.backgroundColor = theme.backgroundColor;
    self.tableView.separatorColor = theme.separatorColor;
    self.emptyLabel.textColor = theme.secondaryTextColor;
    self.emptyLabel.font = [theme fontOfSize:15 weight:UIFontWeightRegular];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.words.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LGWordCell *cell = [tableView dequeueReusableCellWithIdentifier:[LGWordCell reuseIdentifier]
                                                       forIndexPath:indexPath];
    LGWord *word = self.words[(NSUInteger)indexPath.row];
    cell.delegate = self;
    [cell configureWithWord:word favorite:[LGDataStore.sharedStore isFavorite:word]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [LGSpeechService.sharedService speakWord:self.words[(NSUInteger)indexPath.row]];
}

#pragma mark - LGWordCellDelegate

- (void)wordCellDidTapFavorite:(LGWordCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    LGWord *word = self.words[(NSUInteger)indexPath.row];
    [LGDataStore.sharedStore toggleFavorite:word];
    if (!self.showsFavorites) {
        // Favorites list reloads via the notification; here just refresh the star.
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
