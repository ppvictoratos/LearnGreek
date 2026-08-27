#import "LGInfoViewController.h"
#import "LGLanguageManager.h"
#import "LGThemeManager.h"

@interface LGInfoViewController ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *blurbLabel;
@property (nonatomic, strong) UILabel *builtLabel;
@property (nonatomic, strong) UILabel *quoteLabel;
@property (nonatomic, strong) UILabel *quoteTranslationLabel;
@end

@implementation LGInfoViewController

+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)localizedStrings {
    return @{
        @"blurb" : @{
            @"en" : @"Create a schedule for yourself, then start building sentences to repeat "
                    @"out loud. Tap a word to hear it — the bare word first, then with its "
                    @"article. Star the words you want to keep close.",
            @"es" : @"Crea un horario para ti y luego empieza a construir frases para repetir "
                    @"en voz alta. Toca una palabra para escucharla: primero sola, luego con su "
                    @"artículo. Marca con estrella las que quieras tener cerca.",
            @"it" : @"Creati un programma e poi inizia a costruire frasi da ripetere ad alta "
                    @"voce. Tocca una parola per ascoltarla: prima da sola, poi con il suo "
                    @"articolo. Segna con la stella quelle da tenere vicine.",
            @"fr" : @"Crée-toi un emploi du temps, puis commence à construire des phrases à "
                    @"répéter à voix haute. Touche un mot pour l'entendre : d'abord seul, puis "
                    @"avec son article. Étoile ceux que tu veux garder près de toi.",
            @"yue" : @"為自己定一個時間表，然後開始砌句子，大聲重複講。撳一個字就聽到讀音——"
                     @"先淨係個字，再連埋冠詞。想留住嘅字就撳星。",
        },
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
    self.title = @"Βοήθεια";

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = @"LearnGreek";
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.accessibilityIdentifier = @"credits.name";

    self.blurbLabel = [[UILabel alloc] init];
    self.blurbLabel.text = [[self class] string:@"blurb"];
    self.blurbLabel.numberOfLines = 0;
    self.blurbLabel.textAlignment = NSTextAlignmentCenter;
    self.blurbLabel.accessibilityIdentifier = @"info.blurb";

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
        self.nameLabel, self.blurbLabel, self.builtLabel, self.quoteLabel,
        self.quoteTranslationLabel
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
    self.blurbLabel.textColor = theme.primaryTextColor;
    self.blurbLabel.font = [theme fontOfSize:15 weight:UIFontWeightRegular];
    self.builtLabel.textColor = theme.secondaryTextColor;
    self.builtLabel.font = [theme fontOfSize:15 weight:UIFontWeightRegular];
    self.quoteLabel.textColor = theme.accentColor;
    self.quoteLabel.font = [theme fontOfSize:20 weight:UIFontWeightSemibold];
    self.quoteTranslationLabel.textColor = theme.secondaryTextColor;
    self.quoteTranslationLabel.font = [theme fontOfSize:14 weight:UIFontWeightRegular];
}

@end
