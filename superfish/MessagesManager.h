//
//  MessagesManager.h
//  superfish
//
//  Created by Ziyad Parekh on 6/19/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"

@interface MessagesManager : ZPObjectManager

@property (strong, nonatomic) NSString *groupId;
@property (nonatomic) int offset;

- (void) loadGroupMessagesForGroup:(NSString *)groupId withOffset:(int)offset withBlock:(void (^)(NSArray *messages))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

- (void) setGroupId:(NSString *)groupId;
- (void) setOffset:(int)offset;

@end
