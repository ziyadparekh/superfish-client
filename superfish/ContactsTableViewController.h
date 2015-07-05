//
//  ContactsTableViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 6/13/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>

@protocol AddressBookDelegate

- (void)didSelectAddressBookUser:(NSObject *)user;

@end


@interface ContactsTableViewController : UITableViewController<MFMessageComposeViewControllerDelegate>

@property (nonatomic, assign) IBOutlet id<AddressBookDelegate>delegate;

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender;

- (IBAction)didPressRefreshButton:(UIBarButtonItem *)sender;


@end
