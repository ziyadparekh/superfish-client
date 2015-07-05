//
//  RegisterTableViewController.m
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "RegisterTableViewController.h"
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import "NewUserManager.h"
#import "User.h"

@interface RegisterTableViewController ()

@end

@implementation RegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signupButton.layer.cornerRadius = 5;
    self.signupButton.layer.borderWidth = 1;
    self.signupButton.layer.borderColor = [[UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0] CGColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didPressRegisterButton:(UIButton *)sender {
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *number = self.numberTextField.text;
    
    if ([number hasPrefix:@"1"]) {
        number = [number substringFromIndex:1];
    }
    
    if ([username length] < 6) { NSLog(@"username is too short"); return; }
    if ([password length] < 5) { NSLog(@"password must be set"); return; }
    
    NBPhoneNumber *enteredNumber = [phoneUtil parse:number defaultRegion:@"US" error:&anError];
    if (anError == nil && [phoneUtil isValidNumber:enteredNumber]) {
        NSMutableDictionary *newUser = [[NSMutableDictionary alloc] initWithObjects:@[username, password, number] forKeys:@[@"username", @"password", @"number"]];
        
        [[NewUserManager sharedManager] createNewUser:newUser withBlock:^(User *array) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[self createDictionaryForUser:array] forKey:@"currentUser"];
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.delegate != nil) {
                    [self.delegate didRegisterUserForController:self];
                }
            }];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (operation.HTTPRequestOperation.response.statusCode == 400) {
                NSLog(@"Username is already taken");
            } else if (operation.HTTPRequestOperation.response.statusCode == 500) {
                NSLog(@"We were unable to process your request at this time. Please try again in a bit");
            }
        }];
    } else {
        NSLog(@"Phone number is invalid");
    }
}

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)createDictionaryForUser: (User *)user {
    return @{
        @"username": user.username,
        @"token": user.token,
        @"avatar": user.avatar
    };
}

@end
