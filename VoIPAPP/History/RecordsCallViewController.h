//
//  RecordsCallViewController.h
//  linphone
//
//  Created by lam quang quan on 3/25/19.
//

#import <UIKit/UIKit.h>

@interface RecordsCallViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lbStartTime;
@property (weak, nonatomic) IBOutlet UITextField *tfStartTime;
@property (weak, nonatomic) IBOutlet UIButton *btnStartTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrowStart;

@property (weak, nonatomic) IBOutlet UILabel *lbEndTime;
@property (weak, nonatomic) IBOutlet UITextField *tfEndTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrowEnd;
@property (weak, nonatomic) IBOutlet UIButton *btnEndTime;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UITableView *tbListCall;
@property (weak, nonatomic) IBOutlet UILabel *lbNoData;
@property (weak, nonatomic) IBOutlet UIButton *btnListFiles;

- (IBAction)btnStartTimePress:(UIButton *)sender;
- (IBAction)btnEndTimePress:(UIButton *)sender;
- (IBAction)btnSearchPress:(UIButton *)sender;
- (IBAction)btnListFilesPress:(UIButton *)sender;

@end
