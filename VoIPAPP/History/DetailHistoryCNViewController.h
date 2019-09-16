//
//  DetailHistoryCNViewController.h
//  linphone
//
//  Created by user on 18/3/14.
//
//

#import <UIKit/UIKit.h>

@interface DetailHistoryCNViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *icDelete;

@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;

@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UIButton *iconAudio;

@property (weak, nonatomic) IBOutlet UITableView *_tbHistory;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)icDeleteClick:(UIButton *)sender;
- (IBAction)iconAudioClick:(UIButton *)sender;

@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, strong) NSString *onDate;
@property (nonatomic, assign) BOOL onlyMissedCall;

- (void)setPhoneNumberForView:(NSString *)phone andDate: (NSString *)date onlyMissed: (BOOL)onlyMissed;

@end
