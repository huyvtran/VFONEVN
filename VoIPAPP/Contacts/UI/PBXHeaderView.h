//
//  PBXHeaderView.h
//  linphone
//
//  Created by admin on 5/18/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PBXHeaderViewDelegate
- (void)onIconSortClick;
- (void)onSyncButtonPress;
@end

@interface PBXHeaderView : UIView
@property (nonatomic, strong) id<NSObject, PBXHeaderViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnSync;
@property (weak, nonatomic) IBOutlet UIButton *icSort;

@property (nonatomic, assign) BOOL sortAscending;

- (IBAction)btnSyncPress:(UIButton *)sender;
- (IBAction)icSortClick:(UIButton *)sender;
- (void)setupUIForView ;
- (void)updateUIWithCurrentInfo;


@end

NS_ASSUME_NONNULL_END
