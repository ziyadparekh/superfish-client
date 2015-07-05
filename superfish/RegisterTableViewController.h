//
//  RegisterTableViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegisterTableViewController;

@protocol RegisterUserDelegate <NSObject>

- (void)didRegisterUserForController:(RegisterTableViewController *)controller;

@end

@interface RegisterTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *numberTextField;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;

@property (nonatomic, weak) id<RegisterUserDelegate>delegate;

- (IBAction)didPressRegisterButton:(UIButton *)sender;

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender;


@end
