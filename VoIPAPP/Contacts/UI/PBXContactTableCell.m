//
//  PBXContactTableCell.m
//  linphone
//
//  Created by admin on 12/14/17.
//

#import "PBXContactTableCell.h"

@implementation PBXContactTableCell
@synthesize _imgAvatar, _lbName, _lbPhone, _lbSepa, icCall, icVideoCall;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.clipsToBounds = TRUE;
    
    float marginLeft;
    float marginRight;
    if (IS_IPHONE || IS_IPOD) {
        marginRight = 15.0;
        marginLeft = 15.0;
    }else{
        marginRight = 15.0;
        marginLeft = 15.0;
    }

    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = 45.0/2;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(marginLeft);
        make.width.height.mas_equalTo(45.0);
    }];
    
    [icCall setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
    icCall.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [icCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self).offset(-marginRight);
        make.width.height.mas_equalTo(40.0);
    }];
    
    [icVideoCall setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
    icVideoCall.imageEdgeInsets = icCall.imageEdgeInsets;
    [icVideoCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(icCall.mas_left).offset(-5.0);
        make.width.equalTo(icCall.mas_width);
        make.height.equalTo(icCall.mas_height);
    }];
    
    _lbName.font = [AppDelegate sharedInstance].fontNormalMedium;
    _lbName.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar);
        make.left.equalTo(_imgAvatar.mas_right).offset(10);
        make.right.equalTo(icVideoCall.mas_left).offset(-10);
        make.bottom.equalTo(_imgAvatar.mas_centerY);
    }];
    
    _lbPhone.font = [AppDelegate sharedInstance].fontSmallRegular;
    [_lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbName.mas_bottom);
        make.left.right.equalTo(_lbName);
        make.bottom.equalTo(_imgAvatar);
    }];
    
    _lbSepa.backgroundColor = GRAY_240;
    [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (!IS_IPHONE && !IS_IPOD) {
        if (selected) {
            self.backgroundColor = GRAY_230;
        }else{
            self.backgroundColor = UIColor.whiteColor;
        }
    }
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = GRAY_230;
    }else{
        if (IS_IPHONE || IS_IPOD) {
            self.backgroundColor = UIColor.clearColor;
        }else{
            self.backgroundColor = UIColor.whiteColor;
        }
    }
}

@end
