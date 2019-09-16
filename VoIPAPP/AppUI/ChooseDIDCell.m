//
//  ChooseDIDCell.m
//  linphone
//
//  Created by admin on 3/13/19.
//

#import "ChooseDIDCell.h"

@implementation ChooseDIDCell
@synthesize lbDIDNumber, lbTitle;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    lbTitle.font = lbDIDNumber.font = [AppDelegate sharedInstance].fontNormalRegular;
    lbTitle.textColor = lbDIDNumber.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    
    lbTitle.text = @"Gọi ra prefix";
    if (IS_IPHONE || IS_IPOD) {
        [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self.mas_centerX).offset(30.0);
            make.top.bottom.equalTo(self);
        }];
        
        [lbDIDNumber mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX);
            make.right.equalTo(self).offset(-20.0);
            make.top.bottom.equalTo(self);
        }];
        
    }else{
        [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20.0);
            make.right.equalTo(self.mas_centerX).offset(30.0);
            make.top.bottom.equalTo(self);
        }];
        
        [lbDIDNumber mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lbTitle.mas_right).offset(5.0);
            make.right.equalTo(self).offset(-20.0);
            make.top.bottom.equalTo(self);
        }];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = GRAY_245;
    }else{
        self.backgroundColor = UIColor.whiteColor;
    }
}

@end
