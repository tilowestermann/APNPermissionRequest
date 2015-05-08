# APNPermissionRequest

[![CI Status](http://img.shields.io/travis/Tilo Westermann/APNPermissionRequest.svg?style=flat)](https://travis-ci.org/Tilo Westermann/APNPermissionRequest)
[![Version](https://img.shields.io/cocoapods/v/APNPermissionRequest.svg?style=flat)](http://cocoadocs.org/docsets/APNPermissionRequest)
[![License](https://img.shields.io/cocoapods/l/APNPermissionRequest.svg?style=flat)](http://cocoadocs.org/docsets/APNPermissionRequest)
[![Platform](https://img.shields.io/cocoapods/p/APNPermissionRequest.svg?style=flat)](http://cocoadocs.org/docsets/APNPermissionRequest)

APNPermissionRequest is inspired by [ClusterPrePermissions](https://github.com/clusterinc/ClusterPrePermissions).

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```objective-c
APNPermissionRequest *request = [APNPermissionRequest sharedRequest];
[request showWithType: APNTypeAlert | APNTypeSound
                title:@"\"MyApp\" would like to send push notifications."
              message:@"We'll keep you updated ..."
         optionsTitle:@"Notification settings"
      denyButtonTitle:@"Not now"
     grantButtonTitle:@"OK"
    completionHandler:^(BOOL hasPermission,
                        APNPermissionRequestDialogResult userDialogResult,
                        APNPermissionRequestDialogResult systemDialogResult) {
        NSLog(@"Permission: %d",hasPermission);
        
        NSArray *actions = @[@"no action",@"denied", @"granted"];
        NSLog(@"user action: %@",actions[userDialogResult]);
        NSLog(@"system action: %@",actions[systemDialogResult]);
    }];
```

## Requirements

[SDCAlertView](https://github.com/sberrevoets/SDCAlertView)

## Installation

APNPermissionRequest is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "APNPermissionRequest"

## Author

Tilo Westermann, tilo.westermann@tu-berlin.de

## License

APNPermissionRequest is available under the MIT license. See the LICENSE file for more info.

