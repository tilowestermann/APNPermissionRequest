//
//  APNPermissionRequest.h
//  PushNotificationOptions
//
//  Created by Tilo Westermann on 05/02/15.
//  Copyright (c) 2015 Quality and Usability Lab, Telekom Innovation Laboratories, TU Berlin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APNPermissionRequest : NSObject

typedef NS_ENUM(NSInteger, APNAuthorizationStatus) {
    /// Permission status undetermined.
    APNAuthorizationStatusUnDetermined,
    /// Permission denied.
    APNAuthorizationStatusDenied,
    /// Permission authorized.
    APNAuthorizationStatusAuthorized
};

typedef NS_OPTIONS(NSUInteger, APNType) {
    APNTypeNone    = 0,      // the application may not present any UI upon a notification being received
    APNTypeBadge   = 1 << 0, // the application may badge its icon upon a notification being received
    APNTypeSound   = 1 << 1, // the application may play a sound upon a notification being received
    APNTypeAlert   = 1 << 2, // the application may display an alert upon a notification being received
};

typedef NS_ENUM(NSInteger, APNPermissionRequestDialogResult) {
    /// User was not given the chance to take action.
    /// This can happen if the permission was
    /// already granted, denied, or restricted.
    APNPermissionRequestDialogResultNoActionTaken,
    /// User declined access in the user dialog or system dialog.
    APNPermissionRequestDialogResultDenied,
    /// User granted access in the user dialog or system dialog.
    APNPermissionRequestDialogResultGranted
};

typedef void (^APNPermissionRequestCompletionHandler)(BOOL hasPermission,
                                                      APNPermissionRequestDialogResult userDialogResult,
                                                      APNPermissionRequestDialogResult systemDialogResult);

+ (instancetype)sharedRequest;

+ (APNAuthorizationStatus)authorizationStatus;
+ (APNType)enabledType;
+ (NSArray *)enabledTypeNames;

- (void)showWithType:(APNType)requestedType
               title:(NSString *)requestTitle
             message:(NSString *)message
        optionsTitle:(NSString *)optionsTitle
     denyButtonTitle:(NSString *)denyButtonTitle
    grantButtonTitle:(NSString *)grantButtonTitle
    completionHandler:(APNPermissionRequestCompletionHandler)completionHandler;

- (void)showWithType:(APNType)requestedType
               title:(NSString *)requestTitle
             message:(NSString *)message
     denyButtonTitle:(NSString *)denyButtonTitle
    grantButtonTitle:(NSString *)grantButtonTitle
   completionHandler:(APNPermissionRequestCompletionHandler)completionHandler;

- (void)showDefaultRequestWithType:(APNType)requestedType
                 completionHandler:(APNPermissionRequestCompletionHandler)completionHandler;

@property (retain, nonatomic) NSSet *userNotificationCategories;
@property (assign, nonatomic) BOOL collapsed;

@end