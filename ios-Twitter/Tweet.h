//
//  Tweet.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSDate *createdAt;
@property(nonatomic, strong) User *user;
@property(nonatomic, strong) NSString *timestamp;
@property(nonatomic, strong) NSString *mediaUrl;
@property (nonatomic, strong) NSString *idStr;
@property (nonatomic, strong) NSString *retweeted;
@property (nonatomic, strong) NSString *favorited;
@property (nonatomic, assign) NSInteger favoriteCount;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, assign) BOOL retweetable;

-(id)initWithDictionary: (NSDictionary *)dictionary;
-(void) setRetweet:(NSInteger)value;
-(void) setFavorite:(NSInteger)value;
-(void) setRetweetable:(BOOL)value;
+(NSArray *) tweetsWithArray: (NSArray *) array;
@end
