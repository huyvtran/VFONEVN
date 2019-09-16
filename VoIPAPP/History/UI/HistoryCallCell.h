//
//  HistoryCallCell.h
//  linphone
//
//  Created by Ei Captain on 3/1/17.
//
//

#import <UIKit/UIKit.h>

@interface HistoryCallCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbMissed;

@property (weak, nonatomic) IBOutlet UIImageView *_imgStatus;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UIButton *_btnCall;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;
@property (weak, nonatomic) IBOutlet UILabel *_lbPhone;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgDelete;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;

@property (nonatomic, assign) int idHistoryCall;
@property (nonatomic, strong) NSString *_phoneNumber;

//  [Khai le - 03/11/2018]
- (void)updateFrameForHotline: (BOOL)isHotline;

@end
