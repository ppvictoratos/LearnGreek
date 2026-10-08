#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LGPhraseLanguage) {
    LGPhraseLanguageEnglish = 0,
    LGPhraseLanguageGreek = 1,
};

@interface LGPhrase : NSObject <NSSecureCoding>
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) LGPhraseLanguage language;
@property (nonatomic, copy) NSString *phraseID;
@property (nonatomic, strong) NSDate *createdAt;

- (instancetype)initWithText:(NSString *)text language:(LGPhraseLanguage)language;
@end
