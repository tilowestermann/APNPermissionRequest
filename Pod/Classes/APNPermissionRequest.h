//
//  APNPermissionRequest.h
//  PushNotificationOptions
//
//  Created by Tilo Westermann on 05/02/15.
//  Copyright (c) 2015 Quality and Usability Lab, Telekom Innovation Laboratories, TU Berlin. All rights reserved.
//

#import <UIKit/UIKit.h>


/** The `APNPermissionRequest` class enables showing an explanatory message
 * highlighting the nature of notifications the user may expect. Default push
 * notification requests leave the user to make a rather uninformed choice.
 *
 *
 * Additionally, options, which may otherwise be changed in the settings app, 
 * may be included to enable the user to instantly state her preferred modality.
 */
@interface APNPermissionRequest : NSObject

/** 
 * The enumeration of possible authorization statuses
 */
typedef NS_ENUM(NSInteger, APNAuthorizationStatus) {
    APNAuthorizationStatusUnDetermined, /**< Permission status undetermined. */
    APNAuthorizationStatusDenied, /**< Permission denied. */
    APNAuthorizationStatusAuthorized /**< Permission authorized. */
};

/**
 * The enumeration of the available options for notifications
 */
typedef NS_OPTIONS(NSUInteger, APNType) {
    APNTypeNone    = 0,      /**< the application may not present any UI 
                              * upon a notification being received */
    APNTypeBadge   = 1 << 0, /**< the application may badge its icon upon a 
                              * notification being received */
    APNTypeSound   = 1 << 1, /**< the application may play a sound upon a 
                              * notification being received */
    APNTypeAlert   = 1 << 2, /**< the application may display an alert upon a
                              * notification being received */
};

/**
 * The enumeration of possible permission dialog results
 */
typedef NS_ENUM(NSInteger, APNPermissionRequestDialogResult) {
    APNPermissionRequestDialogResultNoActionTaken, /**< User was not given the 
                                                    * chance to take action.
                                                    * This can happen if the 
                                                    * permission was
                                                    * already granted, denied, 
                                                    * or restricted. */
    APNPermissionRequestDialogResultDenied, /**< User declined access in the 
                                             user dialog or system dialog. */
    APNPermissionRequestDialogResultGranted /**< User granted access in the user 
                                             * dialog or system dialog. */
};

/**
 * The handler called upon accepting or denying the actual push notification 
 * request
 */
typedef void (^APNPermissionRequestCompletionHandler)(BOOL hasPermission,
                                                      APNPermissionRequestDialogResult userDialogResult,
                                                      APNPermissionRequestDialogResult systemDialogResult);

/**
 * Creates and returns an `APNPermissionRequest` object.
 */
+ (instancetype)sharedRequest;

/**
 * @return The current authorization status
 */
+ (APNAuthorizationStatus)authorizationStatus;

/**
 * @return the enabled notification setting
 */
+ (APNType)enabledType;

/**
 * @return a list of enabled notification settings
 *
 * @see +enabledType
 */
+ (NSArray *)enabledTypeNames;

/*! Displays a push notification request with an explanatory message and options
 * @param requestedType The APNType to request (badge, sound, alert)
 * @param requestTitle The title to show
 * @param message A message, ideally containg the nature of notifications to expect
 * @param denyButtonTitle The title for the button to deny the request
 * @param grantButtontTitle The title for the button to accept the request
 * @param completionHandler The handler called upon accepting or denying the request
 */
- (void)showWithType:(APNType)requestedType
               title:(NSString *)requestTitle
             message:(NSString *)message
        optionsTitle:(NSString *)optionsTitle
     denyButtonTitle:(NSString *)denyButtonTitle
    grantButtonTitle:(NSString *)grantButtonTitle
    completionHandler:(APNPermissionRequestCompletionHandler)completionHandler;

/*! Displays a push notification request with an explanatory message
 * @param requestedType The APNType to request (badge, sound, alert)
 * @param requestTitle The title to show
 * @param message A message, ideally containg the nature of notifications to expect
 * @param denyButtonTitle The title for the button to deny the request
 * @param grantButtontTitle The title for the button to accept the request
 * @param completionHandler The handler called upon accepting or denying the request
 */
- (void)showWithType:(APNType)requestedType
               title:(NSString *)requestTitle
             message:(NSString *)message
     denyButtonTitle:(NSString *)denyButtonTitle
    grantButtonTitle:(NSString *)grantButtonTitle
   completionHandler:(APNPermissionRequestCompletionHandler)completionHandler;

/*! Displays a fullscreen push notification request with an explanatory message and options
 * @param requestedType The APNType to request (badge, sound, alert)
 * @param requestTitle The title to show
 * @param message A message, ideally containg the nature of notifications to expect
 * @param optionsTitle The title for the options, e.g. notification settings
 * @param denyButtonTitle The title for the button to deny the request
 * @param grantButtontTitle The title for the button to accept the request
 * @param completionHandler The handler called upon accepting or denying the request
 */
- (void)showFullscreenWithType:(APNType)requestedType
                         title:(NSString *)requestTitle
                       message:(NSAttributedString *)message
                  optionsTitle:(NSString *)optionsTitle
               denyButtonTitle:(NSString *)denyButtonTitle
              grantButtonTitle:(NSString *)grantButtonTitle
             completionHandler:(APNPermissionRequestCompletionHandler)completionHandler;


/*! Displays the default push notification request
 * @param requestedType The APNType to request (badge, sound, alert)
 * @param completionHandler The handler called upon accepting or denying the request
 */
- (void)showDefaultRequestWithType:(APNType)requestedType
                 completionHandler:(APNPermissionRequestCompletionHandler)completionHandler;

/**
 * Indicates whether or not the list of notification settings should be
 * collapsed
 */
@property (assign, nonatomic) BOOL collapsed;

/**
 * Background color for the fullscreen request, defaults to lightGrayColor
 */
@property (strong, nonatomic) UIColor *backgroundColor;

@end