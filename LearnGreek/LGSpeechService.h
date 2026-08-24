#import <Foundation/Foundation.h>

@class LGWord;

NS_ASSUME_NONNULL_BEGIN

/// Speaks Greek words through the system el-GR voice. No assets, works offline.
@interface LGSpeechService : NSObject

@property (class, nonatomic, readonly) LGSpeechService *sharedService;

- (void)speakWord:(LGWord *)word;

@end

NS_ASSUME_NONNULL_END
