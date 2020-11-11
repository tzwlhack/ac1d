#import "rocketbootstrap.h"

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
-(BOOL)_sendMediaCommand:(unsigned)command;
-(float)volume;
@end

@interface SBIcon : NSObject
	
-(NSString *)nodeIdentifier;

@end

@interface SBApplicationIcon : SBIcon
	
@end

@interface SBIconController : NSObject

-(id)lastTouchedIcon;

@end

@interface SBUserAgent : NSObject

+(id)sharedUserAgent;
-(void)lockAndDimDevice;
-(void)handleMenuDoubleTap;
-(void)clickedMenuButton;
-(bool)handleHomeButtonSinglePressUp;
-(bool)handleHomeButtonDoublePressDown;

@end


@interface SBDeviceLockController : NSObject

+(id)sharedController;
-(void)_clearBlockedState;
-(BOOL)isPasscodeLocked;

@end

@interface CLLocationManager : NSObject

+(void)setLocationServicesEnabled:(BOOL)arg1;

@end

@interface SBLockScreenManager : NSObject

@property (nonatomic, readonly) BOOL isUILocked;

+(id)sharedInstance;

@end

@interface SBHUDController : NSObject

+(id)sharedInstance;
-(void)hideHUD;
-(void)showHUD;

@end

@interface VolumeControl : NSObject

+(id)sharedVolumeControl;
-(void)toggleMute;

@end
