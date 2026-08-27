#import <Foundation/Foundation.h>

@class LGWord;

NS_ASSUME_NONNULL_BEGIN

/// Speaks Greek through the system el-GR voice. No assets, works offline.
@interface LGSpeechService : NSObject

@property (class, nonatomic, readonly) LGSpeechService *sharedService;

/// Nouns are spoken in two stages — the bare word first, then the full
/// article+noun form after a beat — so learners hear the core word clearly
/// before the gendered form. Phrases are spoken once.
- (void)speakWord:(LGWord *)word;

/// Speaks arbitrary Greek text once (used by the sentence builder).
- (void)speakText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
