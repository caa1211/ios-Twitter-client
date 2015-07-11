//
//  ProfileCell.m
//  ios-Twitter
//
//  Created by Carter Chang on 7/11/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "ProfileCell.h"
#import "TwitterClient.h"

@interface ProfileCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) User* user;
@property (weak, nonatomic) IBOutlet UIImageView *profileBanner;

@end

@implementation ProfileCell

-(void) setUser:(User *)user {
    _user = user;
    self.nameLabel.text = user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@",user.screenname ];
    
    self.nameLabel.shadowColor = [UIColor colorWithRed:0.259 green:0.238 blue:0.240 alpha:1.000];
    self.nameLabel.shadowOffset = CGSizeMake(0,1);
    
    self.screennameLabel.shadowColor = [UIColor colorWithRed:0.259 green:0.238 blue:0.240 alpha:1.000];
    self.screennameLabel.shadowOffset = CGSizeMake(0,1);
    
    NSString *profileImageUrl = user.profileImageUrl;
    [self.profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3] placeholderImage:nil success: nil failure:nil];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 2.0f;
    self.profileImage.layer.borderColor = CGColorRetain([UIColor whiteColor].CGColor);
    
    
  
    if ( user.profileBannerUrl == nil) {
    
        [[TwitterClient sharedInstance] userProfileBannerWithParam:@{@"user_id": user.idStr, @"screen_name": user.screenname} completion:^(NSDictionary *images, NSError *error) {
            if(images != nil){
                NSString *url = images[@"sizes"][@"mobile_retina"][@"url"];
                [self.profileBanner setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3] placeholderImage:nil success: ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                
                    
                    self.profileBanner.image = image;
                    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    fade.fromValue = [NSNumber numberWithFloat:0.0f];
                    fade.toValue = [NSNumber numberWithFloat:1.0f];
                    fade.duration = 0.5f;
                    [self.profileImage.layer addAnimation:fade forKey:@"fade"];
                    
                    [user setProfileBannerUrl:url];

                } failure:nil];
            }
            
            else {
                [user setProfileBannerUrl:@""];
            }
        }];
        
    }else {
        
        [self.profileBanner setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:user.profileBannerUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3] placeholderImage:nil success: nil failure:nil];
    }
}


- (void)awakeFromNib {
    // Initialization code
    
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
