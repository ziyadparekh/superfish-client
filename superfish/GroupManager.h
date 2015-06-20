//
//  GroupManager.h
//  superfish
//
//  Created by Ziyad Parekh on 6/16/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"

@interface GroupManager : ZPObjectManager

- (void) loadUserGroups:(void (^)(NSArray *groups))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
