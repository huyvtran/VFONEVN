//
//  HistoryCallDetailTableViewCell.m
//  linphone
//
//  Created by lam quang quan on 3/14/19.
//

#import "HistoryCallDetailTableViewCell.h"

@implementation HistoryCallDetailTableViewCell
@synthesize imgCallType, lbCallState, imgDirection, lbDate, lbTime, imgDuration, lbDuration, lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    float padding = 8.0;
    float wDate = 90.0;
    
    lbCallState.font = [AppDelegate sharedInstance].fontSmallBold;
    lbCallState.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [lbCallState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_centerY).offset(-2.5);
        make.left.equalTo(self).offset(padding + 20.0 + padding);
        make.right.equalTo(self).offset(-padding);
        make.height.mas_equalTo(25.0);
    }];
    
    [imgCallType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(padding);
        make.centerY.equalTo(lbCallState.mas_centerY);
        make.width.height.mas_equalTo(20.0);
    }];
    
    lbDate.font = [AppDelegate sharedInstance].fontSmallRegular;
    lbDate.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [lbDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_centerY).offset(2.5);
        make.left.equalTo(lbCallState);
        make.width.mas_equalTo(wDate);
        make.height.mas_equalTo(25.0);
    }];
    
    [imgDirection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imgCallType.mas_centerX);
        make.centerY.equalTo(lbDate.mas_centerY);
        make.width.height.mas_equalTo(16.0);
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
