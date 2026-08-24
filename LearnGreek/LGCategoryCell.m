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
        _symbolView.preferredSymbolConfiguration =
            [UIImageSymbolConfiguration configurationWithPointSize:22
                                                            weight:UIImageSymbolWeightMedium];

        _greekLabel = [[UILabel alloc] init];
        _greekLabel.adjustsFontSizeToFitWidth = YES;
        _greekLabel.minimumScaleFactor = 0.6;

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.adjustsFontSizeToFitWidth = YES;
        _subtitleLabel.minimumScaleFactor = 0.6;

        UIStackView *stack = [[UIStackView alloc]
            initWithArrangedSubviews:@[ _symbolView, _greekLabel, _subtitleLabel ]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.spacing = 3;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:stack];
        [NSLayoutConstraint activateConstraints:@[
            [stack.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
            [stack.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor
                                                             constant:6],
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

    self.greekLabel.font = [theme fontOfSize:15 weight:UIFontWeightSemibold];
    self.subtitleLabel.font = [theme fontOfSize:11 weight:UIFontWeightRegular];
    self.contentView.backgroundColor = theme.cellColor;

    if (theme.style == LGThemeStyleLight) {
        self.contentView.layer.borderColor = theme.cellColor.CGColor;
        self.symbolView.tintColor = [UIColor whiteColor];
        self.greekLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75];
    } else {
        self.contentView.layer.borderColor = theme.accentColor.CGColor;
        self.symbolView.tintColor = theme.accentColor;
        self.greekLabel.textColor = theme.accentColor;
        self.subtitleLabel.textColor = theme.secondaryTextColor;
    }
}

@end
