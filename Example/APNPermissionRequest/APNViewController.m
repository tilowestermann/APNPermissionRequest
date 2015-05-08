//
//  APNViewController.m
//  APNPermissionRequest
//
//  Created by Tilo Westermann on 02/10/2015.
//  Copyright (c) 2014 Tilo Westermann. All rights reserved.
//

#import "APNViewController.h"
#import <APNPermissionRequest/APNPermissionRequest.h>

@interface APNViewController ()

@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *requestTitle;
@property (nonatomic, copy) NSString *requestMessage;
@property (nonatomic, copy) NSString *requestOptionsTitle;

@end

@implementation APNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.appName = @"MyMailman";
    self.requestTitle = [NSString stringWithFormat:@"\"%@\" Would Like to Send You Notifications", self.appName];
    self.requestMessage = @"Your delivery is ready for pick-up at the post office? We'll inform you immediately via a push notification!";
    self.requestOptionsTitle = @"Notification Settings";
    
    [self performSelector:@selector(showPushNotificationRequestWithOptions)
               withObject:nil
               afterDelay:2.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showFakeDefaultPushNotificationRequest {
    APNPermissionRequest *request = [APNPermissionRequest sharedRequest];
    [request showWithType: APNTypeAlert | APNTypeSound
                    title:self.requestTitle
                  message:@"Notifications may include alerts, sounds, and icon badges. These can be configured in Settings."
          denyButtonTitle:@"Don't Allow"
         grantButtonTitle:@"OK"
        completionHandler:^(BOOL hasPermission,
                            APNPermissionRequestDialogResult userDialogResult,
                            APNPermissionRequestDialogResult systemDialogResult) {
            NSLog(@"Permission: %d",hasPermission);
            
            NSArray *actions = @[@"no action",@"denied", @"granted"];
            NSLog(@"user: %@",actions[userDialogResult]);
            NSLog(@"system: %@",actions[systemDialogResult]);
        }];
}


- (void)showPushNotificationRequestWithExplanation {
    APNPermissionRequest *request = [APNPermissionRequest sharedRequest];
    [request showWithType: APNTypeAlert | APNTypeSound
                    title:self.requestTitle
                  message:self.requestMessage
          denyButtonTitle:@"Don't Allow"
         grantButtonTitle:@"OK"
        completionHandler:^(BOOL hasPermission,
                            APNPermissionRequestDialogResult userDialogResult,
                            APNPermissionRequestDialogResult systemDialogResult) {
            NSLog(@"Permission: %d",hasPermission);
            
            NSArray *actions = @[@"no action",@"denied", @"granted"];
            NSLog(@"user: %@",actions[userDialogResult]);
            NSLog(@"system: %@",actions[systemDialogResult]);
        }];
}

- (void)showPushNotificationRequestWithCollapsedOptions {
    APNPermissionRequest *request = [APNPermissionRequest sharedRequest];
    request.collapsed = NO;

    [request showWithType: APNTypeAlert | APNTypeSound
                    title:self.requestTitle
                  message:self.requestMessage
             optionsTitle:self.requestOptionsTitle
          denyButtonTitle:@"Don't Allow"
         grantButtonTitle:@"OK"
        completionHandler:^(BOOL hasPermission,
                            APNPermissionRequestDialogResult userDialogResult,
                            APNPermissionRequestDialogResult systemDialogResult) {
            NSLog(@"Permission: %d",hasPermission);
            
            NSArray *actions = @[@"no action",@"denied", @"granted"];
            NSLog(@"user: %@",actions[userDialogResult]);
            NSLog(@"system: %@",actions[systemDialogResult]);
            
            NSLog(@"Settings: %@",[APNPermissionRequest enabledTypeNames]);
        }];
}

- (void)showPushNotificationRequestWithOptions {
    APNPermissionRequest *request = [APNPermissionRequest sharedRequest];
    request.collapsed = NO;
    [request showWithType: APNTypeAlert | APNTypeSound
                    title:self.requestTitle
                  message:self.requestMessage
             optionsTitle:self.requestOptionsTitle
          denyButtonTitle:@"Don't Allow"
         grantButtonTitle:@"OK"
        completionHandler:^(BOOL hasPermission,
                            APNPermissionRequestDialogResult userDialogResult,
                            APNPermissionRequestDialogResult systemDialogResult) {
            NSLog(@"Permission: %d",hasPermission);
            
            NSArray *actions = @[@"no action",@"denied", @"granted"];
            NSLog(@"user: %@",actions[userDialogResult]);
            NSLog(@"system: %@",actions[systemDialogResult]);
            
            NSLog(@"Settings: %@",[APNPermissionRequest enabledTypeNames]);
        }];
}


@end
