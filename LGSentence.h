#import <Foundation/Foundation.h>

@interface LGSentence : NSObject <NSCoding>
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *iconSymbolName;
@property (nonatomic, copy) NSString *sentenceID;
@property (nonatomic, strong) NSDate *createdAt;

/// Pronunciation guide (e.g. "kalimera") built from the transliterations of
/// the words the sentence was chained from. Nil when there's none available.
@property (nonatomic, copy) NSString *phonetic;

- (instancetype)initWithText:(NSString *)text
                 iconSymbolName:(NSString *)iconSymbolName;

- (instancetype)initWithText:(NSString *)text
                 iconSymbolName:(NSString *)iconSymbolName
                       phonetic:(NSString *)phonetic;
@end
