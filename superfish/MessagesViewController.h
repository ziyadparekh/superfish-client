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

@interface MessagesViewController : SLKTextViewController <URBMediaFocusViewControllerDelegate>

@property (strong, nonatomic) ZPGroup *group;

@end
