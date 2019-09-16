//
//  PBXHeaderView.m
//  linphone
//
//  Created by admin on 5/18/19.
//

#import "PBXHeaderView.h"
#import "CustomTextAttachment.h"

@implementation PBXHeaderView
@synthesize lbTitle, btnSync, icSort, sortAscending;
@synthesize delegate;

- (void)setupUIForView {
    self.backgroundColor = UIColor.whiteColor;
    
    icSort.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [icSort mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    lbTitle.font = [AppDelegate sharedInstance].fontNormalRegular;
    lbTitle.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icSort.mas_right).offset(5.0);
        make.top.bottom.equalTo(icSort);
        make.right.equalTo(self.mas_centerX).offset(50);
    }];
    
    [btnSync setAttributedTitle:[self getSyncTitleContentWithFont:[AppDelegate sharedInstance].fontNormalRegular andSizeIcon:17.0] forState:UIControlStateNormal];
    [btnSync mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15.0);
        make.top.bottom.equalTo(lbTitle);
        make.left.equalTo(lbTitle.mas_right);
    }];
}

- (IBAction)btnSyncPress:(UIButton *)sender {
    [delegate onSyncButtonPress];
}

- (IBAction)icSortClick:(UIButton *)sender {
    [delegate onIconSortClick];
}

- (NSAttributedString *)getSyncTitleContentWithFont: (UIFont *)textFont andSizeIcon: (float)size
{
    CustomTextAttachment *attachment = [[CustomTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"sync.png"];
    [attachment setImageHeight: size];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:@"  Đồng bộ"];
    [contentString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, contentString.length)];
    [contentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0] range:NSMakeRange(0, contentString.length)];
    
    NSMutableAttributedString *verString = [[NSMutableAttributedString alloc] initWithAttributedString: attachmentString];
    //
    [verString appendAttributedString: contentString];
    return verString;
}

- (void)updateUIWithCurrentInfo {
    NSNumber *sort = [[NSUserDefaults standardUserDefaults] objectForKey:sort_pbx];
    if ([sort intValue] == eSortAZ) {
        [icSort setImage:[UIImage imageNamed:@"sort-az"] forState:UIControlStateNormal];
        sortAscending = TRUE;
        
    }else if ([sort intValue] == eSortZA) {
        [icSort setImage:[UIImage imageNamed:@"sort-za"] forState:UIControlStateNormal];
        sortAscending = FALSE;
        
    }else if ([sort intValue] == eSort19) {
        [icSort setImage:[UIImage imageNamed:@"sort-19"] forState:UIControlStateNormal];
        sortAscending = TRUE;
        
    }else{
        [icSort setImage:[UIImage imageNamed:@"sort-91"] forState:UIControlStateNormal];
        sortAscending = FALSE;
    }
}

@end
