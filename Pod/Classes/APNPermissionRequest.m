//
//  APNPermissionRequest.m
//  PushNotificationOptions
//
//  Created by Tilo Westermann on 05/02/15.
//  Copyright (c) 2015 Quality and Usability Lab, Telekom Innovation Laboratories, TU Berlin. All rights reserved.
//

#import "APNPermissionRequest.h"

#import <SDCAlertView/SDCAlertController.h>
#import <SDCAutoLayout/UIView+SDCAutoLayout.h>
#import <QuartzCore/QuartzCore.h>

static NSString *const APNPermissionRequestShown = @"APNPermissionRequestShown";
static NSString *const kAPNPermissionRequestBundle = @"APNPermissionRequest.bundle";
static APNPermissionRequest *__sharedInstance;

@interface APNPermissionRequest () <UITableViewDataSource, UITableViewDelegate> {
    SDCAlertController *alert;
    NSLayoutConstraint *heightConstraint;
}

@property (copy, nonatomic) APNPermissionRequestCompletionHandler completionHandler;
@property (assign, nonatomic) APNType requestedType;
@property (copy, nonatomic) NSString *optionsTitle;

@end

@implementation APNPermissionRequest

+ (instancetype)sharedRequest
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[APNPermissionRequest alloc] init];
        __sharedInstance.collapsed = YES;
    });
    return __sharedInstance;
}

+ (APNAuthorizationStatus)authorizationStatus {
    BOOL didAskForPermission = [[NSUserDefaults standardUserDefaults] boolForKey:APNPermissionRequestShown];
    
    if (didAskForPermission) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            // iOS8+
            if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
                return APNAuthorizationStatusAuthorized;
            } else {
                return APNAuthorizationStatusDenied;
            }
        } else {
            if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
                return APNAuthorizationStatusDenied;
            } else {
                return APNAuthorizationStatusAuthorized;
            }
        }
        
    } else {
        return APNAuthorizationStatusUnDetermined;
    }
}

+ (APNType)enabledType {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS8+
        UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
        
        return (APNType)userNotificationSettings.types;
    } else {
        // iOS7 and below
        UIRemoteNotificationType enabledRemoteNotificationTypes = [UIApplication sharedApplication].enabledRemoteNotificationTypes;
        
        return (APNType)enabledRemoteNotificationTypes;
    }
}


- (void)showWithType:(APNType)requestedType
               title:(NSString *)requestTitle
             message:(NSString *)message
        optionsTitle:(NSString *)optionsTitle
     denyButtonTitle:(NSString *)denyButtonTitle
    grantButtonTitle:(NSString *)grantButtonTitle
   completionHandler:(APNPermissionRequestCompletionHandler)completionHandler {
    
    if (requestTitle.length == 0) {
        requestTitle = @"Enable Push Notifications?";
    }
    if (denyButtonTitle.length == 0) {
        denyButtonTitle = @"Not now";
    }
    
    if (grantButtonTitle.length == 0) {
        grantButtonTitle = @"Accept";
    }
    
    if (optionsTitle.length == 0) {
        optionsTitle = @"Push Notification Options";
    }
    self.optionsTitle = optionsTitle;
    
    APNAuthorizationStatus status = [APNPermissionRequest authorizationStatus];
    if (status == APNAuthorizationStatusUnDetermined) {
        self.completionHandler = completionHandler;
        self.requestedType = requestedType;
        
        
        alert = [SDCAlertController alertControllerWithTitle:requestTitle
                                                     message:message
                                              preferredStyle:SDCAlertControllerStyleAlert];
        
        [alert addAction:[SDCAlertAction actionWithTitle:denyButtonTitle
                                                   style:SDCAlertActionStyleDefault
                                                 handler:^(SDCAlertAction *action) {
                                                     [self firePushNotificationPermissionCompletionHandler];
                                                 }]];
        
        [alert addAction:[SDCAlertAction actionWithTitle:grantButtonTitle
                                                   style:SDCAlertActionStyleDefault
                                                 handler:^(SDCAlertAction *action) {
                                                     [self showActualPushNotificationPermissionAlert];
                                                 }]];
        
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.alwaysBounceVertical = NO;
        tableView.separatorColor = [UIColor clearColor];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [alert.contentView addSubview:tableView];
        [tableView sdc_horizontallyCenterInSuperview];
        [tableView sdc_pinWidthToWidthOfView:alert.contentView];
        
        CGFloat heigtConstant = self.collapsed ? 44 : 4*44;
        heightConstraint = [NSLayoutConstraint constraintWithItem:tableView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:heigtConstant];
        [tableView addConstraint:heightConstraint];
        
        [alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(tableView)]];
        
        [alert presentWithCompletion:nil];
        
    } else {
        if (completionHandler) {
            completionHandler((status == APNAuthorizationStatusUnDetermined),
                              APNPermissionRequestDialogResultNoActionTaken,
                              APNPermissionRequestDialogResultNoActionTaken);
        }
    }
}

- (void)showWithType:(APNType)requestedType
               title:(NSString *)requestTitle
             message:(NSString *)message
     denyButtonTitle:(NSString *)denyButtonTitle
    grantButtonTitle:(NSString *)grantButtonTitle
   completionHandler:(APNPermissionRequestCompletionHandler)completionHandler {
    
    if (requestTitle.length == 0) {
        requestTitle = @"Enable Push Notifications?";
    }
    if (denyButtonTitle.length == 0) {
        denyButtonTitle = @"Not now";
    }
    
    if (grantButtonTitle.length == 0) {
        grantButtonTitle = @"Accept";
    }
    
    APNAuthorizationStatus status = [APNPermissionRequest authorizationStatus];
    if (status == APNAuthorizationStatusUnDetermined) {
        self.completionHandler = completionHandler;
        self.requestedType = requestedType;
        
        
        alert = [SDCAlertController alertControllerWithTitle:requestTitle
                                                     message:message
                                              preferredStyle:SDCAlertControllerStyleAlert];
        
        [alert addAction:[SDCAlertAction actionWithTitle:denyButtonTitle
                                                   style:SDCAlertActionStyleDefault
                                                 handler:^(SDCAlertAction *action) {
                                                     [self firePushNotificationPermissionCompletionHandler];
                                                 }]];
        
        [alert addAction:[SDCAlertAction actionWithTitle:grantButtonTitle
                                                   style:SDCAlertActionStyleDefault
                                                 handler:^(SDCAlertAction *action) {
                                                     [self showActualPushNotificationPermissionAlert];
                                                 }]];
        
        [alert presentWithCompletion:nil];
        
    } else {
        if (completionHandler) {
            completionHandler((status == APNAuthorizationStatusUnDetermined),
                              APNPermissionRequestDialogResultNoActionTaken,
                              APNPermissionRequestDialogResultNoActionTaken);
        }
    }
}

- (void)showDefaultRequestWithType:(APNType)requestedType
                 completionHandler:(APNPermissionRequestCompletionHandler)completionHandler {
    
    APNAuthorizationStatus status = [APNPermissionRequest authorizationStatus];
    if (status == APNAuthorizationStatusUnDetermined) {
        self.completionHandler = completionHandler;
        self.requestedType = requestedType;
        
        [self showActualPushNotificationPermissionAlert];
        
    } else {
        if (completionHandler) {
            completionHandler((status == APNAuthorizationStatusUnDetermined),
                              APNPermissionRequestDialogResultNoActionTaken,
                              APNPermissionRequestDialogResultNoActionTaken);
        }
    }
}

- (void)showActualPushNotificationPermissionAlert
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS8+
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationType)self.requestedType
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)self.requestedType];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:APNPermissionRequestShown];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [self firePushNotificationPermissionCompletionHandler];
}


- (void) firePushNotificationPermissionCompletionHandler
{
    APNAuthorizationStatus status = [APNPermissionRequest authorizationStatus];
    if (self.completionHandler) {
        APNPermissionRequestDialogResult userDialogResult = APNPermissionRequestDialogResultGranted;
        APNPermissionRequestDialogResult systemDialogResult = APNPermissionRequestDialogResultGranted;
        if (status == APNAuthorizationStatusAuthorized) {
            userDialogResult = APNPermissionRequestDialogResultGranted;
            systemDialogResult = APNPermissionRequestDialogResultGranted;
        } else if (status == APNAuthorizationStatusDenied) {
            userDialogResult = APNPermissionRequestDialogResultGranted;
            systemDialogResult = APNPermissionRequestDialogResultDenied;
        } else if (status == APNAuthorizationStatusUnDetermined) {
            userDialogResult = APNPermissionRequestDialogResultDenied;
            systemDialogResult = APNPermissionRequestDialogResultNoActionTaken;
        }
        self.completionHandler((status == APNAuthorizationStatusAuthorized),
                                                         userDialogResult,
                                                         systemDialogResult);
        self.completionHandler = nil;
    }
}

#pragma mark - UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.collapsed ? 1 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *imgName, *imgPath;
    
    if (indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"APNPermissionRequestOptionsTitle"];
        cell.textLabel.text = self.optionsTitle;
        cell.detailTextLabel.text = [[self requestedTypeNames] componentsJoinedByString:@", "];
        imgName = self.collapsed ? @"APNPermissionRequestArrowDown" : @"APNPermissionRequestArrowUp";
        imgPath = [[NSBundle mainBundle] pathForResource:imgName
                                                  ofType:@"png"
                                             inDirectory:kAPNPermissionRequestBundle];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgPath]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    } else {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"APNPermissionRequestOptionsOption"];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
        
        UISwitch *permissionSwitch = [[UISwitch alloc] init];
        permissionSwitch.layer.cornerRadius = 16.0;
        permissionSwitch.backgroundColor = [UIColor lightGrayColor];
        
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Sounds", nil);
            imgName = @"APNPermissionRequestSound";
            permissionSwitch.on = (self.requestedType & APNTypeSound);
            permissionSwitch.tag = APNTypeSound;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Badges", nil);
            imgName = @"APNPermissionRequestBadge";
            permissionSwitch.on = (self.requestedType & APNTypeBadge);
            permissionSwitch.tag = APNTypeBadge;
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Alerts", nil);
            imgName = @"APNPermissionRequestAlert";
            permissionSwitch.on = (self.requestedType & APNTypeAlert);
            permissionSwitch.tag = APNTypeAlert;
        }
        imgPath = [[NSBundle mainBundle] pathForResource:imgName
                                                  ofType:@"png"
                                             inDirectory:kAPNPermissionRequestBundle];
        cell.imageView.image = [UIImage imageWithContentsOfFile:imgPath];
        
        [permissionSwitch addTarget:self
                             action:@selector(switchPermission:)
                   forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = permissionSwitch;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - UITableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != 0) {
        return;
    }
    
    NSIndexPath* soundIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath* badgeIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath* alertIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    NSArray* indexPaths = @[soundIndexPath,badgeIndexPath,alertIndexPath];
    
    [tableView beginUpdates];
    
    if (self.collapsed) {
        [tableView insertRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [tableView deleteRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationTop];
    }
    
    self.collapsed = !self.collapsed;
    [tableView endUpdates];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *imgName = self.collapsed ? @"APNPermissionRequestArrowDown" : @"APNPermissionRequestArrowUp";
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:imgName
                                                        ofType:@"png"
                                                   inDirectory:kAPNPermissionRequestBundle];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgPath]];
    
    heightConstraint.constant = [tableView numberOfRowsInSection:indexPath.section]*44;
}

#pragma mark - UISwitch delegate

- (void)switchPermission:(UISwitch *)sender {
    
    self.requestedType = sender.isOn ? self.requestedType | (APNType)sender.tag : self.requestedType & ~(APNType)sender.tag;
    UITableView *tableView = [[alert.contentView subviews] firstObject];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                inSection:0]];
    cell.detailTextLabel.text = [[self requestedTypeNames] componentsJoinedByString:@", "];
}

#pragma mark - APNType Helper

- (NSArray *)requestedTypeNames {
    NSMutableArray *names = [@[] mutableCopy];
    
    if (self.requestedType & APNTypeBadge) {
        [names addObject:NSLocalizedString(@"Badges", nil)];
    }
    if (self.requestedType & APNTypeSound) {
        [names addObject:NSLocalizedString(@"Sounds", nil)];
    }
    if (self.requestedType & APNTypeAlert) {
        [names addObject:NSLocalizedString(@"Alerts", nil)];
    }
    
    return names;
    
}

+ (NSArray *)enabledTypeNames {
    NSMutableArray *names = [@[] mutableCopy];
    
    if ([APNPermissionRequest enabledType] & APNTypeBadge) {
        [names addObject:NSLocalizedString(@"Badges", nil)];
    }
    if ([APNPermissionRequest enabledType] & APNTypeSound) {
        [names addObject:NSLocalizedString(@"Sounds", nil)];
    }
    if ([APNPermissionRequest enabledType] & APNTypeAlert) {
        [names addObject:NSLocalizedString(@"Alerts", nil)];
    }
    
    return names;
}



@end