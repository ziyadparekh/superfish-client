//
//  ComposeTableViewController.m
//  superfish
//
//  Created by Ziyad Parekh on 6/14/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ComposeTableViewController.h"
#import "Contacts.h"

#import "ContactsManager.h"
#import "NewGroupManager.h"

#import <RestKit/RestKit.h>

static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

@interface ComposeTableViewController ()
{
    NSMutableArray *users;
    NSMutableArray *sections;
    NSMutableArray *selection;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;

@end

@implementation ComposeTableViewController

@synthesize viewHeader;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Create Group";
    //---------------------------------------------------------------------------------------------------------------------------------------------
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                                                          action:@selector(actionCancel)];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
                                                                                           action:@selector(actionDone)];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableHeaderView = viewHeader;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    users = [[NSMutableArray alloc] init];
    selection = [[NSMutableArray alloc] init];
    
    //[self configureRestkit];
    [self loadPeople];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void) configureRestkit {
    NSURL *baseUrl = [NSURL URLWithString:@"http://localhost:8080"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    // initialize restkit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *contactsMapping = [RKObjectMapping mappingForClass:[Contacts class]];
    [contactsMapping addAttributeMappingsFromArray:@[@"username", @"number", @"id"]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:contactsMapping method:RKRequestMethodGET pathPattern:@"/contacts" keyPath:@"response.contacts" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    RKObjectMapping *newGroupMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [newGroupMapping addAttributeMappingsFromArray:@[@"name", @"members", @"token"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:newGroupMapping objectClass:[NSMutableDictionary class] rootKeyPath:nil method:RKRequestMethodAny];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
}

- (void)loadPeople
{
    [[ContactsManager sharedManager] loadUserContacts:^(NSArray *contacts) {
        [users removeAllObjects];
        for (Contacts *contact in contacts) {
            [users addObject:contact];
        }
        [self setObjects:users];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"There was an error %@", error);
    }];
}

- (void)setObjects:(NSArray *)objects
{
    if (sections != nil) {
        [sections removeAllObjects];
    }
    
    NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    sections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    for (NSUInteger i=0; i<sectionTitlesCount; i++) {
        [sections addObject:[NSMutableArray array]];
    }
    NSArray *sorted = [objects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                       {
                           Contacts *user1 = (Contacts *)obj1;
                           Contacts *user2 = (Contacts *)obj2;
                           return [user1.username compare:user2.username];
                       }];
    
    for (Contacts *object in sorted)
    {
        NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(getUsername)];
        [sections[section] addObject:object];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if ([selection count] == 0) { NSLog(@"need to select users"); return; }

    NSMutableDictionary *group = [[NSMutableDictionary alloc] initWithObjects:@[@"", selection, TeporaryUserToken] forKeys:@[@"name", @"members", @"token"]];
    [[NewGroupManager sharedManager] createNewGroup:group withBlock:^(NSArray *array) {
        NSLog(@"%@", self.delegate);
        if (delegate != nil){
            NSLog(@"herere");
            [delegate didCreateGroup:array];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([sections[section] count] != 0)
    {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    NSMutableArray *userstemp = sections[indexPath.section];
    Contacts *user = userstemp[indexPath.row];
    cell.textLabel.text = user.username;
    
    BOOL selected = [selection containsObject:user.username];
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
    NSMutableArray *userstemp = sections[indexPath.section];
    Contacts *user = userstemp[indexPath.row];
    BOOL selected = [selection containsObject:user.username];
    if (selected) [selection removeObject:user.username]; else [selection addObject:user.username];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self.tableView reloadData];
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
