//
//  NewGroupManager.h
//  superfish
//
//  Created by Ziyad Parekh on 6/18/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"

@interface NewGroupManager : ZPObjectManager

- (void)createNewGroup:(NSMutableDictionary *)group withBlock:(void (^)(NSArray *array))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
