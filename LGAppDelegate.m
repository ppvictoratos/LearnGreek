#import "LGAppDelegate.h"
#import "LGHomeViewController.h"
#import "LGThemeManager.h"

@implementation LGAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"[LGAppDelegate] didFinishLaunchingWithOptions called");

    // UI tests pass this flag so every run starts from a clean slate.
    if ([[NSProcessInfo processInfo].arguments containsObject:@"--uitest-reset"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"LGFavoriteWordIDs"];
        [defaults removeObjectForKey:@"LGSavedSentences"];
        [defaults removeObjectForKey:@"LGSelectedTheme"];
        [defaults setObject:@"en" forKey:@"LGBaseLanguage"];
    }

    NSLog(@"[LGAppDelegate] Creating window");
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    NSLog(@"[LGAppDelegate] Creating LGHomeViewController");
    LGHomeViewController *home = [[LGHomeViewController alloc] init];
    NSLog(@"[LGAppDelegate] Creating UINavigationController");
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    NSLog(@"[LGAppDelegate] Setting rootViewController");
    self.window.rootViewController = nav;

    NSLog(@"[LGAppDelegate] Making window key and visible");
    [self.window makeKeyAndVisible];

    NSLog(@"[LGAppDelegate] Applying theme");
    [[LGThemeManager sharedManager] applyToNavigationController:nav];
    NSLog(@"[LGAppDelegate] Finished setup");
    return YES;
}

@end
