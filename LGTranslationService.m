#import "LGTranslationService.h"

static NSString *const LGTranslationCacheKey = @"LGTranslationCache";
static NSString *const LGMyMemoryBase = @"https://api.mymemory.translated.net/get";

@implementation LGTranslationService

+ (LGTranslationService *)sharedService {
    static LGTranslationService *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[LGTranslationService alloc] init]; });
    return shared;
}

- (void)translatePhrase:(NSString *)phrase
             completion:(void (^)(NSString *_Nullable, NSError *_Nullable))completion {
    NSString *trimmed = [phrase stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!trimmed.length) {
        dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, nil); });
        return;
    }

    NSString *cached = [self cachedTranslationForKey:trimmed];
    if (cached) {
        dispatch_async(dispatch_get_main_queue(), ^{ completion(cached, nil); });
        return;
    }

    NSString *encoded = [trimmed stringByAddingPercentEncodingWithAllowedCharacters:
                         NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *urlString = [NSString stringWithFormat:@"%@?q=%@&langpair=en|el", LGMyMemoryBase, encoded];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionDataTask *task =
        [[NSURLSession sharedSession] dataTaskWithURL:url
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); });
            return;
        }

        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSString *translated = json[@"responseData"][@"translatedText"];

        if (!translated || jsonError) {
            NSError *parseError = jsonError ?: [NSError errorWithDomain:@"LGTranslation"
                                                                   code:0
                                                               userInfo:@{NSLocalizedDescriptionKey: @"Unexpected response"}];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, parseError); });
            return;
        }

        [self cacheTranslation:translated forKey:trimmed];
        dispatch_async(dispatch_get_main_queue(), ^{ completion(translated, nil); });
    }];
    [task resume];
}

#pragma mark - Cache

- (nullable NSString *)cachedTranslationForKey:(NSString *)key {
    NSDictionary *cache = [[NSUserDefaults standardUserDefaults] dictionaryForKey:LGTranslationCacheKey];
    return cache[key];
}

- (void)cacheTranslation:(NSString *)translation forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *cache = [([defaults dictionaryForKey:LGTranslationCacheKey] ?: @{}) mutableCopy];
    cache[key] = translation;
    [defaults setObject:cache forKey:LGTranslationCacheKey];
}

@end
