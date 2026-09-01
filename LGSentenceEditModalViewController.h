#import <UIKit/UIKit.h>

@class LGSentence;

@protocol LGSentenceEditDelegate <NSObject>
- (void)sentenceDidUpdate:(LGSentence *)sentence;
- (void)sentenceDidDelete:(LGSentence *)sentence;
@end

@interface LGSentenceEditModalViewController : UIViewController
@property (nonatomic, weak) id<LGSentenceEditDelegate> delegate;
@property (nonatomic, strong) LGSentence *sentence;
- (instancetype)initWithSentence:(LGSentence *)sentence;
@end
