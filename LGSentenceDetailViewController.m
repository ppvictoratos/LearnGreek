#import "LGSentenceDetailViewController.h"
#import "LGSentence.h"
#import "LGThemeManager.h"

@interface LGSentenceDetailViewController ()
@property (nonatomic, strong) LGSentence *sentence;
@end

@implementation LGSentenceDetailViewController

- (instancetype)initWithSentence:(LGSentence *)sentence {
    self = [super init];
    if (self) {
        _sentence = sentence;
        self.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    LGThemeManager *theme = LGThemeManager.sharedManager;
    self.view.backgroundColor = theme.backgroundColor;

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 16;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];

    UILabel *sentenceLabel = [[UILabel alloc] init];
    sentenceLabel.text = self.sentence.text;
    sentenceLabel.textColor = theme.primaryTextColor;
    sentenceLabel.font = [theme fontOfSize:36 weight:UIFontWeightBold];
    sentenceLabel.textAlignment = NSTextAlignmentCenter;
    sentenceLabel.numberOfLines = 0;
    sentenceLabel.adjustsFontSizeToFitWidth = YES;
    sentenceLabel.minimumScaleFactor = 0.35;
    [stack addArrangedSubview:sentenceLabel];

    if (self.sentence.phonetic.length > 0) {
        UILabel *phoneticLabel = [[UILabel alloc] init];
        phoneticLabel.text = self.sentence.phonetic;
        phoneticLabel.textColor = theme.secondaryTextColor;
        phoneticLabel.font = [theme fontOfSize:18 weight:UIFontWeightRegular];
        phoneticLabel.textAlignment = NSTextAlignmentCenter;
        phoneticLabel.numberOfLines = 0;
        [stack addArrangedSubview:phoneticLabel];
    }

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
    ]];
}

@end
