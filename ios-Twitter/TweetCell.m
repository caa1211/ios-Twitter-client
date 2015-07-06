//
//  TweetCell.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "TweetCell.h"
#import <UIImageView+AFNetworking.h>
#import "TwitterClient.h"

@interface TweetCell()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *createAt;
@property (weak, nonatomic) IBOutlet UIImageView *retweetBtn;
@property (weak, nonatomic) IBOutlet UIImageView *replyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteBtn;
@property (weak, nonatomic) IBOutlet UIImageView *globalIcon;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) Tweet *tweet;
@property (strong, nonatomic) User *user;

@property (strong, nonatomic) UIImage *retweetImage;
@property (strong, nonatomic) UIImage *retweetActiveImage;

@property (strong, nonatomic) UIImage *favoriteImage;
@property (strong, nonatomic) UIImage *favoriteActiveImage;
@end


@implementation TweetCell

enum {
    TwBtnDisable = -1,
    TwBtnEnable = 0,
    TwBtnActive = 1
};

- (void)awakeFromNib {
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    [factory setColors:@[ UIColorFromRGB(0xcdd8de)]];
    self.globalIcon.image = [factory createImageForIcon:NIKFontAwesomeIconGlobe];

    
    // Initialization code
    self.retweetImage = [Define fontImage:NIKFontAwesomeIconRetweet rgbaValue:0xaaaaaa];
    self.retweetActiveImage = [Define fontImage:NIKFontAwesomeIconRetweet rgbaValue:0x77b255];
    
    self.favoriteImage = [Define fontImage:NIKFontAwesomeIconStarO rgbaValue:0xaaaaaa];
    self.favoriteActiveImage = [Define fontImage:NIKFontAwesomeIconStar rgbaValue:0xffac33];

    self.replyBtn.image = [Define fontImage:NIKFontAwesomeIconReply rgbaValue:0xaaaaaa];//[UIImage imageNamed:@"reply.png" ];

    self.name.text = @"";
    self.clipsToBounds = YES;
    
    
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReply)];
    tapped.numberOfTapsRequired = 1;
    [self.replyBtn addGestureRecognizer:tapped];
    self.replyBtn.userInteractionEnabled = YES;
    
    tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetweet)];
    tapped.numberOfTapsRequired = 1;
    [self.retweetBtn addGestureRecognizer:tapped];
    
    tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFavorite)];
    tapped.numberOfTapsRequired = 1;
    [self.favoriteBtn addGestureRecognizer:tapped];
    
    tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserClick)];
    tapped.numberOfTapsRequired = 1;
    [self.profileImage addGestureRecognizer:tapped];
}

-(void) onUserClick {
    // Delegate tap to TweetsViewController, and than it will lunch ComposeTweetView.
    [self.delegate didUserSelected:self.tweet.user];
}


-(void) onReply {
    // Delegate tap to TweetsViewController, and than it will lunch ComposeTweetView.
    [self.delegate didTapCellReply:self.tweet];
}

-(void) onRetweet {
    NSLog(@"onRetweet");
    [[TwitterClient sharedInstance] postRetweet:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
        if (tweet != nil) {
            [self.tweet setRetweet:TwBtnActive];
            [self updateTweet:tweet];
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTweetNotification object:nil userInfo:@{ @"tweet" : tweet, @"cell": self} ];
        }
        NSLog(@"retweet success");
    }];
}

-(void) onFavorite {
    NSLog(@"onFavorite");
    if([self.tweet.favorited integerValue] == 1){
        [[TwitterClient sharedInstance] postFavoriteDestroy:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
            if (tweet != nil) {
                [self.tweet setFavorite:TwBtnEnable];
                [self updateTweet:tweet];
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTweetNotification object:nil userInfo:@{ @"tweet" : tweet, @"cell": self} ];
            }
            NSLog(@"remove favorite success");
        }];
    }else{
        [[TwitterClient sharedInstance] postFavoriteCreate:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
            if (tweet != nil) {
                [self.tweet setFavorite:TwBtnActive];
                [self updateTweet:tweet];
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTweetNotification object:nil userInfo:@{ @"tweet" : tweet, @"cell": self} ];
            }
            NSLog(@"favorite success");
        }];
    }
}

-(void) onRemoveTweet: (Tweet *) tweet{
    [[TwitterClient sharedInstance] postDestroy:self.tweet.idStr completion:^(Tweet *tweet, NSError *error) {
        if (tweet != nil) {
            NSLog(@"postDestroy success");
        }
        
    }];
}

-(void) setTweet:(Tweet *) tweet {
    User *user = tweet.user;

    NSString *profileImageUrl = user.profileImageUrl;
    
    [self.profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3]
                             placeholderImage:nil success: ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                 self.profileImage.image = image;
                                 CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
                                 fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                 fade.fromValue = [NSNumber numberWithFloat:0.0f];
                                 fade.toValue = [NSNumber numberWithFloat:1.0f];
                                 fade.duration = 0.5f;
                                 [self.profileImage.layer addAnimation:fade forKey:@"fade"];
                                 
                             } failure:nil];

    // Circle Image Style
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = CGColorRetain([UIColor colorWithRed:0.335 green:0.632 blue:0.916 alpha:1.000].CGColor);
    
    
    [self assignTweet:tweet];
    
    // TODO: media preview
//    if(tweet.mediaUrl != nil){
//        [mv setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tweet.mediaUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3] placeholderImage:nil success: ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
//           // mv.image = image;
//        } failure:nil];
//    }

}

-(void) assignTweet:(Tweet *) tweet {
    User *user = tweet.user;
    _user = user;
    _tweet = tweet;
    self.name.text = user.name;
    self.createAt.text = tweet.timestamp;
    self.tweetText.text = tweet.text;
    self.screenName.text = [NSString stringWithFormat:@"@%@", user.screenname ];
    
    [self setFavoriteState: [self.tweet.favorited integerValue]];
    if(self.tweet.retweetable == YES){
        [self setRetweetState: [self.tweet.retweeted integerValue]];
    }else{
        [self setRetweetState: TwBtnDisable];
    }
}

-(void) updateTweet:(Tweet *) tweet {
    self.tweet.favorited = tweet.favorited;
    self.tweet.retweeted = tweet.retweeted;
    [self setFavoriteState: [self.tweet.favorited integerValue]];
    if(self.tweet.retweetable == YES){
        [self setRetweetState: [self.tweet.retweeted integerValue]];
    }else{
        [self setRetweetState: TwBtnDisable];
    }
}

-(void) setRetweetState:(NSInteger)state {
    switch (state) {
        case TwBtnDisable:
            self.retweetBtn.image = self.retweetImage;
            self.retweetBtn.userInteractionEnabled = NO;
            [self.retweetBtn setAlpha:0.3];
            break;
        case TwBtnEnable:
            self.retweetBtn.image = self.retweetImage;
            self.retweetBtn.userInteractionEnabled = YES;
            [self.retweetBtn setAlpha:1];
            break;
        case TwBtnActive:
            self.retweetBtn.image = self.retweetActiveImage;
            self.retweetBtn.userInteractionEnabled = YES;
            [self.retweetBtn setAlpha:1];
            break;
        default:
            break;
    }
}

-(void) setFavoriteState:(NSInteger)state {
    switch (state) {
        case TwBtnDisable:
            self.favoriteBtn.image = self.favoriteImage;
            self.favoriteBtn.userInteractionEnabled = NO;
            [self.favoriteBtn setAlpha:0.3];
            break;
        case TwBtnEnable:
            self.favoriteBtn.image = self.favoriteImage;
            self.favoriteBtn.userInteractionEnabled = YES;
            [self.favoriteBtn setAlpha:1];
            break;
        case TwBtnActive:
            self.favoriteBtn.image = self.favoriteActiveImage;
             self.favoriteBtn.userInteractionEnabled = YES;
            [self.favoriteBtn setAlpha:1];
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.profileImage.image = nil;
    [self assignTweet:self.tweet];
}


@end
