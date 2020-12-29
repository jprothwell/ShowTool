#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "ShowTool.h"

#pragma mark - store
@interface NSObject (LoadingWindow)

@property (nonatomic, strong) UIWindow* loadingWindow;

@end

static char kObjectLoadingWindow;

@implementation NSObject (LoadingWindow)

- (UIWindow *)loadingWindow {
    return (UIWindow*)objc_getAssociatedObject(self, &kObjectLoadingWindow);
}

- (void)setLoadingWindow:(UIWindow *)loadingWindow {
    UIWindow* old = (UIWindow*)objc_getAssociatedObject(self, _cmd);
    if (old != loadingWindow) {
        objc_setAssociatedObject(self, &kObjectLoadingWindow, loadingWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

#pragma mark - ShowTool

@implementation ShowTool
+ (void) toast:(NSString*)message {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_13_0
    UIWindowScene* scene = [[self class] _foregroundActiveWindowScene];
    if (!scene) {
        NSLog(@"未找到SCENES");
        return;
    }
#endif
    
    UIWindow* window = [[UIWindow alloc]init];
    window.backgroundColor = nil;
    window.windowLevel = UIWindowLevelAlert;
    window.rootViewController = [[UIViewController alloc]init];
    window.hidden = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_13_0
    window.windowScene = scene;
#endif
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // window 正好也需要保持变量。
        [window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        window.hidden = YES;
    });
}

+ (void) messageBox:(NSString*)message {
    return [[self class] messageBox:message done:nil];
}

+ (void) messageBox:(NSString*)message done:(void(^)(void))done {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_13_0
    UIWindowScene* scene = [[self class] _foregroundActiveWindowScene];
    if (!scene) {
        NSLog(@"未找到SCENES");
        return;
    }
#endif
    
    UIWindow* window = [[UIWindow alloc]init];
    window.backgroundColor = nil;
    window.windowLevel = UIWindowLevelAlert;
    window.rootViewController = [[UIViewController alloc]init];
    window.hidden = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_13_0
    window.windowScene = scene;
#endif
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        window.hidden = YES;
        done == nil ? : done();
    }]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

+ (void) showLoading {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_13_0
    UIWindowScene* scene = [[self class] _foregroundActiveWindowScene];
    if (!scene) {
        NSLog(@"未找到SCENES");
        return;
    }
#endif
    
    UIWindow* window = [[UIWindow alloc]init];
    window.backgroundColor = nil;
    window.windowLevel = UIWindowLevelAlert;
    window.rootViewController = [[UIViewController alloc]init];
    window.hidden = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_13_0
    window.windowScene = scene;
#endif
    if ([UIApplication sharedApplication].loadingWindow) {
        [[UIApplication sharedApplication].loadingWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
        [UIApplication sharedApplication].loadingWindow.hidden = YES;
    }
    [UIApplication sharedApplication].loadingWindow = window;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc]init];
    activityIndicatorView.userInteractionEnabled = NO;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_13_0
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
#else
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
#endif

    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [alert.view addSubview:activityIndicatorView];
    NSDictionary * views = @{@"indicator" : activityIndicatorView};
    NSArray * constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(40)-[indicator]-(40)-|" options:0 metrics:nil views:views];
    NSArray * constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray * constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    [alert.view addConstraints:constraints];

    dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicatorView startAnimating];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}
+ (void) hideLoading {
    if ([UIApplication sharedApplication].loadingWindow) {
        [[UIApplication sharedApplication].loadingWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
        [UIApplication sharedApplication].loadingWindow.hidden = YES;
        [UIApplication sharedApplication].loadingWindow = nil;
    }
}


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_13_0
+ (UIWindowScene*) _foregroundActiveWindowScene {
    NSSet* scenes = [[[UIApplication sharedApplication] connectedScenes] filteredSetUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ((UIScene*)evaluatedObject).activationState == UISceneActivationStateForegroundActive;
    }]];
    
    return (UIWindowScene*)scenes.anyObject;
}
#endif
@end
