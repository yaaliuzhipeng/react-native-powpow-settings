// PowpowSettings.m

#import "PowpowSettings.h"


@implementation PowpowSettings
{
    int orientationValue;
    MPVolumeView *mpv;
    UISlider *vvslider;
}

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"onOrientationChanged"];
}

-(void)startObserving {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_emitEvent:) name:@"emitEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}
-(void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) _emitEvent:(NSNotification *)notification {
    NSString *eventName = [notification.userInfo objectForKey:@"event-name"];
    NSDictionary *body = [notification.userInfo objectForKey:@"body"];
    [self sendEventWithName:eventName body:body];
}
- (void)_deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    int orientationValue = [self getOrientationIntValue:orientation];
    NSDictionary *payload = @{
        @"event-name":@"onOrientationChanged",
        @"body":@{
                @"orientation": [NSNumber numberWithInt:orientationValue]
        }
    };
    [PowpowSettings emitEvent:payload];
}
+(void)emitEvent:(NSDictionary *)payload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"emitEvent" object:nil userInfo:payload];
}

+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
    _orientation = orientation;
}

+ (UIInterfaceOrientationMask)getOrientation {
    return _orientation;
}

- (int)getOrientationIntValue: (UIDeviceOrientation)orientation {
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  switch (interfaceOrientation) {
    case UIInterfaceOrientationPortrait:
      orientationValue = 1;
      break;
    case UIInterfaceOrientationPortraitUpsideDown:
      orientationValue = 2;
      break;
    case UIInterfaceOrientationLandscapeLeft:
      orientationValue = 3;
    case UIInterfaceOrientationLandscapeRight:
      orientationValue = 4;
      break;
    default:
      orientationValue = 0;
  }
  // [[UIApplication sharedApplication] statusBarOrientation]; //UIInterfaceOrientationPortraitÏ
  return orientationValue;
}

RCT_EXPORT_METHOD(setOrientation: (NSNumber *) orientation)
{
  switch (orientation.intValue) {
    case 0:
      [PowpowSettings setOrientation:UIInterfaceOrientationMaskAll];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
          [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationMaskAll] forKey:@"orientation"];
          [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      }];
      break;
    case 1:
      [PowpowSettings setOrientation:UIInterfaceOrientationMaskPortrait];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
          [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
          [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      }];
      break;
    case 2:
      [PowpowSettings setOrientation:UIInterfaceOrientationMaskPortraitUpsideDown];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
          [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortraitUpsideDown] forKey:@"orientation"];
          [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      }];
      break;
    case 3:
      [PowpowSettings setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
          [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
          [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      }];
    case 4:
      [PowpowSettings setOrientation:UIInterfaceOrientationMaskLandscapeRight];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
          [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
          [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      }];
    default:
      break;
  }
}
RCT_EXPORT_METHOD(getOrientation: (RCTResponseSenderBlock) callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  int orientationValue = [self getOrientationIntValue:orientation];
  callback(@[@{@"value":[NSNumber numberWithInt:orientationValue]}]);
}
RCT_EXPORT_METHOD(setMediaVolume: (double) volume callback:(RCTResponseSenderBlock) callback)
{
  dispatch_sync(dispatch_get_main_queue(), ^{
    if(mpv == nil) {
      mpv = [MPVolumeView new];
    }
    for (UIView *view in mpv.subviews) {
      if ([view isKindOfClass:[UISlider class]]) {
        vvslider = (UISlider *)view;
        break;
      }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self->vvslider.value = MIN(MAX(volume, 0),1);
    });
  });
}
RCT_EXPORT_METHOD(getMediaVolume: (RCTResponseSenderBlock) callback)
{
  callback(@[@{@"value": [NSNumber numberWithFloat:[vvslider value]]}]);
}
RCT_EXPORT_METHOD(setAppScreenBrightness: (double) brightness)
{
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[UIScreen mainScreen] setBrightness:(CGFloat)brightness];
  });
}
RCT_EXPORT_METHOD(getAppScreenBrightness: (RCTResponseSenderBlock) callback)
{
  callback(@[@{@"value": [NSNumber numberWithDouble:[UIScreen mainScreen].brightness]}]);
}
RCT_EXPORT_METHOD(setRealFullscreen:(BOOL) fullscreen)
{
  UIViewController *rootvc = [UIApplication sharedApplication].delegate.window.rootViewController;
  if ([rootvc isKindOfClass:[PowpowSettingsViewController class]]) {
    PowpowSettingsViewController *vc = (PowpowSettingsViewController *)rootvc;
    vc.autoHidden = fullscreen;
    if (@available (iOS 11.0,*)){
      [vc setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
  }
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
