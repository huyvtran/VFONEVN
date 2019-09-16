//
//  AppTabbarViewController.m
//  VoIPAPP
//
//  Created by OS on 9/4/19.
//  Copyright © 2019 OS. All rights reserved.
//

#import "AppTabbarViewController.h"
#import "DialerViewController.h"
#import "CallsHistoryViewController.h"
#import "ContactsViewController.h"
#import "MoreViewController.h"

@interface AppTabbarViewController (){
    AppDelegate *appDelegate;
    UIColor *actColor;
    
    DialerViewController *dialerVC;
    CallsHistoryViewController *historyVC;
    ContactsViewController *contactsVC;
    MoreViewController *moreVC;
    
    UITabBarItem *historyItem;
}

@end

@implementation AppTabbarViewController
@synthesize tabBarController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    actColor = [UIColor colorWithRed:(58/255.0) green:(75/255.0) blue:(101/255.0) alpha:1.0];
    
    tabBarController = [[UITabBarController alloc] init];
    [self setupUIForView];
    
    
    UIFont *itemFont = [UIFont fontWithName:HelveticaNeue size:12.5];
    
    //  Tabbar Dialer
    dialerVC = [[DialerViewController alloc] initWithNibName:@"DialerViewController" bundle:nil];
    UINavigationController *dialerNav = [[UINavigationController alloc] initWithRootViewController: dialerVC];
    
    UIImage *imgDialer = [UIImage imageNamed:@"menu_dialer_def"];
    imgDialer = [imgDialer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *imgDialerAct = [UIImage imageNamed:@"menu_dialer_act"];
    imgDialerAct = [imgDialerAct imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *dialerItem = [[UITabBarItem alloc] initWithTitle:text_menu_dialer image:imgDialer selectedImage:imgDialerAct];
    [dialerItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [dialerItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_DEFAULT_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [dialerItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_ACTIVE_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    dialerNav.tabBarItem = dialerItem;
    
    //  Tabbar history
    historyVC = [[CallsHistoryViewController alloc] initWithNibName:@"CallsHistoryViewController" bundle:nil];
    UINavigationController *historyNav = [[UINavigationController alloc] initWithRootViewController: historyVC];
    
    UIImage *imgHistory = [UIImage imageNamed:@"menu_history_def"];
    imgHistory = [imgHistory imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *imgHistoryAct = [UIImage imageNamed:@"menu_history_act"];
    imgHistoryAct = [imgHistoryAct imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    historyItem = [[UITabBarItem alloc] initWithTitle:text_menu_history image:imgHistory selectedImage:imgHistoryAct];
    [historyItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [historyItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_DEFAULT_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [historyItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_ACTIVE_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    historyNav.tabBarItem = historyItem;
    
    //  Tabbar contacts
    contactsVC = [[ContactsViewController alloc] initWithNibName:@"ContactsViewController" bundle:nil];
    UINavigationController *contactsNav = [[UINavigationController alloc] initWithRootViewController: contactsVC];
    
    UIImage *imgContacts = [UIImage imageNamed:@"menu_contacts_def"];
    imgContacts = [imgContacts imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *imgContactsAct = [UIImage imageNamed:@"menu_contacts_act"];
    imgContactsAct = [imgContactsAct imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *contactsItem = [[UITabBarItem alloc] initWithTitle:text_menu_contacts image:imgContacts selectedImage:imgContactsAct];
    [contactsItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [contactsItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_DEFAULT_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [contactsItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_ACTIVE_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    contactsNav.tabBarItem = contactsItem;
    
    //  Tabbar More
    moreVC = [[MoreViewController alloc] initWithNibName:@"MoreViewController" bundle:nil];
    UINavigationController *moreNav = [[UINavigationController alloc] initWithRootViewController: moreVC];
    
    UIImage *imgMore = [UIImage imageNamed:@"menu_more_def"];
    imgMore = [imgMore imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *imgMoreAct = [UIImage imageNamed:@"menu_more_act"];
    imgMoreAct = [imgMoreAct imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *moreItem = [[UITabBarItem alloc] initWithTitle:text_menu_more image:imgMore selectedImage:imgMoreAct];
    [moreItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [moreItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_DEFAULT_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [moreItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_ACTIVE_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    moreNav.tabBarItem = moreItem;
    
    //  tabBarController.viewControllers = @[homeNav, boNav , transHisNav, moreNav];
    tabBarController.viewControllers = @[dialerNav, historyNav, contactsNav, moreNav];
    [self.view addSubview: tabBarController.view];
    
    tabBarController.selectedIndex = 0;
    
    [self updateNumBadgeForMissedCall];
    [self registerObservers];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    appDelegate.hNav = dialerVC.navigationController.navigationBar.frame.size.height;
}

- (void)setupUIForView {
    tabBarController.tabBar.tintColor = [UIColor colorWithRed:(58/255.0) green:(75/255.0) blue:(101/255.0) alpha:1.0];
    tabBarController.tabBar.barTintColor = UIColor.whiteColor;
    tabBarController.tabBar.backgroundColor = UIColor.whiteColor;
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNumBadgeForMissedCall)
                                                 name:updateMissedCallBadge object:nil];
}

- (void)updateNumBadgeForMissedCall {
    if ([AppUtil isNullOrEmpty: USERNAME] || [AppUtil isNullOrEmpty: PASSWORD]) {
        historyItem.badgeValue = nil;
        return;
    }
    int missedCall = [DatabaseUtil getUnreadMissedCallHisotryWithAccount: USERNAME];
    if (missedCall > 0) {
        historyItem.badgeValue = [NSString stringWithFormat:@"%d", missedCall];
    }else {
        historyItem.badgeValue = nil;
    }
}

@end
