//
//  GroupDetailsTableViewController.m
//  superfish
//
//  Created by Ziyad Parekh on 6/27/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "GroupDetailsTableViewController.h"
#import "GroupNameManager.h"


static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

@interface GroupDetailsTableViewController ()

@end

@implementation GroupDetailsTableViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.title = @"Details";
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.memberUsernames = [self buildGroupMembersUsernameArray];
    
    //self.tableView.separatorColor = [UIColor colorWithRed:177/255 green:191/255 blue:196/255 alpha:1.0];
    self.tableView.separatorColor = [UIColor greenColor];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        return [self.memberUsernames count];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString *newGroupName = textField.text;
    if (newGroupName.length == 0 || [newGroupName isEqualToString:self.group.name]) {
        return YES;
    }
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithObjects:@[newGroupName, self.group.groupId, TeporaryUserToken] forKeys:@[@"name", @"groupId", @"token"]];
    
    [[GroupNameManager sharedManager] updateGroupName:payload withBlock:^(NSArray *array) {
        if (delegate != nil) [delegate didUpdateGroupName:newGroupName];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"There was an error: %@", error);
    }];
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if ([indexPath section] == 0) {
        UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
        playerTextField.adjustsFontSizeToFitWidth = YES;
        playerTextField.textColor = [UIColor blackColor];
        playerTextField.font = [UIFont fontWithName:@"Zapf Dingbats" size:18.0];
        if ([indexPath row] == 0) {
            playerTextField.placeholder = [self.group getGroupName:self.group];
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.returnKeyType = UIReturnKeyDone;
        }
        playerTextField.backgroundColor = [UIColor whiteColor];
        playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
        playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
        playerTextField.tag = 0;
        playerTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        playerTextField.delegate = self;
        
        [cell.contentView addSubview:playerTextField];
    } else if ([indexPath section] == 1) {
        NSString *username = [self.memberUsernames objectAtIndex:indexPath.row];
        cell.textLabel.text = username;
        NSLog(@"%@", self.group.admin);
        if ([self.group.admin isEqualToString:username]) {
            cell.detailTextLabel.text = @"Admin";
        } else {
            cell.detailTextLabel.text = @"";
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Group Name";
    } else if (section == 1) {
        return @"Members";
    } else {
        return @"";
    }
}

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

- (void)didEditGroupMembers:(NSArray *)members
{
    self.memberUsernames = members;
    [self.tableView reloadData];
}


- (NSArray *)buildGroupMembersUsernameArray
{
    NSMutableArray *membersArray = [[NSMutableArray alloc] initWithCapacity:self.group.members.count];
    for (NSDictionary *user in self.group.members) {
        [membersArray addObject:user[@"username"]];
    }
    return membersArray;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"DetailToEditMembersSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        EditGroupMembersTableViewController *destinationVC = [navigationController viewControllers][0];
        destinationVC.members = [self.memberUsernames mutableCopy];
        destinationVC.group = self.group;
        destinationVC.delegate = self;
    }
}


@end
