//
//  CallsHistoryViewController.h
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import <UIKit/UIKit.h>

@interface CallsHistoryViewController : UIViewController

@property (nonatomic, retain) UIPageViewController *_pageViewController;
@property (nonatomic) NSInteger _vcIndex;

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *_btnEdit;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;

@property (weak, nonatomic) IBOutlet UIButton *_iconAll;
@property (weak, nonatomic) IBOutlet UIButton *_iconMissed;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa2;
@property (weak, nonatomic) IBOutlet UIButton *_iconRecord;

- (IBAction)_btnEditPressed:(id)sender;
- (IBAction)_iconAllClicked:(id)sender;
- (IBAction)_iconMissedClicked:(id)sender;
- (IBAction)_iconRecordClicked:(UIButton *)sender;

@end
