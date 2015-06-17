//
//  ZPGroups.h
//  superfish
//
//  Created by Ziyad Parekh on 6/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NSDate-Time-Ago/NSDate+NVTimeAgo.h>

#import "Messages.h"

@interface ZPGroup : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *activity;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSArray *members;
@property (strong, nonatomic) NSString *admin;

- (NSString *)getLastMessageForGroup:(ZPGroup *) group;
- (NSString *)getGroupActivity:(ZPGroup *)group;

@end
