#import <UIKit/UIKit.h>

@class LGSentence;

NS_ASSUME_NONNULL_BEGIN

/// Fullscreen, read-only presentation of a saved sentence: the Greek text
/// large and fitted to the screen, with its phonetic pronunciation guide
/// underneath in a smaller, lighter font.
@interface LGSentenceDetailViewController : UIViewController

- (instancetype)initWithSentence:(LGSentence *)sentence;

@end

NS_ASSUME_NONNULL_END
