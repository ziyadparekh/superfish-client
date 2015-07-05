//
//  ContactsTableViewController.m
//  superfish
//
//  Created by Ziyad Parekh on 6/13/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ContactsTableViewController.h"
#import <AddressBook/AddressBook.h>
#import <RestKit/RestKit.h>

#import "Contacts.h"
#import "ContactsManager.h"

static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

@interface ContactsTableViewController ()
{
    NSMutableArray *users1;
    NSMutableArray *users2;
    
    NSIndexPath *indexSelected;
}
@end

@implementation ContactsTableViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"Contacts";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    users1 = [[NSMutableArray alloc] init];
    users2 = [[NSMutableArray alloc] init];
    
    //[self configureRestkit];
    [self initializeAddressBook];
}

- (void)initializeAddressBook
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self loadAddressBook];
            }
        });
    });
}

- (void) configureRestkit {
    NSURL *baseUrl = [NSURL URLWithString:@"http://localhost:8080"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    // initialize restkit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *contactsMapping = [RKObjectMapping mappingForClass:[Contacts class]];
    [contactsMapping addAttributeMappingsFromArray:@[@"id", @"username", @"number"]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:contactsMapping method:RKRequestMethodAny pathPattern:@"/contacts" keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromArray:@[@"contacts"]];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[NSDictionary class] rootKeyPath:nil method:RKRequestMethodAny];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addRequestDescriptor:requestDescriptor];
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
}

- (void)loadAddressBook
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef sourceBook = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, sourceBook, kABPersonFirstNameProperty);
        CFIndex personCount = CFArrayGetCount(allPeople);
        
        [users1 removeAllObjects];
        for (int i=0; i<personCount; i++) {
            ABMultiValueRef tmp;
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            NSString *first = @"";
            tmp = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            if (tmp != nil) {
                first = [NSString stringWithFormat:@"%@", tmp];
            }
            
            NSString *last = @"";
            tmp = ABRecordCopyValue(person, kABPersonLastNameProperty);
            if (tmp != nil) {
                last = [NSString stringWithFormat:@"%@", tmp];
            }
            
            NSMutableArray *emails = [[NSMutableArray alloc] init];
            ABMultiValueRef multi1 = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (CFIndex j=0; j<ABMultiValueGetCount(multi1); j++) {
                tmp = ABMultiValueCopyValueAtIndex(multi1, j);
                if (tmp != nil) {
                    [emails addObject:[NSString stringWithFormat:@"%@", tmp]];
                }
            }
            
            NSMutableArray *phones = [[NSMutableArray alloc] init];
            ABMultiValueRef multi2 = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (CFIndex j=0; j<ABMultiValueGetCount(multi2); j++) {
                tmp = ABMultiValueCopyValueAtIndex(multi2, j);
                if (tmp != nil) {
                    NSString *formattedPhone = [[[NSString stringWithFormat:@"%@", tmp] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                    [phones addObject:[NSString stringWithFormat:@"%@", formattedPhone]];
                }
            }
            
            NSString *name = [NSString stringWithFormat:@"%@ %@", first, last];
            [users1 addObject:@{@"name":name, @"emails":emails, @"phones":phones}];
        }
        CFRelease(allPeople);
        CFRelease(addressBook);
        [self loadUsers];
    }
}

- (void)loadUsers
{
    NSMutableArray *tmpContacts = [[NSMutableArray alloc] init];
    for (NSDictionary *user in users1) {
        [tmpContacts addObjectsFromArray:user[@"phones"]];
    }
    NSMutableDictionary *contacts = [[NSMutableDictionary alloc] initWithObjects:@[tmpContacts] forKeys:@[@"contacts"]];
    [[ContactsManager sharedManager] postUserContacts:contacts withBlock:^(NSArray *array) {
        [users2 removeAllObjects];
        for (Contacts *contact in array) {
            [users2 addObject:contact];
            [self removeUser:contact.number];
        }
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"There was an error : %@", error);
    }];
}

- (void) removeUser:(NSString *)userPhone
{
    NSMutableArray *remove = [[NSMutableArray alloc] init];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    for (NSDictionary *user in users1)
    {
        for (NSString *number in user[@"phones"])
        {
            if ([number isEqualToString:userPhone])
            {
                [remove addObject:user];
                break;
            }
        }
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    for (NSDictionary *user in remove)
    {
        [users1 removeObject:user];
    }
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
        return [users2 count];
    }
    if (section == 1) {
        return [users1 count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((section == 0) && ([users2 count] != 0)) {
        return @"Registered Users";
    }
    if ((section == 1 && ([users1 count] != 0))) {
        return @"Non-Registered Users";
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    if (indexPath.section == 0) {
        Contacts *user = users2[indexPath.row];
        cell.textLabel.text = user.username;
    }
    if (indexPath.section == 1) {
        NSDictionary *user = users1[indexPath.row];
        NSString *email = [user[@"emails"] firstObject];
        NSString *phone = [user[@"phones"] firstObject];
        cell.textLabel.text = user[@"name"];
        cell.detailTextLabel.text = (email != nil) ? email : phone;
    }
    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
//    if (indexPath.section == 0)
//    {
//        [self dismissViewControllerAnimated:YES completion:^{
//            if (delegate != nil) [delegate didSelectAddressBookUser:users2[indexPath.row]];
//        }];
//    }
    if (indexPath.section == 1)
    {
        indexSelected = indexPath;
        [self inviteUser:users1[indexPath.row]];
    }
}

#pragma mark - Invite helper method

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)inviteUser:(NSDictionary *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (([user[@"phones"] count] != 0)) {
        [self sendSMS:user];
    } else {
        //TODO:: show progress hud error
        NSLog(@"not enough info");
    }
}

#pragma mark - SMS sending method

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendSMS:(NSDictionary *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
        messageCompose.recipients = user[@"phones"];
        messageCompose.body = @"WHAT UP? USE MY APP";
        messageCompose.messageComposeDelegate = self;
        [self presentViewController:messageCompose animated:YES completion:nil];
    }
    else NSLog(@"cant send text from device");
}

#pragma mark - MFMessageComposeViewControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (result == MessageComposeResultSent)
    {
        //[ProgressHUD showSuccess:@"SMS sent successfully."];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressRefreshButton:(UIBarButtonItem *)sender {
    
    [self initializeAddressBook];
}
@end
