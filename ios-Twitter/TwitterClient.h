//
//  TwitterClient.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager
+ (TwitterClient *) sharedInstance;
-(void) loginWithCompletion: (void(^)(User *user, NSError *error))completion;
-(void)openUrl:(NSURL *)url;
-(void) homeTimelineWithParams:(NSDictionary *)params completion:(void(^)(NSArray *tweets, NSError *error))completion;
-(void) postTweet:(NSString *)text completion: (void(^)(Tweet *tweet, NSError *error))completion;
-(void) postRetweet:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion;
-(void) postDestroy:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion;
-(void) postFavoriteCreate:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion;
-(void) postFavoriteDestroy:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion;
-(void) postReply:(NSString *)text toTwitter:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion;
@end
