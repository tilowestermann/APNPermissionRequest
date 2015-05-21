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
static NSString *const kAPNPermissionRequestBundleName = @"APNPermissionRequest";
static APNPermissionRequest *__sharedInstance;

@interface APNPermissionRequest () <UITableViewDataSource, UITableViewDelegate> {
    UINavigationController *navigationController;
    UITableView *optionsTableView;
    NSLayoutConstraint *heightConstraint;
    NSBundle *resourceBundle;
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
        [__sharedInstance setup];
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

- (void)setup {
    resourceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[APNPermissionRequest class]]
                                               pathForResource:kAPNPermissionRequestBundleName
                                               ofType:@"bundle"]];
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
        
        
        SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:requestTitle
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
        
        optionsTableView = [[UITableView alloc] init];
        optionsTableView.delegate = self;
        optionsTableView.dataSource = self;
        optionsTableView.alwaysBounceVertical = NO;
        optionsTableView.separatorColor = [UIColor clearColor];
        optionsTableView.backgroundColor = [UIColor clearColor];
        optionsTableView.translatesAutoresizingMaskIntoConstraints = NO;
        [alert.contentView addSubview:optionsTableView];
        [optionsTableView sdc_horizontallyCenterInSuperview];
        [optionsTableView sdc_pinWidthToWidthOfView:alert.contentView];
        
        CGFloat heigtConstant = self.collapsed ? 44 : 4*44;
        heightConstraint = [NSLayoutConstraint constraintWithItem:optionsTableView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:heigtConstant];
        [optionsTableView addConstraint:heightConstraint];
        
        [alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[optionsTableView]-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(optionsTableView)]];
        
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
        
        
        SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:requestTitle
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

- (void)showFullscreenWithType:(APNType)requestedType
               title:(NSString *)requestTitle
             message:(NSAttributedString *)message
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
    self.collapsed = NO;
    
    APNAuthorizationStatus status = [APNPermissionRequest authorizationStatus];
    if (status == APNAuthorizationStatusUnDetermined) {
        self.completionHandler = completionHandler;
        self.requestedType = requestedType;
        
        
        UIViewController *viewController = [[UIViewController alloc] init];
        viewController.view.backgroundColor = self.backgroundColor == nil ? [UIColor lightGrayColor] : self.backgroundColor;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.navigationBarHidden = YES;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = requestTitle;
        [viewController.view addSubview:titleLabel];
        
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        messageLabel.numberOfLines = 0;
        messageLabel.font = [UIFont systemFontOfSize:14];
        messageLabel.attributedText = message;
        [viewController.view addSubview:messageLabel];
        
        optionsTableView = [[UITableView alloc] init];
        optionsTableView.delegate = self;
        optionsTableView.dataSource = self;
        optionsTableView.alwaysBounceVertical = NO;
        optionsTableView.separatorColor = [UIColor clearColor];
        optionsTableView.backgroundColor = [UIColor clearColor];
        optionsTableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat heigtConstant = self.collapsed ? 44 : 4*44;
        heightConstraint = [NSLayoutConstraint constraintWithItem:optionsTableView
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:heigtConstant];
        [optionsTableView addConstraint:heightConstraint];
        [viewController.view addSubview:optionsTableView];
        
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:denyButtonTitle
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(firePushNotificationPermissionCompletionHandler)];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
        UIBarButtonItem *acceptItem = [[UIBarButtonItem alloc] initWithTitle:grantButtonTitle
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showActualPushNotificationPermissionAlert)];
        toolbar.items = @[cancelItem,spaceItem,acceptItem];
        [viewController.view addSubview:toolbar];
        
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel,
                                                             messageLabel,
                                                             optionsTableView,
                                                             toolbar);
        
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(40)-[titleLabel]-[messageLabel]-[optionsTableView]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbar]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[messageLabel]-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[optionsTableView]-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];
        
        UIWindow *mainWindow = [[UIApplication sharedApplication].windows firstObject];
        [mainWindow.rootViewController presentViewController:navigationController animated:YES completion:^{
            
        }];
        
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
    if (navigationController != nil) {
        [navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
    
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
    
    if (navigationController != nil) {
        [navigationController dismissViewControllerAnimated:YES completion:NULL];
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
        imgPath = [resourceBundle pathForResource:imgName
                                           ofType:@"png"];
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
        imgPath = [resourceBundle pathForResource:imgName
                                           ofType:@"png"];
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
    NSString *imgPath = [resourceBundle pathForResource:imgName
                                                 ofType:@"png"];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgPath]];
    
    heightConstraint.constant = [tableView numberOfRowsInSection:indexPath.section]*44;
}

#pragma mark - UISwitch delegate

- (void)switchPermission:(UISwitch *)sender {
    
    self.requestedType = sender.isOn ? self.requestedType | (APNType)sender.tag : self.requestedType & ~(APNType)sender.tag;
    
    UITableViewCell *cell = [optionsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
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