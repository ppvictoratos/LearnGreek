#import "LGSpeechService.h"
#import "LGWord.h"
#import <AVFoundation/AVFoundation.h>

@interface LGSpeechService ()
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@end

@implementation LGSpeechService

+ (LGSpeechService *)sharedService {
    static LGSpeechService *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[LGSpeechService alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return self;
}

- (AVSpeechUtterance *)utteranceForText:(NSString *)text {
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"el-GR"];
    utterance.rate = 0.45;
    return utterance;
}

- (void)stopSpeaking {
    if (self.synthesizer.isSpeaking) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

- (void)speakWord:(LGWord *)word {
    [self stopSpeaking];
    [self.synthesizer speakUtterance:[self utteranceForText:word.greek]];
}

- (void)speakText:(NSString *)text {
    [self stopSpeaking];
    [self.synthesizer speakUtterance:[self utteranceForText:text]];
}

@end
