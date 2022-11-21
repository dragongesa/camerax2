#import "CameraXPlugin.h"
#if __has_include(<camerax2/camerax2-Swift.h>)
#import <camerax2/camerax2-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "camerax2-Swift.h"
#endif

@implementation CameraXPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCameraXPlugin registerWithRegistrar:registrar];
}
@end
