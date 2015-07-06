//
//  TweetsViewController.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "Tweet.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import <UIScrollView+InfiniteScroll.h>
#import <TSMessage.h>
#import "ComposeTweetViewController.h"
#import "TweetDetailViewController.h"
#import "SlideNavigationController.h"
#import "MenuViewController.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate, SlideNavigationControllerDelegate>

//@property (nonatomic, strong) UINavigationController *naviController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) User *loginUser;
@end

enum {
    TimelineSection = 0
};

@implementation TweetsViewController

- (void)viewWillAppear:(BOOL)animated {
    // Fix height of cell be strange after filter view closing
    [super viewWillAppear:animated];
    self.tableView.estimatedRowHeight = 100.0; // for example. Set your average height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (id) initWithUser: (User *)user{
    self = [super init];
    if (self) {
        self.loginUser = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (tweets == nil){
            NSString *errorMsg =  error.userInfo[@"NSLocalizedDescription"];
            [TSMessage showNotificationWithTitle:@"Newtork Error"
                                        subtitle:errorMsg //@"Please check your connection and try again later"
                                        type:TSMessageNotificationTypeWarning];
        }else{
            self.tweets = [[NSMutableArray alloc] initWithArray: tweets];
            [self.tableView reloadData];
        }
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.title = @"Home";
 
    [[SlideNavigationController sharedInstance] setNavigationBarHidden:NO animated:YES];
    
    // Menu button
    UIImage *menuImg = [Define fontImage:NIKFontAwesomeIconBars rgbaValue:0xffffff];
    UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithImage:menuImg style:UIBarButtonItemStylePlain target:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu)];
    [SlideNavigationController sharedInstance].leftBarButtonItem = menuBtn;
    
    // Compose tweet button
    UIImage *newImg = [Define fontImage:NIKFontAwesomeIconPencilSquareO rgbaValue:0xffffff];
    UIBarButtonItem *newBtn = [[UIBarButtonItem alloc] initWithImage:newImg style:UIBarButtonItemStylePlain target:self action:@selector(onNew)];
   
    self.navigationItem.rightBarButtonItem = newBtn;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
    
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[[UIColor alloc] initWithRed:0.298 green:0.646 blue:0.920 alpha:1.000]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    [self initRefreshControl];
    [self initInfiniteScroll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDestroyTweet:) name:DestroyTweetNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPostNewTweet:) name:PostNewTweetNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateTweet:) name:UpdateTweetNotification object:nil];
       
}

- (void) initInfiniteScroll {
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        [self loadMoreTweetsWithCompletionHandler:^{
             [self.tableView finishInfiniteScroll];
        }];
    }];
}

- (void)loadMoreTweetsWithCompletionHandler:(void (^)(void))completionHandler {
    NSString *lastTweetIdStr = ((Tweet *)[self.tweets lastObject]).idStr;
    long long maxIdToLoad = [lastTweetIdStr longLongValue] - 1;
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:@{@"max_id": [@(maxIdToLoad) stringValue]} completion:^(NSArray *tweets, NSError *error) {

        if (tweets.count > 0) {
            NSInteger cNumTweets = self.tweets.count;
            //self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
            [self.tweets addObjectsFromArray:tweets];
            NSMutableArray *newIndexPaths = [NSMutableArray array];
            for (NSInteger i = cNumTweets; i < self.tweets.count; i++) {
                [newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        completionHandler();
    }];
    
}


- (void) initRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.850 green:0.528 blue:0.530 alpha:1.000];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action: @selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex: 0];
}

- (void)refreshData{
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (tweets!=nil) {
            [self.tweets removeAllObjects];
            [self.tweets addObjectsFromArray:tweets];
            [self.tableView reloadData];
        }
        
        //End the refreshing
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;

        [self.refreshControl endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogout {
    [User logout];
}

- (void)onNew {
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc]initWithUser:self.loginUser];
    UINavigationController *nvController = [[UINavigationController alloc]
                              initWithRootViewController: vc];
    // nvController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nvController animated:YES completion:nil];
}


#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    switch (section) {
        case TimelineSection:
        default:
            num = self.tweets.count;
            break;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    Tweet *tweetData = self.tweets[indexPath.row];

    if ([self.loginUser.idStr isEqual:tweetData.user.idStr]) {
        // can't retweet self
        //[cell setRetweetState:-1];
        [tweetData setRetweetable:NO];
    }else{
        //[cell setRetweetState: [tweetData.retweeted integerValue]];
        [tweetData setRetweetable:YES];
    }
    
    [cell setTweet:tweetData];

    
//
//    [cell setFavoriteState: [tweetData.favorited integerValue]];
    
    cell.delegate = self;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    [view setBackgroundColor:[UIColor colorWithRed:0.951 green:0.965 blue:0.975 alpha:1.000]];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 50)];
    [lbl setFont:[UIFont boldSystemFontOfSize:15]];
    [lbl setTextColor:[UIColor grayColor]];
    [view addSubview:lbl];
    [lbl setText:[NSString stringWithFormat:@"%@", [self tableView:self.tableView titleForHeaderInSection:section]]];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.view.bounds.size.width, 1)] ;
    lineView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
    [view addSubview:lineView];

    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TimelineSection:
        default:
            return @"Timeline";
            break;
    }
}

- (void) didUserSelected: (User *) user {
    ProfileViewController *vc = [[ProfileViewController alloc]initWithUser:user andLoginUser: self.loginUser];
    UINavigationController *nvController = [[UINavigationController alloc]
                                            initWithRootViewController: vc];
    [self presentViewController:nvController animated:YES completion:nil];
}

- (void)didTapCellReply:(Tweet *)tweet
{
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc]initWithUser:self.loginUser andTweet:tweet];
    UINavigationController *nvController = [[UINavigationController alloc]
                                            initWithRootViewController: vc];
    // nvController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nvController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] initWithUser:self.loginUser andTweet:self.tweets[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Notification handler

-(NSInteger) findTweetIndexById:(NSString*)idStr {
    NSInteger index = -1;
    for (NSInteger i = 0; i<self.tweets.count; i++){
        Tweet *displayedTweet = self.tweets[i];
        if([displayedTweet.idStr isEqualToString:idStr]){
            index = i;
            break;
        }
    }
    return index;
}



- (void) onDestroyTweet:(NSNotification *)note {
    Tweet *tweet = note.userInfo[@"tweet"];
    NSInteger removeIndex = [self findTweetIndexById:tweet.idStr];
    if (removeIndex!=-1) {
        [self.tweets removeObjectAtIndex:removeIndex];
        
        // Remove row with animation
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:removeIndex inSection:0];
        NSMutableArray *arrRows = [NSMutableArray array];
        [arrRows addObject:indexPath];
        [self.tableView deleteRowsAtIndexPaths:arrRows withRowAnimation:UITableViewRowAnimationFade];
    }
    
    // or refresh tabel: [self.tableView reloadData];
    // or refeth data: [self refreshData];
    NSLog(@"onPostNewTweet %@", tweet.user.name);
}
- (void) onPostNewTweet:(NSNotification *)note {
    Tweet *tweet = note.userInfo[@"tweet"];
    [self.tweets insertObject:tweet atIndex:0];
    
    // Insert row with animation
    NSMutableArray *arrRows = [NSMutableArray array];
    [arrRows addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView insertRowsAtIndexPaths:arrRows withRowAnimation:UITableViewRowAnimationFade];

    // or refresh tabel: [self.tableView reloadData];
    // or refeth data: [self refreshData];
    NSLog(@"onPostNewTweet %@", tweet.user.name);
}
- (void) onUpdateTweet:(NSNotification *)note {
    Tweet *tweet = note.userInfo[@"tweet"];
    TweetCell *cell = note.userInfo[@"cell"];
    if (cell == nil) {
          // Update by TweetDetailView
        
          // Update for specific cell
//        NSInteger updateIndex = [self findTweetIndexById:tweet.idStr];
//        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:updateIndex inSection:0];
//        cell = (TweetCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//        if (cell) {
//            [cell updateTweet:tweet];
//        }
        
         // Update whole table
         [self.tableView reloadData];
    }

    NSLog(@"onUpdateTweet %@", tweet.user.name);
}


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


@end
