#import <Foundation/Foundation.h>

@interface LGSentence : NSObject <NSCoding>
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *iconSymbolName;
@property (nonatomic, copy) NSString *sentenceID;
@property (nonatomic, strong) NSDate *createdAt;

- (instancetype)initWithText:(NSString *)text
                 iconSymbolName:(NSString *)iconSymbolName;
@end
