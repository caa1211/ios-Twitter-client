//
//  ComposeTweetViewController.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/30/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Tweet.h"

@protocol ComposeTweetViewControllerDelegate <NSObject>
- (void) didPostTweet:(Tweet*)tweet;
@end

@interface ComposeTweetViewController : UIViewController
-(id) initWithUser:(User*)user;
-(id) initWithUser:(User*)user andTweet:(Tweet *)tweet;

@property (nonatomic, weak) id <ComposeTweetViewControllerDelegate> delegate;
@end
