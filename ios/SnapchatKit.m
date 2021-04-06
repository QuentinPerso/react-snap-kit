#import "SnapchatKit.h"
#import <SCSDKLoginKit/SCSDKLoginKit.h>
#import <SCSDKCreativeKit/SCSDKCreativeKit.h>
#import <React/RCTConvert.h>

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

RCT_EXPORT_METHOD(sharePhotoResolved:(NSDictionary *)resolvedPhoto url:(NSString *)photoUrl
                  stickerResolved:(NSDictionary *)stickerResolved stickerUrl:(NSString *)stickerUrl
                  stickerPosX:(float)stickerPosX stickerPosY:(float)stickerPosY
                  attachmentUrl:(NSString *)attachmentUrl
                  caption:(NSString *)caption
                  resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {

    NSObject *photo = resolvedPhoto != NULL ? resolvedPhoto : photoUrl;
    NSObject *sticker = stickerResolved != NULL ? stickerResolved : stickerUrl;
    [self shareWithPhoto:photo videoUrl:NULL sticker:sticker stickerPosX:stickerPosX stickerPosY:stickerPosY attachmentUrl:attachmentUrl caption:caption resolver:resolve rejecter:reject];

}


RCT_EXPORT_METHOD(shareVideoAtUrl:(NSString *)videoUrl
                  stickerResolved:(NSDictionary *)stickerResolved stickerUrl:(NSString *)stickerUrl
                  stickerPosX:(float)stickerPosX stickerPosY:(float)stickerPosY
                  attachmentUrl:(NSString *)attachmentUrl
                  caption:(NSString *)caption
                  resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {

    NSObject *sticker = stickerResolved != NULL ? stickerResolved : stickerUrl;
    [self shareWithPhoto:NULL videoUrl:videoUrl sticker:sticker stickerPosX:stickerPosX stickerPosY:stickerPosY attachmentUrl:attachmentUrl caption:caption resolver:resolve rejecter:reject];

}

- (void) shareWithPhoto:(NSObject *)photoImageOrUrl videoUrl:(NSString *)videoUrl sticker:(NSObject *)stickerImageOrUrl stickerPosX:(float)stickerPosX stickerPosY:(float)stickerPosY attachmentUrl:(NSString *)attachmentUrl caption:(NSString *)caption resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject {

    NSObject<SCSDKSnapContent> *snap;

    if (videoUrl) {
        NSURL *url = [self urlForString:videoUrl];
        SCSDKSnapVideo *video = [[SCSDKSnapVideo alloc] initWithVideoUrl:url];
        snap = [[SCSDKVideoSnapContent alloc] initWithSnapVideo:video];
    }
    else if ([photoImageOrUrl isKindOfClass:[NSString class]]) {
        NSURL *url = [self urlForString:(NSString *)photoImageOrUrl];
        SCSDKSnapPhoto *photo = [[SCSDKSnapPhoto alloc] initWithImageUrl:url];
        snap = [[SCSDKPhotoSnapContent alloc] initWithSnapPhoto:photo];
    }
    else if ([photoImageOrUrl isKindOfClass:[NSDictionary class]]) {
        UIImage *image = [RCTConvert UIImage:photoImageOrUrl];
        SCSDKSnapPhoto *photo = [[SCSDKSnapPhoto alloc] initWithImage:image];
        snap = [[SCSDKPhotoSnapContent alloc] initWithSnapPhoto:photo];
    }
    else {
        snap = [SCSDKNoSnapContent new];
    }

    if (stickerImageOrUrl) {
         SCSDKSnapSticker *snapSticker;
         if ([stickerImageOrUrl isKindOfClass:[NSString class]]) {
             NSURL *url = [self urlForString:(NSString *)stickerImageOrUrl];
             snapSticker = [[SCSDKSnapSticker alloc] initWithStickerUrl:url isAnimated:NO];
         }
         else if ([stickerImageOrUrl isKindOfClass:[UIImage class]]) {
             snapSticker = [[SCSDKSnapSticker alloc] initWithStickerImage:(UIImage *)stickerImageOrUrl];
         }

         if (stickerPosX) {
             snapSticker.posX = stickerPosX;
         }
         if (stickerPosY) {
              snapSticker.posY = stickerPosY;
         }

         snap.sticker = snapSticker;
     }

     snap.caption = caption;
     snap.attachmentUrl = attachmentUrl;
     NSLog(@"snap api : %@", snapAPI);
     [snapAPI startSendingContent:snap completionHandler:^(NSError *error) {
         if (error != nil) {
             resolve(@{
             @"result": @(YES),
             @"error": error.localizedDescription
                 });
         }
         else {
             resolve(@{ @"result": @(YES)});
         }
         /* Handle response */
     }];
 }

 - (BOOL) isStringAPath:(NSString *)stringUrl {
     NSString *fullpath = stringUrl.stringByExpandingTildeInPath;
     return [fullpath hasPrefix:@"/"] || [fullpath hasPrefix:@"file:/"];
 }

 - (NSURL *) urlForString:(NSString *)stringUrl {
     if ([self isStringAPath:stringUrl]) {
         // NSLog(@"IS A FILE PATH");
         return [NSURL fileURLWithPath:stringUrl];
     } else {
         // NSLog(@"IS NOT A FILE PATH");
         return [NSURL URLWithString:stringUrl];
     }
 }

 RCT_EXPORT_METHOD(lensSnapContent:(NSString *)lensUUID
                  caption:(NSString *)caption
                  attachmentUrl:(NSString *)attachmentUrl
                  launchData:(NSString *)launchData
                  resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {

    NSLog(@"lens launchData ========> %@", launchData);
     // objective-c
     /* Modeling a Snap using SCSDKLensSnapContent */
     SCSDKLensSnapContent *snap = [[SCSDKLensSnapContent alloc] initWithLensUUID:lensUUID];
     snap.caption = caption; /* Optional */
     snap.attachmentUrl = attachmentUrl; /* Optional */

     /* Optionally can add launch data */
     /* First initialize the launch data builder: */
     SCSDKLensLaunchDataBuilder *launchDataBuilder = [[SCSDKLensLaunchDataBuilder alloc] init];

     /* Then add the key value pair of the launch data: */
      [launchDataBuilder addNSStringKeyPair:@"breadtag" value:launchData];

     /* Then initialize and set the launch data to the Lens snap content type using the builder: */
    // [SCSDKLensLaunchData initWithBuilder:launchDataBuilder];
     snap.launchData = [[SCSDKLensLaunchData alloc] initWithBuilder:launchDataBuilder];
     
     NSLog(@"snap : %@", snap);
     [snapAPI startSendingContent:snap completionHandler:^(NSError *error) {
         if (error != nil) {
             resolve(@{
             @"result": @(YES),
             @"error": error.localizedDescription
                 });
         }
         else {
             resolve(@{ @"result": @(YES)});
         }
         /* Handle response */
     }];
}

 @end
