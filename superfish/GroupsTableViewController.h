//
//  GroupsTableViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 6/9/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeTableViewController.h"
#import "MessagesViewController.h"

@interface GroupsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ComposeGroupDelegate, MessagesViewControllerDelegate>

@property (strong, nonatomic) NSDictionary *currentUser;

@end
