//
//  NewUserManger.h
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"
#import "User.h"

@interface NewUserManager : ZPObjectManager

- (void)createNewUser:(NSMutableDictionary *)user withBlock:(void (^)(User *array))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
