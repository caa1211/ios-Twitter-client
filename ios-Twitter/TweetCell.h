//
//  TweetCell.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
#import "Tweet.h"
#import "User.h"

@protocol TweetCellDelegate <NSObject>
-(void) didTapCellReply: (Tweet *) tweet;
@end

@interface TweetCell : UITableViewCell
-(void) setTweet:(Tweet *) tweet;
-(void) setRetweetState:(NSInteger)state;
-(void) setFavoriteState:(NSInteger)state;
-(void) updateTweet:(Tweet *) tweet;
@property (nonatomic, weak) id <TweetCellDelegate> delegate;
@end
