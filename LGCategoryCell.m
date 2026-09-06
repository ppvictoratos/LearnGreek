#import "LGCategoryCell.h"
#import "LGThemeManager.h"

@interface LGCategoryCell ()
@property (nonatomic, strong) UIImageView *symbolView;
@property (nonatomic, strong) UILabel *greekLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@end

@implementation LGCategoryCell

+ (NSString *)reuseIdentifier {
    return @"LGCategoryCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 14;
        self.contentView.layer.borderWidth = 1;

        _symbolView = [[UIImageView alloc] init];
        _symbolView.contentMode = UIViewContentModeScaleAspectFit;
        _symbolView.translatesAutoresizingMaskIntoConstraints = NO;
        _symbolView.preferredSymbolConfiguration =
            [UIImageSymbolConfiguration configurationWithPointSize:28
                                                            weight:UIImageSymbolWeightMedium];

        _greekLabel = [[UILabel alloc] init];
        _greekLabel.adjustsFontSizeToFitWidth = NO;
        _greekLabel.numberOfLines = 1;

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.adjustsFontSizeToFitWidth = NO;
        _subtitleLabel.numberOfLines = 1;

        // Text stack (greek + subtitle)
        UIStackView *textStack = [[UIStackView alloc]
            initWithArrangedSubviews:@[ _greekLabel, _subtitleLabel ]];
        textStack.axis = UILayoutConstraintAxisVertical;
        textStack.alignment = UIStackViewAlignmentLeading;
        textStack.spacing = 2;
        textStack.translatesAutoresizingMaskIntoConstraints = NO;

        // Horizontal layout: icon (left) + text stack (right)
        UIStackView *horizontalStack = [[UIStackView alloc]
            initWithArrangedSubviews:@[ _symbolView, textStack ]];
        horizontalStack.axis = UILayoutConstraintAxisHorizontal;
        horizontalStack.alignment = UIStackViewAlignmentCenter;
        horizontalStack.spacing = 8;
        horizontalStack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:horizontalStack];

        [NSLayoutConstraint activateConstraints:@[
            [_symbolView.widthAnchor constraintEqualToConstant:40],
            [_symbolView.heightAnchor constraintEqualToConstant:40],
            [horizontalStack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10],
            [horizontalStack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10],
            [horizontalStack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:6],
            [horizontalStack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-6],
        ]];
    }
    return self;
}

- (void)configureWithSymbolName:(NSString *)symbolName
                     titleGreek:(NSString *)titleGreek
                       subtitle:(NSString *)subtitle {
    LGThemeManager *theme = LGThemeManager.sharedManager;
    self.symbolView.image = [UIImage systemImageNamed:symbolName];
    self.greekLabel.text = titleGreek;
    self.subtitleLabel.text = subtitle;

    self.greekLabel.font = [theme fontOfSize:14.5 weight:UIFontWeightSemibold];
    self.subtitleLabel.font = [theme fontOfSize:10.5 weight:UIFontWeightRegular];
    self.contentView.backgroundColor = theme.cellColor;

    // Special tint for star.fill (favorites) - EU gold color
    if ([symbolName isEqualToString:@"star.fill"]) {
        self.symbolView.tintColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0];
    } else if (theme.style == LGThemeStyleLight) {
        self.symbolView.tintColor = [UIColor whiteColor];
    } else {
        self.symbolView.tintColor = theme.accentColor;
    }

    if (theme.style == LGThemeStyleLight) {
        self.contentView.layer.borderColor = theme.cellColor.CGColor;
        self.greekLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75];
    } else {
        self.contentView.layer.borderColor = theme.accentColor.CGColor;
        self.greekLabel.textColor = theme.accentColor;
        self.subtitleLabel.textColor = theme.secondaryTextColor;
    }
}

@end
