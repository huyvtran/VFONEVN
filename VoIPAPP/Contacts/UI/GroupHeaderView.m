//
//  GroupHeaderView.m
//  linphone
//
//  Created by admin on 5/16/19.
//

#import "GroupHeaderView.h"

@implementation GroupHeaderView
@synthesize lbTitle, icSort, lbSepa, sortAscending;

- (void)setupUIForView {
    self.backgroundColor = UIColor.whiteColor;
    
    icSort.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [icSort mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    lbTitle.font = [AppDelegate sharedInstance].fontNormalRegular;
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icSort.mas_right).offset(5.0);
        make.top.bottom.equalTo(icSort);
        make.right.equalTo(self).offset(-5.0);
    }];
    
    lbSepa.backgroundColor = GRAY_240;
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    
    lbTitle.textColor = [UIColor colorWithRed:(60/255.0) green:(75/255.0) blue:(102/255.0) alpha:1.0];
}

- (IBAction)icSortClick:(UIButton *)sender {
}

- (void)updateUIWithCurrentInfo {
    NSNumber *sort = [[NSUserDefaults standardUserDefaults] objectForKey:sort_group];
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
