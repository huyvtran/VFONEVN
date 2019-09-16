//
//  HistoryCallDetailTableViewCell.h
//  linphone
//
//  Created by lam quang quan on 3/14/19.
//

#import <UIKit/UIKit.h>

@interface HistoryCallDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgCallType;
@property (weak, nonatomic) IBOutlet UILabel *lbCallState;
@property (weak, nonatomic) IBOutlet UIImageView *imgDirection;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgDuration;
@property (weak, nonatomic) IBOutlet UILabel *lbDuration;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;

@end
