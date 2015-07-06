//
//  MenuViewController.m
//  ios-Twitter
//
//  Created by Carter Chang on 7/6/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "MenuViewController.h"

typedef NS_ENUM(NSInteger, MenuItem) {
    Profile,
    Timeline,
    Mentions,
    Logout
};

@interface MenuViewController ()  <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) User *loginUser;
@property (assign, nonatomic) MenuItem cuttentMenuItem;
@end


@implementation MenuViewController


- (id) initWithUser: (User *)user{
    self = [super init];
    if (self) {
        self.loginUser = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DefaultCell"];
    [self.headView setBackgroundColor:[[UIColor alloc] initWithRed:0.298 green:0.646 blue:0.920 alpha:1.000]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = nil;
    
    if (_cuttentMenuItem == indexPath.row) {
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
        return;
    }
    
   _cuttentMenuItem = indexPath.row;
    
    switch (indexPath.row) {
        case Profile:
            vc = [[ProfileViewController alloc] initWithUser:self.loginUser];
            break;
        case Timeline:
            vc = [[TweetsViewController alloc] initWithUser:self.loginUser andTimelineType:TIMELINE_TYPE_HOME];
            break;
        case Mentions:
            vc = [[TweetsViewController alloc] initWithUser:self.loginUser andTimelineType:TIMELINE_TYPE_MENTIONS];
            break;
        case Logout:
            [User logout];
            return;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid item" userInfo:nil];
    }
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
    cell.backgroundColor = tableView.backgroundColor;
    cell.textLabel.text = [self textForItem:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor colorWithRed:0.335 green:0.632 blue:0.916 alpha:1.000];
    return cell;
}

- (NSString *)textForItem:(MenuItem)item {
    switch (item) {
        case Profile:
            return @"Profile";
        case Timeline:
            return @"Timeline";
        case Mentions:
            return @"Mentions";
        case Logout:
            return @"Sign Out";
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid item" userInfo:nil];
    }
}


@end
