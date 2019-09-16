//
//  GroupHeaderView.h
//  linphone
//
//  Created by admin on 5/16/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *icSort;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;
@property (nonatomic, assign) BOOL sortAscending;

- (IBAction)icSortClick:(UIButton *)sender;

- (void)setupUIForView;
- (void)updateUIWithCurrentInfo;

@end

NS_ASSUME_NONNULL_END
