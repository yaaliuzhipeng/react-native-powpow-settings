// PowpowSettings.h

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PowpowSettingsViewController.h"

@interface PowpowSettings : RCTEventEmitter <RCTBridgeModule>

+ (UIInterfaceOrientationMask) getOrientation;
+ (void) setOrientation: (UIInterfaceOrientationMask)orientation;
+ (void) emitEvent:(NSDictionary *)payload;

@end
