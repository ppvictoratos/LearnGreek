#import "LGPhrasesViewController.h"
#import "LGDataStore.h"
#import "LGPhrase.h"
#import "LGThemeManager.h"

@interface LGPhrasesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISegmentedControl *languageFilter;
@property (nonatomic, strong) NSMutableArray<LGPhrase *> *displayedPhrases;
@property (nonatomic, assign) LGPhraseLanguage selectedLanguage;
@end

@implementation LGPhrasesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Phrases";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.view.backgroundColor = [LGThemeManager sharedManager].backgroundColor;

    // Search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Search phrases...";
    self.searchBar.delegate = self;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;

    // Language filter
    self.languageFilter = [[UISegmentedControl alloc] initWithItems:@[@"All", @"English", @"Greek"]];
    self.languageFilter.selectedSegmentIndex = 0;
    [self.languageFilter addTarget:self action:@selector(languageFilterChanged) forControlEvents:UIControlEventValueChanged];
    self.languageFilter.translatesAutoresizingMaskIntoConstraints = NO;

    // Header stack
    UIStackView *headerStack = [[UIStackView alloc] initWithArrangedSubviews:@[self.searchBar, self.languageFilter]];
    headerStack.axis = UILayoutConstraintAxisVertical;
    headerStack.spacing = 8;
    headerStack.layoutMargins = UIEdgeInsetsMake(12, 16, 8, 16);
    headerStack.layoutMarginsRelativeArrangement = YES;
    headerStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headerStack];

    // Table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [headerStack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [headerStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [headerStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        [self.tableView.topAnchor constraintEqualToAnchor:headerStack.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    self.displayedPhrases = [NSMutableArray array];
    self.selectedLanguage = NSNotFound;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phrasesDidChange) name:LGPhrasesDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyTheme) name:LGThemeDidChangeNotification object:nil];

    [self applyTheme];
    [self updateDisplayedPhrases];
}

- (void)applyTheme {
    LGThemeManager *theme = LGThemeManager.sharedManager;
    self.view.backgroundColor = theme.backgroundColor;
    self.tableView.backgroundColor = theme.backgroundColor;
    self.searchBar.barTintColor = theme.backgroundColor;
}

- (void)languageFilterChanged {
    [self updateDisplayedPhrases];
}

- (void)updateDisplayedPhrases {
    [self.displayedPhrases removeAllObjects];
    NSString *searchText = self.searchBar.text ?: @"";

    for (LGPhrase *phrase in [LGDataStore sharedStore].phrases) {
        BOOL languageMatch = (self.languageFilter.selectedSegmentIndex == 0 || phrase.language == (self.languageFilter.selectedSegmentIndex - 1));
        BOOL textMatch = searchText.length == 0 || [phrase.text localizedCaseInsensitiveContainsString:searchText];

        if (languageMatch && textMatch) {
            [self.displayedPhrases addObject:phrase];
        }
    }

    [self.tableView reloadData];
}

- (void)phrasesDidChange {
    [self updateDisplayedPhrases];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayedPhrases.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const reuseID = @"LGPhraseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    LGPhrase *phrase = self.displayedPhrases[indexPath.row];
    cell.textLabel.text = phrase.text;
    cell.textLabel.textColor = [LGThemeManager sharedManager].primaryTextColor;
    cell.detailTextLabel.text = phrase.language == LGPhraseLanguageEnglish ? @"English" : @"Greek";
    cell.detailTextLabel.textColor = [LGThemeManager sharedManager].secondaryTextColor;
    cell.backgroundColor = [LGThemeManager sharedManager].backgroundColor;

    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateDisplayedPhrases];
}

@end
