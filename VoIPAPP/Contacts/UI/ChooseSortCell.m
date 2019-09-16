//
//  ChooseSortCell.m
//  linphone
//
//  Created by admin on 5/18/19.
//

#import "ChooseSortCell.h"

@implementation ChooseSortCell
@synthesize lbName, lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    lbName.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    lbName.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5.0);
        make.right.equalTo(self).offset(-5.0);
        make.top.bottom.equalTo(self);
    }];
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
