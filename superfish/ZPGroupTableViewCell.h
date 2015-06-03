//
//  ZPGroupTableViewCell.h
//  superfish
//
//  Created by Ziyad Parekh on 6/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZPGroupTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *groupName;
@property (strong, nonatomic) IBOutlet UILabel *groupMessage;
@property (strong, nonatomic) IBOutlet UILabel *groupDate;

@end
