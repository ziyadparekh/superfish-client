//
//  GroupDetailsTableViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 6/27/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPGroup.h"
#import "EditGroupMembersTableViewController.h"

@protocol GroupDetailsDelegate

- (void)didUpdateGroupName:(NSString *)groupName;

@end

@interface GroupDetailsTableViewController : UITableViewController <UITextFieldDelegate, EditGroupMembersDelegate>

@property (strong, nonatomic) ZPGroup *group;
@property (strong, nonatomic) NSArray *memberUsernames;
@property (strong, nonatomic) NSDictionary *currentUser;

@property (nonatomic, assign) IBOutlet id<GroupDetailsDelegate>delegate;

@end
