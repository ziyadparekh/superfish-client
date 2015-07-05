//
//  EditGroupMembersTableViewController.m
//  superfish
//
//  Created by Ziyad Parekh on 6/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "EditGroupMembersTableViewController.h"
#import "Contacts.h"
#import "ContactsManager.h"
#import "GroupMembersManager.h"

static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

@interface EditGroupMembersTableViewController ()

@end

@implementation EditGroupMembersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Edit Members";
    // Do any additional setup after loading the view.
    self.currentUser = [self getCurrentUser];
}

- (NSDictionary *)getCurrentUser
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"currentUser"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPeople
{
    [[ContactsManager sharedManager] loadUserContacts:^(NSArray *contacts) {
        [self.users removeAllObjects];
        for (Contacts *contact in contacts) {
            [self.users addObject:contact];
        }
        [self setObjects:self.users];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"There was an error %@", error);
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    NSMutableArray *userstemp = self.sections[indexPath.section];
    Contacts *user = userstemp[indexPath.row];
    cell.textLabel.text = user.username;
    
    BOOL selected = [self.members containsObject:user.username];

    cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
    
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSMutableArray *userstemp = self.sections[indexPath.section];
    Contacts *user = userstemp[indexPath.row];
    BOOL selected = [self.members containsObject:user.username];
    if (selected) [self.members removeObject:user.username]; else [self.members addObject:user.username];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self.tableView reloadData];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender {
    
    if ([self.members count] == 0) { NSLog(@"need to select users"); return; }
    
    NSMutableDictionary *group = [[NSMutableDictionary alloc] initWithObjects:@[self.group.groupId, self.members, self.currentUser[@"token"]] forKeys:@[@"groupId", @"members", @"token"]];
    
    [[GroupMembersManager sharedManager] updateGroupMembers:group withBlock:^(NSArray *array) {
        if (self.editGroupdelegate != nil) {
            [self.editGroupdelegate didEditGroupMembers:self.members];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}
@end
