#import "LGSentenceBuilderViewController.h"
#import "LGDataStore.h"
#import "LGLanguageManager.h"
#import "LGSpeechService.h"
#import "LGThemeManager.h"
#import "LGWord.h"
#import "LGWordCell.h"

@interface LGSentenceBuilderViewController () <UITableViewDataSource, UITableViewDelegate,
                                               LGWordCellDelegate>
@property (nonatomic, copy) NSArray<LGWord *> *favorites;
@property (nonatomic, strong) NSMutableArray<LGWord *> *chain;
@property (nonatomic, strong) UILabel *sentenceLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation LGSentenceBuilderViewController

+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)localizedStrings {
    return @{
        @"hint" : @{
            @"en" : @"Tap your favorite words to string them together, then play the chain "
                    @"and repeat it out loud. Favorite words from any category to use them here.",
            @"es" : @"Toca tus palabras favoritas para encadenarlas, luego reprodúcelas y "
                    @"repítelas en voz alta. Marca palabras de cualquier categoría para usarlas aquí.",
            @"it" : @"Tocca le tue parole preferite per metterle in fila, poi ascolta la "
                    @"catena e ripetila ad alta voce. Aggiungi preferiti da qualsiasi categoria.",
            @"fr" : @"Touche tes mots favoris pour les enchaîner, puis écoute la chaîne et "
                    @"répète-la à voix haute. Étoile des mots de n'importe quelle catégorie.",
            @"yue" : @"撳你嘅最愛字將佢哋串埋一齊，然後播出嚟，大聲重複講。喺任何分類撳星，"
                     @"啲字就會喺呢度出現。",
        },
    };
}

+ (NSString *)string:(NSString *)key {
    NSDictionary *entry = [self localizedStrings][key];
    return entry[LGLanguageManager.sharedManager.languageCode] ?: entry[@"en"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Προτάσεις";
    self.chain = [NSMutableArray array];

    self.sentenceLabel = [[UILabel alloc] init];
    self.sentenceLabel.numberOfLines = 0;
    self.sentenceLabel.accessibilityIdentifier = @"sentence.chain";

    self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"]
                     forState:UIControlStateNormal];
    self.playButton.accessibilityIdentifier = @"sentence.play";
    [self.playButton addTarget:self
                        action:@selector(playChain)
              forControlEvents:UIControlEventTouchUpInside];

    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearButton setImage:[UIImage systemImageNamed:@"trash.circle"]
                      forState:UIControlStateNormal];
    self.clearButton.accessibilityIdentifier = @"sentence.clear";
    [self.clearButton addTarget:self
                         action:@selector(clearChain)
               forControlEvents:UIControlEventTouchUpInside];

    UIStackView *controls = [[UIStackView alloc]
        initWithArrangedSubviews:@[ self.sentenceLabel, self.playButton, self.clearButton ]];
    controls.axis = UILayoutConstraintAxisHorizontal;
    controls.alignment = UIStackViewAlignmentCenter;
    controls.spacing = 12;
    [self.sentenceLabel setContentHuggingPriority:UILayoutPriorityDefaultLow
                                          forAxis:UILayoutConstraintAxisHorizontal];

    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.text = [[self class] string:@"hint"];
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.accessibilityIdentifier = @"sentence.hint";

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 64;
    self.tableView.accessibilityIdentifier = @"sentence.table";
    [self.tableView registerClass:[LGWordCell class]
           forCellReuseIdentifier:[LGWordCell reuseIdentifier]];

    UIStackView *layout = [[UIStackView alloc]
        initWithArrangedSubviews:@[ controls, self.hintLabel, self.tableView ]];
    layout.axis = UILayoutConstraintAxisVertical;
    layout.spacing = 12;
    layout.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:layout];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [layout.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [layout.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [layout.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [layout.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    [self reloadFavorites];
    [self renderChain];
    [self applyTheme];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(reloadFavorites)
                   name:LGFavoritesDidChangeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(applyTheme)
                   name:LGThemeDidChangeNotification
                 object:nil];
}

- (void)reloadFavorites {
    self.favorites = LGDataStore.sharedStore.favoriteWords;
    [self.tableView reloadData];
}

- (void)renderChain {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    for (LGWord *word in self.chain) {
        [parts addObject:word.fullPhrase];
    }
    self.sentenceLabel.text =
        self.chain.count > 0 ? [parts componentsJoinedByString:@" "] : @"…";
    self.playButton.enabled = self.chain.count > 0;
    self.clearButton.enabled = self.chain.count > 0;
}

- (void)playChain {
    [LGSpeechService.sharedService speakText:self.sentenceLabel.text];
}

- (void)clearChain {
    [self.chain removeAllObjects];
    [self renderChain];
}

- (void)applyTheme {
    LGThemeManager *theme = LGThemeManager.sharedManager;
    self.view.backgroundColor = theme.backgroundColor;
    self.tableView.backgroundColor = theme.backgroundColor;
    self.tableView.separatorColor = theme.separatorColor;
    self.sentenceLabel.textColor = theme.primaryTextColor;
    self.sentenceLabel.font = [theme fontOfSize:20 weight:UIFontWeightSemibold];
    self.hintLabel.textColor = theme.secondaryTextColor;
    self.hintLabel.font = [theme fontOfSize:13 weight:UIFontWeightRegular];
    self.playButton.tintColor = theme.accentColor;
    self.clearButton.tintColor = theme.secondaryTextColor;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LGWordCell *cell = [tableView dequeueReusableCellWithIdentifier:[LGWordCell reuseIdentifier]
                                                       forIndexPath:indexPath];
    LGWord *word = self.favorites[(NSUInteger)indexPath.row];
    cell.delegate = self;
    [cell configureWithWord:word favorite:[LGDataStore.sharedStore isFavorite:word]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.chain addObject:self.favorites[(NSUInteger)indexPath.row]];
    [self renderChain];
}

#pragma mark - LGWordCellDelegate

- (void)wordCellDidTapFavorite:(LGWordCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    [LGDataStore.sharedStore toggleFavorite:self.favorites[(NSUInteger)indexPath.row]];
}

@end
