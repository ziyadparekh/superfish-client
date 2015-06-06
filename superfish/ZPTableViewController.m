//
//  ZPTableViewController.m
//  
//
//  Created by Ziyad Parekh on 6/3/15.
//
//

#import "ZPTableViewController.h"
#import "ZPGroupTableViewCell.h"
#import <RestKit/RestKit.h>
#import <NSDate-Time-Ago/NSDate+NVTimeAgo.h>
#import "MessagesViewController.h"
#import "ZPGroup.h"
#import "Messages.h"

@interface ZPTableViewController ()

@property (strong, nonatomic) NSArray *groups;

@end

@implementation ZPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure Restkit
    [self configureRestkit];
    [self loadGroups];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Restkit Implementation

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
    NSString *token = @"555e8e3b3c5d6387f9000002_8538477eea20bc193e81c4785e369aa2186ad34ea8b896a67a608c1937a3cd63";
    NSDictionary *queryParams = @{@"token" : token};
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/groups" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.groups = mappingResult.array;
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"There was an error : %@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.groups count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    ZPGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ZPGroup *group = self.groups[indexPath.row];
    
    cell.groupName.text = [self getNameForGroup:group];
    cell.groupMessage.text = [self getLastMessageForGroup:group];
    cell.groupDate.text = [self getGroupActivity:group];
    
    return cell;
}

#pragma mark - TableView Cell data source

- (NSString *)getNameForGroup:(ZPGroup *)group {
    return group.name;
}

- (NSString *)getLastMessageForGroup:(ZPGroup *) group {
    Messages *msg = [group.messages objectAtIndex:0];
    return msg.content;
}

- (NSString *)getGroupActivity:(ZPGroup *)group {
    NSString *activity = group.activity;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'-'HH:mm"];
    NSDate *date = [formatter dateFromString:activity];
    
    return [date formattedAsTimeAgo];
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
    if ([segue.identifier isEqualToString:@"GroupToMessagesSegue"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //MessagesViewController *destinationViewController = [segue destinationViewController];
        //destinationViewController.group = [self.groups objectAtIndex:indexPath.row];
        
    }
}


@end
