//
//  GroupNameManager.h
//  superfish
//
//  Created by Ziyad Parekh on 6/27/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"

@interface GroupNameManager : ZPObjectManager

- (void)updateGroupName:(NSMutableDictionary *)group withBlock:(void (^)(NSArray *array))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;



@end
