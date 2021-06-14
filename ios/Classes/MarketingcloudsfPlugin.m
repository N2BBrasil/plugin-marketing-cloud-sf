#import "MarketingcloudsfPlugin.h"
#if __has_include(<marketingcloudsf/marketingcloudsf-Swift.h>)
#import <marketingcloudsf/marketingcloudsf-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "marketingcloudsf-Swift.h"
#endif

@implementation MarketingcloudsfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMarketingcloudsfPlugin registerWithRegistrar:registrar];
}
@end
