#import "SnapchatKit.h"
#import <SCSDKLoginKit/SCSDKLoginKit.h>
#import <SCSDKCreativeKit/SCSDKCreativeKit.h>

@implementation SnapchatKit {
    SCSDKSnapAPI *snapAPI;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (instancetype)init {
    self = [super init];
    if (self) {
        snapAPI = [SCSDKSnapAPI new];
    }
    return self;
}



RCT_EXPORT_MODULE()

//******************************************************************
#pragma mark --------- Login Kit ------------
//******************************************************************

RCT_REMAP_METHOD(login,
                 loginResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    
    [SCSDKLoginClient loginFromViewController:rootViewController
                                   completion:^(BOOL success, NSError * _Nullable error)
    {
        if(error) {
            resolve(@{
                @"result": @(NO),
                @"error": error.localizedDescription
            });
        } else {
            resolve(@{@"result": @(YES)});
        }
    }];
}

RCT_EXPORT_METHOD(logout) {
    [SCSDKLoginClient clearToken];
}

RCT_REMAP_METHOD(isUserLoggedIn,
                 isUserLoggedInResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    resolve(@{@"result": @([SCSDKLoginClient isUserLoggedIn])});
}

RCT_REMAP_METHOD(fetchUserData,
                 fetchUserDataResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if ([SCSDKLoginClient isUserLoggedIn]) {
        NSString *graphQLQuery = @"{me{displayName, externalId, bitmoji{avatar}}}";
        
        NSDictionary *variables = @{@"page": @"bitmoji"};
        
        [SCSDKLoginClient fetchUserDataWithQuery:graphQLQuery
                                       variables:variables
                                         success:^(NSDictionary *resources)
        {
            NSDictionary *data = resources[@"data"];
            NSDictionary *me = data[@"me"];
            NSDictionary *bitmoji = me[@"bitmoji"];
            NSString *bitmojiAvatarUrl = bitmoji[@"avatar"];
            if (bitmojiAvatarUrl == (id)[NSNull null] || bitmojiAvatarUrl.length == 0 ) bitmojiAvatarUrl = @"(null)";
            resolve(@{
                @"displayName": me[@"displayName"],
                @"externalId": me[@"externalId"],
                @"avatar": bitmojiAvatarUrl
            });
            
        }
                                         failure:^(NSError * error, BOOL isUserLoggedOut)
        {
            reject(@"error", @"error", error);
        }];
    } else {
        resolve([NSNull null]);
    }
}

RCT_REMAP_METHOD(getAccessToken,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString * accessToken = [SCSDKLoginClient getAccessToken];
    
    if (accessToken) {
        resolve(@{
            @"accessToken": accessToken
        });
    } else {
        resolve(@{
            @"accessToken": [NSNull null],
            @"error": @"No access token"
        });
    }
}

//******************************************************************
#pragma mark --------- Creative Kit ------------
//******************************************************************

RCT_EXPORT_METHOD(sharePhotoAtUrl:(NSString *)photoUrl stickerUrl:(NSString *)stickerUrl stickerPosX:(float)stickerPosX stickerPosY:(float)stickerPosY attachmentUrl:(NSString *)attachmentUrl caption:(NSString *)caption resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [self shareWithPhotoUrl:photoUrl videoUrl:NULL stickerUrl:stickerUrl stickerPosX:stickerPosX stickerPosY:stickerPosY attachmentUrl:attachmentUrl caption:caption resolver:resolve rejecter:reject];
    
}

RCT_EXPORT_METHOD(shareVideoAtUrl:(NSString *)videoUrl stickerUrl:(NSString *)stickerUrl stickerPosX:(float)stickerPosX stickerPosY:(float)stickerPosY attachmentUrl:(NSString *)attachmentUrl caption:(NSString *)caption resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [self shareWithPhotoUrl:NULL videoUrl:videoUrl stickerUrl:stickerUrl stickerPosX:stickerPosX stickerPosY:stickerPosY attachmentUrl:attachmentUrl caption:caption resolver:resolve rejecter:reject];
    
}

- (void) shareWithPhotoUrl:(NSString *)photoUrl videoUrl:(NSString *)videoUrl stickerUrl:(NSString *)stickerUrl stickerPosX:(float)stickerPosX stickerPosY:(float)stickerPosY attachmentUrl:(NSString *)attachmentUrl caption:(NSString *)caption resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {
    
    NSObject<SCSDKSnapContent> *snap;
    
    if (videoUrl) {
        NSURL *url = [NSURL URLWithString:videoUrl];
        SCSDKSnapVideo *video = [[SCSDKSnapVideo alloc] initWithVideoUrl:url];
        snap = [[SCSDKVideoSnapContent alloc] initWithSnapVideo:video];
    }
    else if (photoUrl) {
        NSURL *url = [NSURL URLWithString:photoUrl];
        SCSDKSnapPhoto *photo = [[SCSDKSnapPhoto alloc] initWithImageUrl:url];
        snap = [[SCSDKPhotoSnapContent alloc] initWithSnapPhoto:photo];
    }
    else {
        snap = [SCSDKNoSnapContent new];
    }

    if (stickerUrl) {
        NSURL *url = [NSURL URLWithString:stickerUrl];
        SCSDKSnapSticker *sticker = [[SCSDKSnapSticker alloc] initWithStickerUrl:url isAnimated:NO];
        sticker.posX = stickerPosX;
        sticker.posY = stickerPosY;
        snap.sticker = sticker;
    }
    
    snap.caption = caption;
    snap.attachmentUrl = attachmentUrl;

    [snapAPI startSendingContent:snap completionHandler:^(NSError *error) {
        if (error != nil) {
            reject(@"Error", @"Unknown", error);
        }
        else {
            resolve(@{@"success": @(YES)});
        }
        /* Handle response */
    }];
    
}

@end
