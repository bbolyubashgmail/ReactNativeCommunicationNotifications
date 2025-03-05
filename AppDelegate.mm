#import "AppDelegate.h"
#import <Firebase.h>
#import <RNBranch/RNBranch.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTLinkingManager.h>

// ---------- ADD IMPORTS -------- //
#import <UserNotifications/UserNotifications.h>
#import <FirebaseMessaging/FirebaseMessaging.h>

@interface AppDelegate () <UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    [RNBranch useTestInstance];
    [RNBranch initSessionWithLaunchOptions:launchOptions isReferrable:YES];

    [FIRApp configure];

    // --------------- ADD BLOCK: Запит на дозвіл пуш-нотифікацій -------------- //
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [application registerForRemoteNotifications];
            });
        }
    }];


    // --------------- ADD LINE: Установлення делегату для Firebase Messaging -------------- //
    [FIRMessaging messaging].delegate = self;

    self.moduleName = @"target_name";
    self.initialProps = @{};
  
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
    return [self bundleURL];
}

- (NSURL *)bundleURL
{
#if DEBUG
    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@".expo/.virtual-metro-entry"];
#else
    return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    [RNBranch application:application openURL:url options:options];
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    [RNBranch continueUserActivity:userActivity];
    return YES;
}

    // --------------- ADD BLOCK -------------- //
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    NSLog(@"Foreground notification received: %@", notification.request.content.userInfo);

    // Надсилаємо дані у Firebase Messaging
    [[FIRMessaging messaging] appDidReceiveMessage:notification.request.content.userInfo];

    // Повідомляємо систему, як показувати пуш
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

    // --------------- ADD BLOCK: Делегат для обробки реакції на пуш-нотифікацію (коли користувач натискає на пуш) -------------- //
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"Push Clicked: %@", response.notification.request.content.userInfo);
    completionHandler();
}

    // --------------- ADD BLOCK: Обробка реєстрації для пуш-нотифікацій -------------- //
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [FIRMessaging messaging].APNSToken = deviceToken;
}

    // --------------- ADD BLOCK: Обробка отримання пуш-нотифікацій у бекграунді або коли додаток закритий -------------- //
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Remote notification received: %@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
