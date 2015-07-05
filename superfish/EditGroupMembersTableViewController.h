//
//  EditGroupMembersTableViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 6/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ComposeTableViewController.h"
#import "ZPGroup.h"

@class EditGroupMembersTableViewController;

@protocol EditGroupMembersDelegate <NSObject>

- (void)didEditGroupMembers:(NSArray *)members;

@end

@interface EditGroupMembersTableViewController : ComposeTableViewController

@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) ZPGroup *group;
@property (strong, nonatomic) NSDictionary *currentUser;

@property (nonatomic, weak) id<EditGroupMembersDelegate>editGroupdelegate;

- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender;
- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender;


@end
