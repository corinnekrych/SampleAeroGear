//
//  AGAppDelegate.h
//  AeroGearExample
//
//  Created by Corinne Krych on 5/17/13.
//  Copyright (c) 2013 My Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGViewController.h"

@interface AGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) AGViewController *controller;

@end