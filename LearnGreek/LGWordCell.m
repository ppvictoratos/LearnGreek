#import "LGWordCell.h"
#import "LGLanguageManager.h"
#import "LGThemeManager.h"
#import "LGWord.h"

@interface LGWordCell ()
@property (nonatomic, strong) UILabel *greekLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *favoriteButton;
@end

@implementation LGWordCell

+ (NSString *)reuseIdentifier {
    return @"LGWordCell";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _greekLabel = [[UILabel alloc] init];
        _detailLabel = [[UILabel alloc] init];

        _favoriteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _favoriteButton.accessibilityIdentifier = @"word.favoriteButton";
        [_favoriteButton addTarget:self
                            action:@selector(favoriteTapped)
                  forControlEvents:UIControlEventTouchUpInside];

        UIStackView *textStack =
            [[UIStackView alloc] initWithArrangedSubviews:@[ _greekLabel, _detailLabel ]];
        textStack.axis = UILayoutConstraintAxisVertical;
        textStack.spacing = 2;

        UIStackView *row =
            [[UIStackView alloc] initWithArrangedSubviews:@[ textStack, _favoriteButton ]];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.alignment = UIStackViewAlignmentCenter;
        row.spacing = 8;
        // Text stretches, star hugs — keeps every star on the trailing edge.
        [_favoriteButton setContentHuggingPriority:UILayoutPriorityRequired
                                           forAxis:UILayoutConstraintAxisHorizontal];
        [_favoriteButton setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                          forAxis:UILayoutConstraintAxisHorizontal];
        [textStack setContentHuggingPriority:UILayoutPriorityDefaultLow
                                     forAxis:UILayoutConstraintAxisHorizontal];
        row.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:row];
        [NSLayoutConstraint activateConstraints:@[
            [row.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [row.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [row.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_favoriteButton.widthAnchor constraintGreaterThanOrEqualToConstant:44],
            [_favoriteButton.heightAnchor constraintGreaterThanOrEqualToConstant:44],
        ]];
    }
    return self;
}

- (void)configureWithWord:(LGWord *)word favorite:(BOOL)favorite {
    LGThemeManager *theme = LGThemeManager.sharedManager;

    self.greekLabel.text = word.greek;
    NSString *translation =
        [word translationForLanguage:LGLanguageManager.sharedManager.languageCode];
    self.detailLabel.text =
        [NSString stringWithFormat:@"%@ · %@", word.transliteration, translation];

    self.greekLabel.font = [theme fontOfSize:20 weight:UIFontWeightSemibold];
    self.greekLabel.textColor = theme.primaryTextColor;
    self.detailLabel.font = [theme fontOfSize:14 weight:UIFontWeightRegular];
    self.detailLabel.textColor = theme.secondaryTextColor;
    self.backgroundColor = theme.backgroundColor;
    self.contentView.backgroundColor = theme.backgroundColor;

    UIImage *star = [UIImage systemImageNamed:(favorite ? @"star.fill" : @"star")];
    [self.favoriteButton setImage:star forState:UIControlStateNormal];
    self.favoriteButton.tintColor = theme.accentColor;
    self.favoriteButton.accessibilityValue = favorite ? @"favorited" : @"not favorited";

    self.accessibilityIdentifier = [NSString stringWithFormat:@"word.%@", word.wordID];
}

- (void)favoriteTapped {
    [self.delegate wordCellDidTapFavorite:self];
}

@end
