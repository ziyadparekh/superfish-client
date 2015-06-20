//
//  ComposeTableViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 6/16/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPGroup.h"

@protocol ComposeGroupDelegate

- (void)didCreateGroup:(NSArray *)group;

@end

@interface ComposeTableViewController : UITableViewController

@property (nonatomic, assign) IBOutlet id<ComposeGroupDelegate>delegate;

@end
