//
//  MessagesViewController.h
//  superfish
//
//  Created by Ziyad Parekh on 6/4/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "SLKTextViewController.h"
#import "URBMediaFocusViewController.h"
#import "ZPGroup.h"

@class MessagesViewController;

@protocol MessagesViewControllerDelegate <NSObject>

- (void)didGoBackToGroupViewControllerFrom:(MessagesViewController *)controller;

@end

@interface MessagesViewController : SLKTextViewController <URBMediaFocusViewControllerDelegate>

@property (nonatomic, weak) id<MessagesViewControllerDelegate>delegate;
@property (strong, nonatomic) ZPGroup *group;

@property (strong, nonatomic) NSDictionary *currentUser;

@end
