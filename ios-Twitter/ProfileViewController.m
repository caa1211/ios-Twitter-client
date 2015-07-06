//
//  ProfileViewController.m
//  ios-Twitter
//
//  Created by Carter Chang on 7/7/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "ProfileViewController.h"
#import "Define.h"

@interface ProfileViewController ()  <SlideNavigationControllerDelegate,  UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet UILabel *scrollTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIScrollView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *tweetsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (strong, nonatomic) User *loginUser;
@property (weak, nonatomic) IBOutlet UILabel *scrollTweetsCountLabel;
@property (strong, nonatomic) User *user;
@end

@implementation ProfileViewController

-(id) initWithUser:(User*)user andLoginUser:(User*)loginUser {
    self = [super init];
    if (self) {
        self.loginUser = loginUser;
        self.user = user;
    }
    return self;
}

- (id) initWithUser: (User *)user{
    self = [super init];
    if (self) {
        self.loginUser = user;
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    User *user = self.user;
    self.title = user.name;
    self.scrollTitleLabel.text = self.title;
    
    self.tweetsCountLabel.text = [@(user.numTweets) stringValue];
    self.followersCountLabel.text = [@(user.numFollowers) stringValue];
    self.followingCountLabel.text = [@(user.numFollowing) stringValue];
    self.scrollTweetsCountLabel.text = [NSString stringWithFormat:@"%ld tweets", (long)user.numTweets];
    self.name.text = user.name;
    self.screenname.text = user.screenname;
    
    NSString *profileImageUrl = user.profileImageUrl;
    [self.profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3] placeholderImage:nil success: nil failure:nil];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 2.0f;
    self.profileImage.layer.borderColor = CGColorRetain([UIColor colorWithRed:0.335 green:0.632 blue:0.916 alpha:1.000].CGColor);
    
    
    self.contentView.delegate = self;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[[UIColor alloc] initWithRed:0.298 green:0.646 blue:0.920 alpha:1.000]];

    self.navigationItem.titleView = self.titleView;
    
    if (self.loginUser != self.user){
        // Profile page for others
        UIImage *backImg = [Define fontImage:NIKFontAwesomeIconTimesCircle rgbaValue:0xffffff];
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:backImg style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
        self.navigationItem.leftBarButtonItem = backBtn;
    }else {
        // Profile page for self
        UIImage *menuImg = [Define fontImage:NIKFontAwesomeIconBars rgbaValue:0xffffff];
        UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithImage:menuImg style:UIBarButtonItemStylePlain target:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu)];
        [SlideNavigationController sharedInstance].leftBarButtonItem = menuBtn;
        
        self.scrollTitleLabel.text = @"Me";
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = CGPointMake(0.0, MIN(scrollView.contentOffset.y - 36.0, 42.0));
    [self.titleView setContentOffset:contentOffset];
}

- (void) onBack {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    if (self.loginUser != self.user){
        return NO;
    }
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

@end
