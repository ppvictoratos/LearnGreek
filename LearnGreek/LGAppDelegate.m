#import "LGAppDelegate.h"
#import "LGHomeViewController.h"
#import "LGThemeManager.h"

@implementation LGAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // UI tests pass this flag so every run starts from a clean slate.
    if ([[NSProcessInfo processInfo].arguments containsObject:@"--uitest-reset"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"LGFavoriteWordIDs"];
        [defaults removeObjectForKey:@"LGSavedSentences"];
        [defaults removeObjectForKey:@"LGSelectedTheme"];
        [defaults setObject:@"en" forKey:@"LGBaseLanguage"];
    }

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    LGHomeViewController *home = [[LGHomeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];

    [[LGThemeManager sharedManager] applyToNavigationController:nav];
    return YES;
}

@end
