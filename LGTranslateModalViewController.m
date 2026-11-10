#import "LGTranslateModalViewController.h"
#import "LGTranslationService.h"
#import "LGSpeechService.h"
#import "LGThemeManager.h"
#import "LGDataStore.h"
#import "LGSentence.h"

@interface LGTranslateModalViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *translateButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, copy) NSString *translatedText;
@end

@implementation LGTranslateModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Translate";
    self.view.backgroundColor = [LGThemeManager sharedManager].backgroundColor;

    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(dismiss)];

    [self buildLayout];
}

- (void)buildLayout {
    LGThemeManager *theme = [LGThemeManager sharedManager];

    self.inputField = [[UITextField alloc] init];
    self.inputField.placeholder = @"What do you want to say?";
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputField.returnKeyType = UIReturnKeyGo;
    self.inputField.delegate = self;
    self.inputField.accessibilityIdentifier = @"translate.input";

    self.translateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.translateButton setTitle:@"Translate →" forState:UIControlStateNormal];
    self.translateButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.translateButton.tintColor = theme.accentColor;
    self.translateButton.accessibilityIdentifier = @"translate.go";
    [self.translateButton addTarget:self action:@selector(runTranslation) forControlEvents:UIControlEventTouchUpInside];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.hidesWhenStopped = YES;

    self.resultLabel = [[UILabel alloc] init];
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightLight];
    self.resultLabel.textColor = theme.primaryTextColor;
    self.resultLabel.accessibilityIdentifier = @"translate.result";

    self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"] forState:UIControlStateNormal];
    self.playButton.tintColor = theme.accentColor;
    self.playButton.hidden = YES;
    self.playButton.accessibilityIdentifier = @"translate.play";
    [self.playButton addTarget:self action:@selector(playResult) forControlEvents:UIControlEventTouchUpInside];

    self.saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.saveButton setTitle:@"Save as sentence" forState:UIControlStateNormal];
    self.saveButton.tintColor = theme.accentColor;
    self.saveButton.hidden = YES;
    self.saveButton.accessibilityIdentifier = @"translate.save";
    [self.saveButton addTarget:self action:@selector(saveResult) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *actionRow = [[UIStackView alloc]
        initWithArrangedSubviews:@[ self.playButton, self.saveButton ]];
    actionRow.axis = UILayoutConstraintAxisHorizontal;
    actionRow.spacing = 24;
    actionRow.alignment = UIStackViewAlignmentCenter;

    UIStackView *stack = [[UIStackView alloc]
        initWithArrangedSubviews:@[ self.inputField, self.translateButton, self.spinner, self.resultLabel, actionRow ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 20;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stack];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:safe.topAnchor constant:32],
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
        [self.inputField.widthAnchor constraintEqualToAnchor:stack.widthAnchor],
    ]];
}

#pragma mark - Actions

- (void)runTranslation {
    NSString *phrase = self.inputField.text;
    if (!phrase.length) return;

    [self.inputField resignFirstResponder];
    self.resultLabel.text = nil;
    self.playButton.hidden = YES;
    self.saveButton.hidden = YES;
    [self.spinner startAnimating];
    self.translateButton.enabled = NO;

    [[LGTranslationService sharedService] translatePhrase:phrase
                                               completion:^(NSString *translation, NSError *error) {
        [self.spinner stopAnimating];
        self.translateButton.enabled = YES;

        if (error || !translation) {
            self.resultLabel.text = @"Couldn't translate — check your connection.";
            self.resultLabel.textColor = [UIColor systemRedColor];
            return;
        }

        self.translatedText = translation;
        self.resultLabel.text = translation;
        self.resultLabel.textColor = [LGThemeManager sharedManager].primaryTextColor;
        self.playButton.hidden = NO;
        self.saveButton.hidden = NO;
    }];
}

- (void)playResult {
    if (self.translatedText) {
        [[LGSpeechService sharedService] speakText:self.translatedText];
    }
}

- (void)saveResult {
    if (!self.translatedText) return;

    LGSentence *sentence = [[LGSentence alloc] initWithText:self.translatedText
                                             iconSymbolName:@"character.bubble"];
    sentence.translation = self.inputField.text;
    [LGDataStore.sharedStore addSentence:sentence];

    if ([self.delegate respondsToSelector:@selector(translateModalDidSave:)]) {
        [self.delegate translateModalDidSave:self.translatedText];
    }
    [self dismiss];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self runTranslation];
    return NO;
}

@end
