#import "CronetPlugin.h"
#import "../../src/wrapper.h"

@implementation CronetPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"cronet"
            binaryMessenger:[registrar messenger]];
  CronetPlugin* instance = [[CronetPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    NSString *version = [NSString stringWithCString:VersionString() encoding:NSUTF8StringEncoding];
    result(version);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
