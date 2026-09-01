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
            @"en" : @"Give yourself a schedule, then practice out loud.\n\n"
                    @"Tap a word to hear it. Star the ones worth keeping — the small grey "
                    @"word in front is its article, which tells you the gender.\n\n"
                    @"In Προτάσεις, tap your starred words to chain them into a sentence. "
                    @"Play it, then tap the bookmark to save it. Saved sentences stay put — "
                    @"tap one to hear it again, swipe to delete.",
            @"es" : @"Date un horario y practica en voz alta.\n\n"
                    @"Toca una palabra para escucharla. Marca las que valga la pena guardar; "
                    @"la palabrita gris de delante es su artículo, que indica el género.\n\n"
                    @"En Προτάσεις, toca tus palabras marcadas para encadenarlas en una frase. "
                    @"Reprodúcela y toca el marcador para guardarla. Las frases guardadas se "
                    @"quedan: tócalas para oírlas, deslízalas para borrarlas.",
            @"it" : @"Datti un programma, poi esercitati ad alta voce.\n\n"
                    @"Tocca una parola per ascoltarla. Aggiungi la stella a quelle da tenere; "
                    @"la paroletta grigia davanti è l'articolo, che indica il genere.\n\n"
                    @"In Προτάσεις, tocca le parole preferite per concatenarle in una frase. "
                    @"Riproducila, poi tocca il segnalibro per salvarla. Le frasi salvate "
                    @"restano: toccale per riascoltarle, scorri per eliminarle.",
            @"fr" : @"Donne-toi un emploi du temps, puis pratique à voix haute.\n\n"
                    @"Touche un mot pour l'entendre. Étoile ceux qui valent la peine ; le petit "
                    @"mot gris devant est son article, qui indique le genre.\n\n"
                    @"Dans Προτάσεις, touche tes mots étoilés pour les enchaîner en une phrase. "
                    @"Écoute-la, puis touche le signet pour l'enregistrer. Les phrases "
                    @"enregistrées restent : touche pour réécouter, glisse pour supprimer.",
            @"yue" : @"為自己定個時間表，然後大聲練習。\n\n"
                     @"撳個字就聽到讀音。想留住嘅就撳星——前面嗰個細細灰色字係冠詞，"
                     @"話你知個字嘅性別。\n\n"
                     @"喺 Προτάσεις 度，撳你加咗星嘅字，就可以串成一句。撳播放聽吓，"
                     @"再撳書籤儲起。儲低嘅句子會留喺度：撳一下再聽，掃走就刪除。",
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
            @"en" : @"We love beauty with simplicity. — Pericles",
            @"es" : @"Amamos la belleza con sencillez. — Pericles",
            @"it" : @"Amiamo la bellezza con semplicità. — Pericle",
            @"fr" : @"Nous aimons la beauté avec simplicité. — Périclès",
            @"yue" : @"我哋愛美，而不奢華。— 伯里克利",
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
    // Pericles' funeral oration (Thucydides 2.40) — a fitting line for an app
    // that is deliberately plain.
    self.quoteLabel.text = @"Φιλοκαλοῦμεν μετ' εὐτελείας";
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
