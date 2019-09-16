//
//  PlayRingTonePopupView.h
//  linphone
//
//  Created by lam quang quan on 3/15/19.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol PlayRingTonePopupViewDelegate
- (void)finishedSetRingTone: (NSString *)ringtone;
@end

@interface PlayRingTonePopupView : UIView<AVAudioPlayerDelegate>

@property (nonatomic,strong) id <NSObject, PlayRingTonePopupViewDelegate> delegate;
@property (nonatomic, strong) UILabel *lbTitle;
@property (nonatomic, strong) UIButton *btnPlay;
@property (nonatomic, strong) UIButton *btnClose;
@property (nonatomic, strong) UIButton *btnSet;
@property (nonatomic, strong) UILabel *lbSepaVertical;
@property (nonatomic, strong) UILabel *lbSepaHorzital;

- (void)setRingtoneInfoContent: (NSDictionary *)ringtone;
@property (nonatomic, strong) NSString *file;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@property (nonatomic, strong) AVAudioPlayer *player;

@end
