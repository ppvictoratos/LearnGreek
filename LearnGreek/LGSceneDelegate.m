#import "LGSceneDelegate.h"
#import "LGHomeViewController.h"
#import "LGThemeManager.h"

@implementation LGSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    NSLog(@"[LGSceneDelegate] scene:willConnectToSession: called");
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        NSLog(@"[LGSceneDelegate] Scene is not UIWindowScene, returning");
        return;
    }

    NSLog(@"[LGSceneDelegate] Creating window...");
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    NSLog(@"[LGSceneDelegate] Creating LGHomeViewController...");
    LGHomeViewController *home = [[LGHomeViewController alloc] init];
    NSLog(@"[LGSceneDelegate] Creating UINavigationController...");
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    NSLog(@"[LGSceneDelegate] Setting window.rootViewController...");
    self.window.rootViewController = nav;

    NSLog(@"[LGSceneDelegate] Applying theme...");
    [[LGThemeManager sharedManager] applyToNavigationController:nav];
    NSLog(@"[LGSceneDelegate] Making window key and visible...");
    [self.window makeKeyAndVisible];
    NSLog(@"[LGSceneDelegate] Scene setup complete");
}

@end
