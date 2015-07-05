//
//  HomeViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterTableViewController.h"
#import "LoginTableViewController.h"

@interface HomeViewController : UIViewController<RegisterUserDelegate, LoginUserDelegate>

@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)signUpButtonPressed:(UIButton *)sender;

- (IBAction)loginButtonPressed:(UIButton *)sender;
@end
