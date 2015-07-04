//
//  Common.m
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.

#import "common.h"
#import "RegisterTableViewController.h"


//-------------------------------------------------------------------------------------------------------------------------------------------------
void LoginUser(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[RegisterTableViewController alloc] init]];
    [target presentViewController:navigationController animated:YES completion:nil];
}