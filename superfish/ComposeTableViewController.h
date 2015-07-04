//
//  ComposeTableViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 6/16/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPGroup.h"

@class ComposeTableViewController;

@protocol ComposeGroupDelegate <NSObject>

- (void)didCreateGroup:(NSArray *)group forController:(ComposeTableViewController *)controller;

@end

@interface ComposeTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSMutableArray *selection;

@property (nonatomic, weak) id<ComposeGroupDelegate>delegate;

- (IBAction)didPressDoneButton:(UIBarButtonItem *)sender;
- (IBAction)didPressCancelButton:(UIBarButtonItem *)sender;

- (void)setObjects:(NSArray *)objects;

@end
