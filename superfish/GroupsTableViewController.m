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

#import <RestKit/RestKit.h>



static NSString *GroupCellIdentifier = @"GroupCell";
static NSString *TeporaryUserToken = @"555e8e3b3c5d6387f9000002_8538477eea20bc193e81c4785e369aa2186ad34ea8b896a67a608c1937a3cd63";

@interface GroupsTableViewController ()

@property (strong, nonatomic) NSArray *groups;

@end

@implementation GroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    
    [self.tableView registerClass:[GroupsTableViewCell class] forCellReuseIdentifier:GroupCellIdentifier];
    self.tableView.rowHeight = 72.0;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 30, 0, 0)];
    
    // Configure Restkit
    [self configureRestkit];
    [self loadGroups];
}

- (void) configureRestkit {
    NSURL *baseUrl = [NSURL URLWithString:@"http://localhost:8080"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    // initialize restkit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *groupMapping = [RKObjectMapping mappingForClass:[ZPGroup class]];
    [groupMapping addAttributeMappingsFromArray:@[@"name", @"activity", @"groupId"]];
    
    RKObjectMapping *messagesMapping = [RKObjectMapping mappingForClass:[Messages class]];
    [messagesMapping addAttributeMappingsFromArray:@[@"content", @"time"]];
    
    RKRelationshipMapping *rel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"messages" toKeyPath:@"messages" withMapping:messagesMapping];
    
    [groupMapping addPropertyMapping:rel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:groupMapping method:RKRequestMethodGET pathPattern:@"/groups" keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

- (void) loadGroups {
    NSDictionary *queryParams = @{@"token" : TeporaryUserToken};
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/groups" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.groups = mappingResult.array;
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
    cell.groupNameLabel.text = group.name;
    cell.lastMessageTextLabel.text = [group getLastMessageForGroup:group];
    cell.lastMessageSentDateLabel.text = [group getGroupActivity:group];
    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
