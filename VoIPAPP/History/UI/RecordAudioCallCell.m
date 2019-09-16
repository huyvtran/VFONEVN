//
//  RecordAudioCallCell.m
//  linphone
//
//  Created by lam quang quan on 3/27/19.
//

#import "RecordAudioCallCell.h"

@implementation RecordAudioCallCell
@synthesize lbName, btnChoose, lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (SCREEN_WIDTH > 320) {
        btnChoose.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    }else{
        btnChoose.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    
    lbName.numberOfLines = 5;
    lbName.textColor = UIColor.darkGrayColor;
    lbName.font = [AppDelegate sharedInstance].fontNormalRegular;
    
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

- (void)updateFrameForEdit: (BOOL)edit {
    if (edit) {
        btnChoose.hidden = NO;
        [btnChoose mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).mas_offset(-10.0);
            make.centerY.equalTo(self.mas_centerY);
            make.width.height.mas_equalTo(40.0);
        }];
        
        [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.equalTo(self);
            make.left.equalTo(self).offset(10.0);
            make.right.equalTo(btnChoose.mas_left).offset(-10.0);
        }];
        
        lbSepa.backgroundColor = GRAY_240;
        [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(1.0);
        }];
        
    }else{
        btnChoose.hidden = YES;
        [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.equalTo(self);
            make.left.equalTo(self).offset(10.0);
            make.right.equalTo(self).offset(-10.0);
        }];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = GRAY_230;
    }else{
        self.backgroundColor = UIColor.whiteColor;
    }
}

@end
