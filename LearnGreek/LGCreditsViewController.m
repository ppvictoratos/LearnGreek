#import "LGCreditsViewController.h"
#import "LGLanguageManager.h"
#import "LGThemeManager.h"

@interface LGCreditsViewController ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *builtLabel;
@property (nonatomic, strong) UILabel *quoteLabel;
@property (nonatomic, strong) UILabel *quoteTranslationLabel;
@end

@implementation LGCreditsViewController

+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)localizedStrings {
    return @{
        @"built" : @{
            @"en" : @"Built with Objective-C and UIKit.\nNo ads. No tracking. No dependencies.\n"
                    @"Made by an independent developer learning Greek.",
            @"es" : @"Hecha con Objective-C y UIKit.\nSin anuncios. Sin rastreo. Sin dependencias.\n"
                    @"Creada por un desarrollador independiente que aprende griego.",
            @"it" : @"Costruita con Objective-C e UIKit.\nSenza pubblicità. Senza tracciamento. "
                    @"Senza dipendenze.\nCreata da uno sviluppatore indipendente che impara il greco.",
            @"fr" : @"Construite avec Objective-C et UIKit.\nSans publicité. Sans traçage. Sans "
                    @"dépendances.\nCréée par un développeur indépendant qui apprend le grec.",
            @"yue" : @"用 Objective-C 同 UIKit 打造。\n冇廣告。冇追蹤。冇依賴。\n"
                     @"由一位學緊希臘文嘅獨立開發者製作。",
        },
        @"quoteTranslation" : @{
            @"en" : @"“I was given the Greek language.” — Odysseas Elytis",
            @"es" : @"“Me dieron la lengua griega.” — Odiseas Elitis",
            @"it" : @"“Mi è stata data la lingua greca.” — Odisseas Elitis",
            @"fr" : @"“On m'a donné la langue grecque.” — Odysséas Elýtis",
            @"yue" : @"「我獲賜希臘語。」— 奧德修斯·埃利蒂斯",
        },
    };
}

+ (NSString *)string:(NSString *)key {
    NSDictionary *entry = [self localizedStrings][key];
    return entry[LGLanguageManager.sharedManager.languageCode] ?: entry[@"en"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Σχετικά";

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = @"LearnGreek";
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.accessibilityIdentifier = @"credits.name";

    self.builtLabel = [[UILabel alloc] init];
    self.builtLabel.text = [[self class] string:@"built"];
    self.builtLabel.numberOfLines = 0;
    self.builtLabel.textAlignment = NSTextAlignmentCenter;
    self.builtLabel.accessibilityIdentifier = @"credits.built";

    self.quoteLabel = [[UILabel alloc] init];
    self.quoteLabel.text = @"«Τη γλώσσα μού έδωσαν ελληνική»";
    self.quoteLabel.numberOfLines = 0;
    self.quoteLabel.textAlignment = NSTextAlignmentCenter;
    self.quoteLabel.accessibilityIdentifier = @"credits.quote";

    self.quoteTranslationLabel = [[UILabel alloc] init];
    self.quoteTranslationLabel.text = [[self class] string:@"quoteTranslation"];
    self.quoteTranslationLabel.numberOfLines = 0;
    self.quoteTranslationLabel.textAlignment = NSTextAlignmentCenter;
    self.quoteTranslationLabel.accessibilityIdentifier = @"credits.quoteTranslation";

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.nameLabel, self.builtLabel, self.quoteLabel, self.quoteTranslationLabel
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 24;
    [stack setCustomSpacing:48 afterView:self.builtLabel];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:28],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-28],
    ]];

    [self applyTheme];
}

- (void)applyTheme {
    LGThemeManager *theme = LGThemeManager.sharedManager;
    self.view.backgroundColor = theme.backgroundColor;
    self.nameLabel.textColor = theme.primaryTextColor;
    self.nameLabel.font = [theme fontOfSize:28 weight:UIFontWeightBold];
    self.builtLabel.textColor = theme.secondaryTextColor;
    self.builtLabel.font = [theme fontOfSize:15 weight:UIFontWeightRegular];
    self.quoteLabel.textColor = theme.accentColor;
    self.quoteLabel.font = [theme fontOfSize:20 weight:UIFontWeightSemibold];
    self.quoteTranslationLabel.textColor = theme.secondaryTextColor;
    self.quoteTranslationLabel.font = [theme fontOfSize:14 weight:UIFontWeightRegular];
}

@end
