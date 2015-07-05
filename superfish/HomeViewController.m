//
//  HomeViewController.m
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.loginButton.font = [UIFont fontWithName:@"Zapf Dingbats" size:18.0];
    self.loginButton.layer.cornerRadius = 5;
    self.signupButton.layer.borderColor = [[UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0] CGColor];
    self.signupButton.layer.borderWidth = 1;
    self.loginButton.backgroundColor = [UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"Zapf Dingbats" size:21];
    
    self.signupButton.layer.cornerRadius = 5;
    self.signupButton.layer.borderColor = [[UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0] CGColor];
    self.signupButton.layer.borderWidth = 1;
    self.signupButton.backgroundColor = [UIColor whiteColor];
    [self.signupButton setTitleColor:[UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0] forState:UIControlStateNormal];
    self.signupButton.titleLabel.font = [UIFont fontWithName:@"Zapf Dingbats" size:21];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"HomeToLoginSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        LoginTableViewController *destinationVC = [navController viewControllers][0];
        destinationVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"HomeToSignupSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        RegisterTableViewController *destinationVC = [navController viewControllers][0];
        destinationVC.delegate = self;
    }
}


- (void)didLoginUserForController:(LoginTableViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRegisterUserForController:(RegisterTableViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signUpButtonPressed:(UIButton *)sender {
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
}
@end
