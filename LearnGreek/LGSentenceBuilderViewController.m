#import "LGSentenceBuilderViewController.h"
#import "LGDataStore.h"
#import "LGLanguageManager.h"
#import "LGSpeechService.h"
#import "LGThemeManager.h"
#import "LGWord.h"
#import "LGWordCell.h"
#import "LGSentence.h"

static NSInteger const LGSectionSaved = 0;
static NSInteger const LGSectionFavorites = 1;

static NSString *const LGSavedSentenceCellID = @"LGSavedSentenceCell";

@interface LGSentenceBuilderViewController () <UITableViewDataSource, UITableViewDelegate,
                                               UICollectionViewDataSource, UICollectionViewDelegate,
                                               LGWordCellDelegate>
@property (nonatomic, copy) NSArray<LGWord *> *favorites;
@property (nonatomic, copy) NSArray<NSString *> *saved;
@property (nonatomic, copy) NSArray<LGSentence *> *savedSentences;
@property (nonatomic, strong) NSMutableArray<LGWord *> *chain;
@property (nonatomic, strong) UILabel *sentenceLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *iconCollectionView;
@property (nonatomic, copy) NSString *selectedIcon;
@end

@implementation LGSentenceBuilderViewController

+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)localizedStrings {
    return @{
        @"hint" : @{
            @"en" : @"Tap favorites to chain them. Play to hear it, bookmark to save it.",
            @"es" : @"Toca favoritos para encadenarlos. Reproduce para oírlo, guarda con el marcador.",
            @"it" : @"Tocca i preferiti per concatenarli. Riproduci per ascoltare, salva col segnalibro.",
            @"fr" : @"Touche tes favoris pour les enchaîner. Écoute, puis garde avec le signet.",
            @"yue" : @"撳最愛字串埋一齊。撳播放聽，撳書籤儲起。",
        },
        @"savedHeader" : @{
            @"en" : @"Saved sentences", @"es" : @"Frases guardadas", @"it" : @"Frasi salvate",
            @"fr" : @"Phrases enregistrées", @"yue" : @"已儲句子",
        },
        @"favoritesHeader" : @{
            @"en" : @"Your favorites", @"es" : @"Tus favoritos", @"it" : @"I tuoi preferiti",
            @"fr" : @"Tes favoris", @"yue" : @"你嘅最愛",
        },
        @"noFavorites" : @{
            @"en" : @"Star words in any category to use them here.",
            @"es" : @"Marca palabras en cualquier categoría para usarlas aquí.",
            @"it" : @"Aggiungi preferiti da qualsiasi categoria per usarli qui.",
            @"fr" : @"Étoile des mots dans n'importe quelle catégorie pour les utiliser ici.",
            @"yue" : @"喺任何分類撳星，啲字就會喺呢度出現。",
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

    self.saveButton = [self buttonWithSymbol:@"bookmark.circle.fill"
                                  identifier:@"sentence.save"
                                      action:@selector(saveChain)];
    self.playButton = [self buttonWithSymbol:@"play.circle.fill"
                                  identifier:@"sentence.play"
                                      action:@selector(playChain)];
    self.clearButton = [self buttonWithSymbol:@"trash.circle"
                                   identifier:@"sentence.clear"
                                       action:@selector(clearChain)];

    UIStackView *buttons = [[UIStackView alloc]
        initWithArrangedSubviews:@[ self.playButton, self.saveButton, self.clearButton ]];
    buttons.axis = UILayoutConstraintAxisHorizontal;
    buttons.distribution = UIStackViewDistributionFillEqually;

    self.hintLabel = [[UILabel alloc] init];
    self.hintLabel.text = [[self class] string:@"hint"];
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.accessibilityIdentifier = @"sentence.hint";

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64;
    self.tableView.accessibilityIdentifier = @"sentence.table";
    [self.tableView registerClass:[LGWordCell class]
           forCellReuseIdentifier:[LGWordCell reuseIdentifier]];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:LGSavedSentenceCellID];

    UIStackView *layout = [[UIStackView alloc]
        initWithArrangedSubviews:@[ self.sentenceLabel, buttons, self.hintLabel, self.tableView ]];
    layout.axis = UILayoutConstraintAxisVertical;
    layout.spacing = 10;
    layout.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:layout];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [layout.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [layout.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [layout.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],
        [layout.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    [self reloadData];
    [self renderChain];
    [self applyTheme];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(reloadData)
                   name:LGFavoritesDidChangeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(reloadData)
                   name:LGSentencesDidChangeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(applyTheme)
                   name:LGThemeDidChangeNotification
                 object:nil];
}

- (UIButton *)buttonWithSymbol:(NSString *)symbol
                    identifier:(NSString *)identifier
                        action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:[UIImage systemImageNamed:symbol] forState:UIControlStateNormal];
    button.accessibilityIdentifier = identifier;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    return button;
}

- (void)reloadData {
    self.favorites = LGDataStore.sharedStore.favoriteWords;
    self.saved = LGDataStore.sharedStore.savedSentences;
    self.savedSentences = LGDataStore.sharedStore.savedSentencesWithIcons;
    [self.tableView reloadData];
}

#pragma mark - Chain

- (NSString *)chainText {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    for (LGWord *word in self.chain) {
        [parts addObject:word.fullPhrase];
    }
    return [parts componentsJoinedByString:@" "];
}

- (void)renderChain {
    BOOL hasWords = self.chain.count > 0;
    self.sentenceLabel.text = hasWords ? [self chainText] : @"…";
    self.playButton.enabled = hasWords;
    self.saveButton.enabled = hasWords;
    self.clearButton.enabled = hasWords;
}

- (void)playChain {
    [LGSpeechService.sharedService speakText:[self chainText]];
}

- (void)saveChain {
    if (self.chain.count == 0) return;
    self.selectedIcon = @"ellipsis.bubble";
    [self showIconPicker];
}

- (void)saveChainWithIcon:(NSString *)icon {
    LGSentence *sentence = [[LGSentence alloc] initWithText:[self chainText]
                                              iconSymbolName:icon];
    [LGDataStore.sharedStore addSentence:sentence];
    [self clearChain];
    [self reloadData];
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
    self.saveButton.tintColor = theme.accentColor;
    self.clearButton.tintColor = theme.secondaryTextColor;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == LGSectionSaved ? (NSInteger)self.savedSentences.count
                                     : (NSInteger)self.favorites.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == LGSectionSaved) {
        return self.savedSentences.count > 0 ? [[self class] string:@"savedHeader"] : nil;
    }
    return self.favorites.count > 0 ? [[self class] string:@"favoritesHeader"]
                                    : [[self class] string:@"noFavorites"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LGThemeManager *theme = LGThemeManager.sharedManager;

    if (indexPath.section == LGSectionSaved) {
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:LGSavedSentenceCellID
                                            forIndexPath:indexPath];
        LGSentence *sentence = self.savedSentences[(NSUInteger)indexPath.row];
        cell.textLabel.text = sentence.text;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [theme fontOfSize:17 weight:UIFontWeightRegular];
        cell.textLabel.textColor = theme.primaryTextColor;
        cell.imageView.image = [UIImage systemImageNamed:sentence.iconSymbolName];
        cell.imageView.tintColor = theme.accentColor;
        cell.backgroundColor = theme.backgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessibilityIdentifier = @"sentence.saved";

        // Add tap gesture to play
        for (UIGestureRecognizer *g in cell.gestureRecognizers) {
            [cell removeGestureRecognizer:g];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(sentenceTapped:)];
        [cell addGestureRecognizer:tap];

        // Add swipe gesture to edit
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]
            initWithTarget:self action:@selector(sentenceSwiped:)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [cell addGestureRecognizer:swipe];

        return cell;
    }

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
    if (indexPath.section == LGSectionSaved) {
        [LGSpeechService.sharedService speakText:self.saved[(NSUInteger)indexPath.row]];
        return;
    }
    [self.chain addObject:self.favorites[(NSUInteger)indexPath.row]];
    [self renderChain];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == LGSectionSaved;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [LGDataStore.sharedStore deleteSentence:self.saved[(NSUInteger)indexPath.row]];
    }
}

#pragma mark - LGWordCellDelegate

- (void)wordCellDidTapFavorite:(LGWordCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath || indexPath.section != LGSectionFavorites) {
        return;
    }
    [LGDataStore.sharedStore toggleFavorite:self.favorites[(NSUInteger)indexPath.row]];
}

#pragma mark - Icon Picker

- (NSArray<NSString *> *)availableIcons {
    return @[@"ellipsis.bubble", @"star.fill", @"heart.fill", @"bookmark.fill",
             @"lightbulb.fill", @"checkmark.circle.fill", @"exclamationmark.circle.fill",
             @"info.circle.fill", @"wand.and.stars", @"hand.thumbsup.fill",
             @"face.smiling.fill", @"sparkles", @"flame.fill", @"sun.max.fill",
             @"moon.fill", @"cloud.fill", @"tree.fill", @"leaf.fill",
             @"drop.fill", @"hourglass", @"hare.fill", @"tortoise.fill",
             @"bird.fill", @"fish.fill", @"key.fill", @"ant.fill",
             @"ladybug.fill", @"person.fill", @"hand.wave.fill", @"gift.fill",
             @"phone.fill", @"car.fill"];
}

- (void)showIconPicker {
    UIViewController *container = [[UIViewController alloc] init];
    container.modalPresentationStyle = UIModalPresentationFormSheet;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(70, 70);
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

    self.iconCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                  collectionViewLayout:layout];
    self.iconCollectionView.dataSource = self;
    self.iconCollectionView.delegate = self;
    self.iconCollectionView.backgroundColor = [LGThemeManager sharedManager].backgroundColor;
    [self.iconCollectionView registerClass:[UICollectionViewCell class]
              forCellWithReuseIdentifier:@"iconCell"];
    self.iconCollectionView.translatesAutoresizingMaskIntoConstraints = NO;

    [container.view addSubview:self.iconCollectionView];
    [NSLayoutConstraint activateConstraints:@[
        [self.iconCollectionView.topAnchor constraintEqualToAnchor:container.view.safeAreaLayoutGuide.topAnchor],
        [self.iconCollectionView.leadingAnchor constraintEqualToAnchor:container.view.leadingAnchor],
        [self.iconCollectionView.trailingAnchor constraintEqualToAnchor:container.view.trailingAnchor],
        [self.iconCollectionView.bottomAnchor constraintEqualToAnchor:container.view.bottomAnchor],
    ]];

    [self presentViewController:container animated:YES completion:nil];
}

- (void)iconPickerDone {
    [self dismissViewControllerAnimated:YES completion:^{
        [self saveChainWithIcon:self.selectedIcon];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self availableIcons].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"iconCell"
                                                                           forIndexPath:indexPath];
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }

    NSString *icon = [self availableIcons][indexPath.item];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:icon]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tintColor = [LGThemeManager sharedManager].accentColor;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:imageView];
    [NSLayoutConstraint activateConstraints:@[
        [imageView.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [imageView.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [imageView.widthAnchor constraintEqualToConstant:45],
        [imageView.heightAnchor constraintEqualToConstant:45],
    ]];

    cell.contentView.layer.cornerRadius = 8;
    if ([self.selectedIcon isEqualToString:icon]) {
        cell.contentView.layer.borderWidth = 3;
        cell.contentView.layer.borderColor = [UIColor systemBlueColor].CGColor;
        cell.contentView.backgroundColor = [LGThemeManager sharedManager].accentColor;
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.1];
    } else {
        cell.contentView.layer.borderWidth = 0;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIcon = [self availableIcons][indexPath.item];
    [self dismissViewControllerAnimated:YES completion:^{
        [self saveChainWithIcon:self.selectedIcon];
    }];
}

#pragma mark - Sentence Interactions

- (void)sentenceTapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (indexPath && indexPath.section == LGSectionSaved) {
        LGSentence *sentence = self.savedSentences[(NSUInteger)indexPath.row];
        [LGSpeechService.sharedService speakText:sentence.text];
    }
}

- (void)sentenceSwiped:(UISwipeGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateRecognized) return;
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (indexPath && indexPath.section == LGSectionSaved && indexPath.row < (NSInteger)self.savedSentences.count) {
        LGSentence *sentence = self.savedSentences[(NSUInteger)indexPath.row];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete sentence?" message:sentence.text preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [LGDataStore.sharedStore deleteSentenceWithID:sentence];
            [self reloadData];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
