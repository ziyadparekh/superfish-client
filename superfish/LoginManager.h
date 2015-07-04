//
//  LoginManger.h
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"
#import "User.h"

@interface LoginManager : ZPObjectManager

- (void)loginUser:(NSMutableDictionary *)user withBlock:(void (^)(User *user))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
