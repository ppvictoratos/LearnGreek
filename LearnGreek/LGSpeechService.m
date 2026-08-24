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

- (void)speakWord:(LGWord *)word {
    if (self.synthesizer.isSpeaking) {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:word.greek];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"el-GR"];
    utterance.rate = 0.45;
    [self.synthesizer speakUtterance:utterance];
}

@end
