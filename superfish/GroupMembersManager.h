//
//  GroupMembersManager.h
//  superfish
//
//  Created by Ziyad Parekh on 6/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"

@interface GroupMembersManager : ZPObjectManager

- (void)updateGroupMembers:(NSMutableDictionary *)group withBlock:(void (^)(NSArray *array))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
