#import "PowpowSettingsViewController.h"

@implementation PowpowSettingsViewController

- (instancetype) init {
  if (self = [super init]){
    self.autoHidden = false;
  }
  return self;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
  return _autoHidden;
}
- (BOOL)prefersStatusBarHidden{
  return NO;
}

- (BOOL)shouldAutorotate {
  return true;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
 return [DeviceOrientation getOrientation];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
  return UIInterfaceOrientationPortrait;
}
@end
