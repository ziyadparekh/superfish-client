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
    Messages *msg = [group.messages objectAtIndex:0];
    return msg.content;
}

- (NSString *)getGroupActivity:(ZPGroup *)group {
    NSString *activity = group.activity;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'-'HH:mm"];
    NSDate *date = [formatter dateFromString:activity];
    
    return [date formattedAsTimeAgo];
}

@end
