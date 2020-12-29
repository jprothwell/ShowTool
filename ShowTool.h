#import <Foundation/Foundation.h>

@interface ShowTool : NSObject
+ (void) toast:(NSString*)message;
+ (void) messageBox:(NSString*)message;
+ (void) messageBox:(NSString*)message done:(void(^)(void))done;
+ (void) showLoading;
+ (void) hideLoading;
@end
