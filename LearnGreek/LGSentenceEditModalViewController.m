#import "LGSentenceEditModalViewController.h"
#import "LGSentence.h"
#import "LGThemeManager.h"
#import "LGDataStore.h"

@interface LGSentenceEditModalViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UICollectionView *iconCollectionView;
@property (nonatomic, copy) NSString *selectedIcon;
@end

@implementation LGSentenceEditModalViewController

- (instancetype)initWithSentence:(LGSentence *)sentence {
    self = [super init];
    if (self) {
        _sentence = sentence;
        _selectedIcon = sentence.iconSymbolName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Edit Sentence";
    self.view.backgroundColor = [LGThemeManager sharedManager].backgroundColor;

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(saveTapped)];
    self.navigationItem.rightBarButtonItem = saveButton;

    // Text field
    self.textField = [[UITextField alloc] init];
    self.textField.text = self.sentence.text;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.textField];
    [NSLayoutConstraint activateConstraints:@[
        [self.textField.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.textField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.textField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.textField.heightAnchor constraintEqualToConstant:44],
    ]];

    // Icon label
    UILabel *iconLabel = [[UILabel alloc] init];
    iconLabel.text = @"Icon:";
    iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:iconLabel];
    [NSLayoutConstraint activateConstraints:@[
        [iconLabel.topAnchor constraintEqualToAnchor:self.textField.bottomAnchor constant:20],
        [iconLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
    ]];

    // Icon collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 60);
    layout.minimumInteritemSpacing = 10;
    self.iconCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                  collectionViewLayout:layout];
    self.iconCollectionView.dataSource = self;
    self.iconCollectionView.delegate = self;
    [self.iconCollectionView registerClass:[UICollectionViewCell class]
              forCellWithReuseIdentifier:@"editIconCell"];
    self.iconCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.iconCollectionView];
    [NSLayoutConstraint activateConstraints:@[
        [self.iconCollectionView.topAnchor constraintEqualToAnchor:iconLabel.bottomAnchor constant:10],
        [self.iconCollectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.iconCollectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.iconCollectionView.heightAnchor constraintEqualToConstant:200],
    ]];

    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    deleteButton.tintColor = [UIColor systemRedColor];
    [deleteButton addTarget:self action:@selector(deleteTapped) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:deleteButton];
    [NSLayoutConstraint activateConstraints:@[
        [deleteButton.topAnchor constraintEqualToAnchor:self.iconCollectionView.bottomAnchor constant:20],
        [deleteButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
    ]];
}

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

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self availableIcons].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"editIconCell"
                                                                           forIndexPath:indexPath];
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }

    NSString *icon = [self availableIcons][indexPath.item];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:icon]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:imageView];
    [NSLayoutConstraint activateConstraints:@[
        [imageView.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [imageView.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [imageView.widthAnchor constraintEqualToConstant:40],
        [imageView.heightAnchor constraintEqualToConstant:40],
    ]];

    if ([self.selectedIcon isEqualToString:icon]) {
        cell.contentView.layer.borderWidth = 2;
        cell.contentView.layer.borderColor = [UIColor systemBlueColor].CGColor;
        cell.contentView.layer.cornerRadius = 8;
    } else {
        cell.contentView.layer.borderWidth = 0;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIcon = [self availableIcons][indexPath.item];
    [self.iconCollectionView reloadData];
}

- (void)saveTapped {
    self.sentence.text = self.textField.text;
    self.sentence.iconSymbolName = self.selectedIcon;
    [self checkAndCorrectSentence];
}

- (void)checkAndCorrectSentence {
    NSString *text = self.sentence.text;
    UITextChecker *checker = [[UITextChecker alloc] init];
    NSRange range = [checker rangeOfMisspelledWordInString:text range:NSMakeRange(0, text.length) startingAt:0 wrap:NO language:@"el"];

    if (range.location == NSNotFound) {
        [LGDataStore.sharedStore updateSentence:self.sentence];
        [self.delegate sentenceDidUpdate:self.sentence];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    NSString *misspelled = [text substringWithRange:range];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Grammar check"
                                                                   message:[NSString stringWithFormat:@"Misspelling detected: '%@'. Keep or edit?", misspelled]
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Keep original" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [LGDataStore.sharedStore updateSentence:self.sentence];
        [self.delegate sentenceDidUpdate:self.sentence];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        self.textField.text = text;
        [self.textField becomeFirstResponder];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteTapped {
    if (!self.sentence || !self.sentence.sentenceID) return;
    LGSentence *sentenceCopy = [[LGSentence alloc] initWithText:self.sentence.text iconSymbolName:self.sentence.iconSymbolName];
    sentenceCopy.sentenceID = self.sentence.sentenceID;

    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [LGDataStore.sharedStore deleteSentenceWithID:sentenceCopy];
        [self.delegate sentenceDidDelete:sentenceCopy];
    }];
}

@end
