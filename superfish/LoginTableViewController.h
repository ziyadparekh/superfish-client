//
//  LoginTableViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginTableViewController;

@protocol LoginUserDelegate <NSObject>

- (void)didLoginUserForController:(LoginTableViewController *)controller;

@end

@interface LoginTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, weak) id<LoginUserDelegate>delegate;

- (IBAction)didPressLoginButton:(UIButton *)sender;

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender;
@end
