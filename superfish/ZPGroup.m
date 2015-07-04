//
//  ZPGroups.m
//  superfish
//
//  Created by Ziyad Parekh on 6/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPGroup.h"

@implementation ZPGroup

- (NSString *)getLastMessageForGroup:(ZPGroup *) group {
    if ([group.messages count] == 0) {
        return @"";
    }
    Messages *msg = [group.messages objectAtIndex:0];
    return msg.content;
}

- (NSArray *)getReadArrayForGroup:(ZPGroup *) group {
    if ([group.messages count] == 0) {
        return @[];
    }
    Messages *msg = [group.messages objectAtIndex:0];
    return msg.read;
}

- (NSString *)getGroupActivity:(ZPGroup *)group {
    NSString *activity = group.activity;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'-'HH:mm"];
    NSDate *date = [formatter dateFromString:activity];
    
    return [date formattedAsTimeAgo];
}

- (NSString *)getGroupName:(ZPGroup *)group
{
    if (group.members.count == 1) {
        return @"Botler";
    }
    if (group.name.length == 0) {
        NSMutableArray *usernames = [[NSMutableArray alloc] initWithCapacity:[group.members count]];
        for (NSDictionary *user in group.members) {
            [usernames addObject:user[@"username"]];
        }
        return [usernames componentsJoinedByString:@", "];
    }
    return group.name;
}

@end
