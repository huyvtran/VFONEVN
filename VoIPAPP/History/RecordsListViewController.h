//
//  RecordsListViewController.h
//  linphone
//
//  Created by lam quang quan on 3/27/19.
//

#import <UIKit/UIKit.h>

@interface RecordsListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *icBack;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *icChoose;
@property (weak, nonatomic) IBOutlet UITableView *tbList;
- (IBAction)icBackClick:(UIButton *)sender;
- (IBAction)icChoosePress:(UIButton *)sender;

@end
