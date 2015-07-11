//
//  StatusCell.m
//  ios-Twitter
//
//  Created by Carter Chang on 7/12/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "StatusCell.h"

@interface StatusCell()
@property (weak, nonatomic) IBOutlet UILabel *tweetsNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersNumLabel;

@property (strong, nonatomic) User* user;
@end

@implementation StatusCell

-(void) setUser:(User *)user {
    _user = user;
    self.followersNumLabel.text = [@(user.numFollowers) stringValue];
    self.followingNumLabel.text = [@(user.numFollowing) stringValue];
    self.tweetsNumLabel.text = [@(user.numTweets) stringValue];
}

- (void)awakeFromNib {
    self.separatorInset = UIEdgeInsetsZero;
    self.layoutMargins = UIEdgeInsetsZero;
    self.preservesSuperviewLayoutMargins = NO;
    
    self.clipsToBounds= YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
