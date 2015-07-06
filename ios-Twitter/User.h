//
//  User.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;


@interface User : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *screenname;
@property(nonatomic, strong) NSString *profileImageUrl;
@property(nonatomic, strong) NSString *tagline;
@property(nonatomic, strong) NSString *idStr;
@property (nonatomic, assign) NSInteger numTweets;
@property (nonatomic, assign) NSInteger numFollowing;
@property (nonatomic, assign) NSInteger numFollowers;

-(id)initWithDictionary: (NSDictionary *)dictionary;
+ (User *) currentUser;
+ (void) setCurrentUser:(User *) currentUser;
+ (void) logout;
@end
