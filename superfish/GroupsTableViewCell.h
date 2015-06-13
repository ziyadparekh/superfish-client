//
//  GroupsTableViewCell.h
//  superfish
//
//  Created by Ziyad Parekh on 6/9/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupsTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *groupNameLabel;
@property (strong, nonatomic) UILabel *lastMessageTextLabel;
@property (strong, nonatomic) UILabel *lastMessageSentDateLabel;

@end
