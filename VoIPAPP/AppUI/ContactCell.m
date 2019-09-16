//
//  ContactCell.m
//  linphone
//
//  Created by user on 13/5/14.
//
//

#import "ContactCell.h"

@implementation ContactCell
@synthesize name, phone, image, strCallnexId, avatarStr, _lbSepa, icCall;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    float marginLeft = 15.0;
    float marginRight = 15.0;
    
    icCall.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    image.clipsToBounds = YES;
    image.layer.cornerRadius = 45.0/2;
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(marginLeft);
        make.width.height.mas_equalTo(45.0);
    }];
    
    [icCall setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
    [icCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self).offset(-marginRight);
        make.width.height.mas_equalTo(40.0);
    }];
    
    name.font = [AppDelegate sharedInstance].fontNormalMedium;
    name.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(image);
        make.left.equalTo(image.mas_right).offset(10.0);
        make.right.equalTo(icCall).offset(-10.0);
        make.bottom.equalTo(image.mas_centerY);
    }];
    
    phone.font = [AppDelegate sharedInstance].fontSmallRegular;
    phone.textColor = UIColor.grayColor;
    [phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(name.mas_bottom);
        make.left.right.equalTo(name);
        make.bottom.equalTo(image.mas_bottom);
    }];
    
    _lbSepa.backgroundColor = GRAY_235;
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
        self.backgroundColor = GRAY_245;
    }else{
        if (IS_IPHONE || IS_IPOD) {
            self.backgroundColor = UIColor.clearColor;
        }else{
            self.backgroundColor = UIColor.whiteColor;
        }
    }
}

@end
