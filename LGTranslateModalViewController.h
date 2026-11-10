#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LGTranslateDelegate <NSObject>
/// Called when the user saves the translated Greek text as a sentence.
- (void)translateModalDidSave:(NSString *)greekText;
@end

/// Text field → MyMemory translation → hear it → save as a sentence.
@interface LGTranslateModalViewController : UIViewController

@property (nonatomic, weak) id<LGTranslateDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
