//
//  NewHistoryDetailCell.m
//  linphone
//
//  Created by lam quang quan on 11/13/18.
//

#import "NewHistoryDetailCell.h"

@implementation NewHistoryDetailCell
@synthesize imgStatus, lbDate, lbTime, lbDuration, lbState, lbSepa, imgDuration;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    lbState.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    lbState.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [lbState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_centerY);
        make.left.equalTo(imgStatus.mas_right).offset(8.0);
        make.right.equalTo(self).offset(-18.0 - 8.0);
        make.height.mas_equalTo(25.0);
    }];
    
    [imgStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10.0);
        make.centerY.equalTo(lbState.mas_centerY);
        make.width.height.mas_equalTo(18.0);
    }];
    
    lbDate.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
    lbDate.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [lbDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbState.mas_bottom);
        make.left.equalTo(lbState);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(25.0);
    }];
    
    lbTime.font = lbDate.font;
    lbTime.textAlignment = NSTextAlignmentCenter;
    lbTime.textColor = lbDate.textColor;
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbDate);
        make.left.equalTo(lbDate.mas_right);
        make.width.mas_equalTo(80);
    }];
    
    [imgDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lbTime.mas_centerY);
        make.left.equalTo(lbTime.mas_right).offset(1.0);
        make.width.height.mas_equalTo(14.0);
    }];
    
    lbDuration.font = lbTime.font;
    lbDuration.textColor = lbTime.textColor;
    [lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbTime);
        make.right.equalTo(self).offset(-8.0);
        make.left.equalTo(imgDuration.mas_right).offset(3.0);
    }];
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                              blue:(240/255.0) alpha:1.0];
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
