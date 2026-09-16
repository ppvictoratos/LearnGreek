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

// Keyed by SF Symbol name so each home-grid tile reads as its own category
// rather than a wall of same-colored icons.
+ (NSDictionary<NSString *, UIColor *> *)iconPalette {
    static NSDictionary<NSString *, UIColor *> *palette;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        palette = @{
            @"star.fill" : [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0],
            @"wand.and.stars" : [UIColor colorWithRed:1.0 green:0.1 blue:0.6 alpha:1.0],
            @"hand.wave.fill" : [UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:1.0],
            @"bubble.left.and.bubble.right.fill" : [UIColor colorWithRed:0.0 green:0.78 blue:0.85 alpha:1.0],
            @"bolt.fill" : [UIColor colorWithRed:1.0 green:0.65 blue:0.0 alpha:1.0],
            @"moon.stars.fill" : [UIColor colorWithRed:0.45 green:0.4 blue:0.9 alpha:1.0],
            @"bus.fill" : [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0],
            @"sportscourt.fill" : [UIColor colorWithRed:0.3 green:0.85 blue:0.4 alpha:1.0],
            @"fork.knife" : [UIColor colorWithRed:0.95 green:0.35 blue:0.2 alpha:1.0],
            @"number" : [UIColor colorWithRed:0.55 green:0.6 blue:0.66 alpha:1.0],
            @"paintpalette.fill" : [UIColor colorWithRed:0.75 green:0.25 blue:0.8 alpha:1.0],
            @"clock.fill" : [UIColor colorWithRed:0.7 green:0.5 blue:0.25 alpha:1.0],
            @"house.fill" : [UIColor colorWithRed:0.95 green:0.5 blue:0.6 alpha:1.0],
            @"leaf.fill" : [UIColor colorWithRed:0.15 green:0.55 blue:0.25 alpha:1.0],
            @"pawprint.fill" : [UIColor colorWithRed:0.6 green:0.4 blue:0.22 alpha:1.0],
            @"cross.case.fill" : [UIColor colorWithRed:0.9 green:0.15 blue:0.15 alpha:1.0],
            @"link" : [UIColor colorWithRed:0.25 green:0.6 blue:0.65 alpha:1.0],
        };
    });
    return palette;
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

    // The theme toggle deliberately contrasts with the *current* theme rather
    // than matching its own accent, so it always stands out from the grid.
    if ([symbolName isEqualToString:@"circle.lefthalf.filled"]) {
        self.symbolView.tintColor = theme.style == LGThemeStyleLight
            ? [UIColor colorWithRed:0.0 green:0.65 blue:0.3 alpha:1.0]
            : [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
    } else {
        // Every other tile gets a deliberate color from the palette below, so
        // the grid doesn't read as "a few special icons + a wall of flat white/green".
        UIColor *paletteTint = [[self class] iconPalette][symbolName];
        if (paletteTint) {
            self.symbolView.tintColor = paletteTint;
        } else if (theme.style == LGThemeStyleLight) {
            self.symbolView.tintColor = [UIColor whiteColor];
        } else {
            self.symbolView.tintColor = theme.accentColor;
        }
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
