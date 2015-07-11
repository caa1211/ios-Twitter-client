//
//  ProfileViewController2.m
//  ios-Twitter
//
//  Created by Carter Chang on 7/11/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "ProfileViewController2.h"
#import "ProfileCell.h"
#import "StatusCell.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "ComposeTweetViewController.h"
#import "TweetDetailViewController.h"
@interface ProfileViewController2 ()  <SlideNavigationControllerDelegate,  UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, TweetCellDelegate, ComposeTweetViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *scrollTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *scrollSubtitleLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *titleView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) User *loginUser;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *tweets;
@end

@implementation ProfileViewController2

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
   
    
    self.scrollTitleLabel.text = [ NSString stringWithFormat:@"%d tweets",user.numTweets];
    self.scrollSubtitleLabel.text = user.name;

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
        
        self.scrollSubtitleLabel.text = @"Me";
    }
    
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DefaultCell"];

    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"StatusCell" bundle:nil] forCellReuseIdentifier:@"StatusCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    self.tableView.clipsToBounds = YES;
    [self adjustTableHeight];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPostNewTweet:) name:PostNewTweetNotification object:nil];
    
    [[TwitterClient sharedInstance] userTimelineWithParams:@{@"user_id": user.idStr} completion:^(NSArray *tweets, NSError *error) {
        if (tweets == nil){
//            NSString *errorMsg =  error.userInfo[@"NSLocalizedDescription"];
//            [TSMessage showNotificationWithTitle:@"Newtork Error"
//                                        subtitle:errorMsg //@"Please check your connection and try again later"
//                                            type:TSMessageNotificationTypeWarning];
        }else{
            self.tweets = [[NSMutableArray alloc] initWithArray: tweets];
            [self.tableView reloadData];
        }

    }];
    
}

- (void) onBack {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void) onPostNewTweet:(NSNotification *)note {
    Tweet *tweet = note.userInfo[@"tweet"];
    [self.tweets insertObject:tweet atIndex:0];
    
    // Insert row with animation
    NSMutableArray *arrRows = [NSMutableArray array];
    [arrRows addObject:[NSIndexPath indexPathForRow:2 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:arrRows withRowAnimation:UITableViewRowAnimationFade];
    
    // or refresh tabel: [self.tableView reloadData];
    // or refeth data: [self refreshData];
    NSLog(@"onPostNewTweet %@", tweet.user.name);
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = CGPointMake(0.0, MIN(scrollView.contentOffset.y - 36.0, 42.0));
    [self.titleView setContentOffset:contentOffset];
    
    
    float scale = ((scrollView.contentOffset.y + 64) * -1)/100;
    
    UITableViewCell *profileCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (profileCell && scale > 0) {
        ((ProfileCell *)profileCell).profileBackground.transform = CGAffineTransformMakeScale(1.0 + scale , 1.0 +scale);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0 ) {
       ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell" forIndexPath:indexPath];
        [cell setUser:self.user];
        return cell;
    }else if(indexPath.row == 1){
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell" forIndexPath:indexPath];
        [cell setUser:self.user];
        return cell;
    }
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    Tweet *tweetData = self.tweets[indexPath.row -2];
    
    if ([self.loginUser.idStr isEqual:tweetData.user.idStr]) {
        [tweetData setRetweetable:NO];
    }else{
        //[cell setRetweetState: [tweetData.retweeted integerValue]];
        [tweetData setRetweetable:YES];
    }
    
    [cell setTweet:tweetData];
    cell.delegate = self;
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
//    cell.backgroundColor = tableView.backgroundColor;
//    cell.textLabel.text = @"aa";
//    cell.textLabel.font = [UIFont systemFontOfSize:18];
//    cell.textLabel.textColor = [UIColor colorWithRed:0.335 green:0.632 blue:0.916 alpha:1.000];
    return cell;
}


- (void)didTapCellReply:(Tweet *)tweet
{
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc]initWithUser:self.loginUser andTweet:tweet];
    UINavigationController *nvController = [[UINavigationController alloc]
                                            initWithRootViewController: vc];
    // nvController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nvController animated:YES completion:nil];
}

- (void) adjustTableHeight {
    self.tableView.estimatedRowHeight = 100.0; // for example. Set your average height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    // Fix height of cell be strange after filter view closing
    [super viewWillAppear:animated];
    [self adjustTableHeight];
}

- (void) didUserSelected: (User *) user {
//    ProfileViewController2 *vc = [[ProfileViewController2 alloc]initWithUser:user andLoginUser: self.loginUser];
//    UINavigationController *nvController = [[UINavigationController alloc]
//                                            initWithRootViewController: vc];
//    [self presentViewController:nvController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row > 1){
        TweetDetailViewController *vc = [[TweetDetailViewController alloc] initWithUser:self.loginUser andTweet:self.tweets[indexPath.row-2]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(indexPath.row == 0){
        return 260;
    }if(indexPath.row == 1){
        return 53;
    }else{
        return tableView.rowHeight;
    }
}

@end
