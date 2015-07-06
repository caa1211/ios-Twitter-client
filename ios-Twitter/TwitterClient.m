//
//  TwitterClient.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString * const kTwitterConsumerKey = @"iab5m8aK5pZrva9vjY16hObSa";
NSString * const kTwitterConsumerSecret = @"DKsD7D0aUs0kbYvn59eo9PNSI8WqCOcqFLMuBXnlz0PAGt39aW";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient()
@property(nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);
@end

@implementation TwitterClient
+ (TwitterClient *) sharedInstance {
    static TwitterClient *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL: [NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });

    return instance;
}

-(void) loginWithCompletion: (void(^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"caatwitterclient://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"got the request token");
        NSURL *authURL = [NSURL URLWithString: [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        [[UIApplication sharedApplication] openURL:authURL];
    } failure:^(NSError *error) {
        NSLog(@"failed to get the request token");
        self.loginCompletion(nil, error);
    }];
}

-(void)openUrl:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        NSLog(@"got access token");
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:@"/1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            NSLog(@"current user %@", user.name);
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failed to get current user");
            self.loginCompletion(nil, error);
        }] ;
        
    } failure:^(NSError *error) {
        NSLog(@"failed to get access token");
        self.loginCompletion(nil, error);
        
    }];
}

-(void) homeTimelineWithParams:(NSDictionary *)params completion:(void(^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"/1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }] ;
}

-(void) postTweet:(NSString *)text completion: (void(^)(Tweet *tweet, NSError *error))completion{
    [self POST:@"1.1/statuses/update.json" parameters:@{@"status": text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }] ;
}

-(void) postReply:(NSString *)text toTwitter:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion{
    [self POST:@"1.1/statuses/update.json" parameters:@{@"status": text, @"in_reply_to_status_id": idStr} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }] ;
}


-(void) postRetweet:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion{
    NSString *url = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json",idStr];
    
    [self POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }] ;
}

-(void) postDestroy:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion{
    NSString *url = [NSString stringWithFormat:@"1.1/statuses/destroy/%@.json",idStr];
    
    [self POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }] ;
}


-(void) postFavoriteCreate:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion{
    NSString *url = @"1.1/favorites/create.json";
    
    [self POST:url parameters:@{@"id": idStr} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }] ;
}

-(void) postFavoriteDestroy:(NSString *)idStr completion: (void(^)(Tweet *tweet, NSError *error))completion{
    NSString *url = @"1.1/favorites/destroy.json";
    [self POST:url parameters:@{@"id": idStr} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:responseObject];
        completion(tweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }] ;
}


@end
