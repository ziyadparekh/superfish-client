//
//  GroupsTableViewController.m
//  superfish
//
//  Created by Ziyad Parekh on 6/9/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "GroupsTableViewController.h"
#import "GroupsTableViewCell.h"
#import "ZPGroup.h"
#import "Messages.h"
#import "Contacts.h"
#import "ComposeTableViewController.h"
#import "MessagesViewController.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

#import "Common.h"

#import "GroupManager.h"

#import <RestKit/RestKit.h>



static NSString *GroupCellIdentifier = @"GroupCell";

static NSString *TemporaryUserId = @"ziyadparekh";
static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

@interface GroupsTableViewController ()

@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) ZPGroup *groupForSegue;

@end

@implementation GroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    FAKFontAwesome *icon = [FAKFontAwesome userIconWithSize:25];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]];
    
    [self.navigationItem.leftBarButtonItem setImage:[icon imageWithSize:CGSizeMake(25, 25)]];
    
    [self.tableView registerClass:[GroupsTableViewCell class] forCellReuseIdentifier:GroupCellIdentifier];
    self.tableView.rowHeight = 72.0;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 30, 0, 0)];
    self.title = @"Conversations";
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.currentUser = [userDefaults objectForKey:@"currentUser"];
    if (self.currentUser == nil) {
        [self performSegueWithIdentifier:@"GroupToHomeSegue" sender:self];
    } else {
        [self loadGroups];
    }
}

- (void) configureRestkit {
    NSURL *baseUrl = [NSURL URLWithString:@"http://localhost:8080"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    // initialize restkit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *groupMapping = [RKObjectMapping mappingForClass:[ZPGroup class]];
    [groupMapping addAttributeMappingsFromArray:@[@"name", @"activity", @"groupId", @"members"]];
    
    RKObjectMapping *messagesMapping = [RKObjectMapping mappingForClass:[Messages class]];
    [messagesMapping addAttributeMappingsFromArray:@[@"content", @"time"]];
    
    RKRelationshipMapping *rel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"messages" toKeyPath:@"messages" withMapping:messagesMapping];
    
    [groupMapping addPropertyMapping:rel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:groupMapping method:RKRequestMethodGET pathPattern:@"/groups" keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

- (void) loadGroups {
    [[GroupManager sharedManager] loadUserGroups:^(NSArray *groups) {
        self.groups = [groups mutableCopy];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"There was an error : %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    ZPGroup *group = self.groups[indexPath.row];
    cell.groupNameLabel.text = [self getGroupName:group];
    cell.lastMessageTextLabel.text = [group getLastMessageForGroup:group];
    cell.lastMessageSentDateLabel.text = [group getGroupActivity:group];
    if (![self hasUserReadLastMessage:[group getReadArrayForGroup:group]]) {
        cell.lastMessageTextLabel.textColor = [UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0];
    } else {
        cell.lastMessageTextLabel.textColor = [UIColor lightGrayColor];
    }
    return cell;
}

- (BOOL)hasUserReadLastMessage:(NSArray *)array
{
    if ([array containsObject:self.currentUser[@"username"]]) {
        return YES;
    }
    return NO;
}

- (NSString *)getGroupName:(ZPGroup *)group
{
    if (group.members.count == 1) {
        return @"Botler";
    }
    if (group.name.length == 0) {
        NSMutableArray *usernames = [[NSMutableArray alloc] initWithCapacity:(group.members.count -1)];
        for (NSDictionary *user in group.members) {
            if (![user[@"username"] isEqualToString:self.currentUser[@"username"]]) {
                [usernames addObject:user[@"username"]];
            }
        }
        return [usernames componentsJoinedByString:@", "];
    }
    return group.name;
}

#pragma mark - ComposeTableView delegate method

- (void)didCreateGroup:(NSArray *)group forController:(ComposeTableViewController *)controller
{
    self.groupForSegue = [group firstObject];
    [self performSegueWithIdentifier:@"GroupToMessages" sender:self];
}

#pragma mark - MessagesViewController delegate method

- (void)didGoBackToGroupViewControllerFrom:(MessagesViewController *)controller
{
    [self loadGroups];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"GroupToMessages" sender:self];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"GroupToComposeSeugue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ComposeTableViewController *destinationViewController = [navigationController viewControllers][0];
        destinationViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"GroupToMessages"] && self.groupForSegue == nil) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MessagesViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.group = [self.groups objectAtIndex:indexPath.row];
        destinationViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"GroupToMessages"] && self.groupForSegue != nil) {
        MessagesViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.group = self.groupForSegue;
        destinationViewController.delegate = self;
        self.groupForSegue = nil;
    }
}

@end
