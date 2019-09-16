//
//  ContactsViewController.h
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UIViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource, UITextFieldDelegate>

@property (nonatomic, retain) UIPageViewController *_pageViewController;

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconAll;
@property (weak, nonatomic) IBOutlet UIButton *_iconPBX;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa2;
@property (weak, nonatomic) IBOutlet UIButton *icGroupPBX;


@property (weak, nonatomic) IBOutlet UITextField *_tfSearch;
@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UIButton *_icClearSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;

- (IBAction)_iconAllClicked:(id)sender;
- (IBAction)_iconPBXClicked:(UIButton *)sender;
- (IBAction)_icClearSearchClicked:(UIButton *)sender;
- (IBAction)iconGroupPBXPress:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *_listSyncContact;
@property (nonatomic, strong) NSString *_phoneForSync;

@end
