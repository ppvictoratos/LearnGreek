#import <Foundation/Foundation.h>

@class LGWord;

NS_ASSUME_NONNULL_BEGIN

/// Speaks Greek through the system el-GR voice. No assets, works offline.
@interface LGSpeechService : NSObject

@property (class, nonatomic, readonly) LGSpeechService *sharedService;

/// Speaks the bare word only — never the definite article. The article is
/// taught visually (small and dimmed in the list); hearing it read aloud just
/// obscures which sound is the word itself.
- (void)speakWord:(LGWord *)word;

/// Speaks arbitrary Greek text once (used by the sentence builder).
- (void)speakText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
