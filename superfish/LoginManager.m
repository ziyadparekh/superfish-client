//
//  LoginManger.m
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "LoginManager.h"
#import "MappingProvider.h"

static LoginManager *sharedManager = nil;

@implementation LoginManager

- (void)loginUser:(NSMutableDictionary *)user withBlock:(void (^)(User *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    [self postObject:user path:@"/login" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            User *currentUser = [mappingResult.array firstObject];
            success(currentUser);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

- (void)setupRequestDescriptors
{
    [super setupRequestDescriptors];
    
    RKObjectMapping *loginUserMapping = [MappingProvider userLoginMapping];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:loginUserMapping objectClass:[NSMutableDictionary class] rootKeyPath:nil method:RKRequestMethodPOST];
    [self addRequestDescriptor:requestDescriptor];
}

- (void)setupResponseDescriptors
{
    [super setupResponseDescriptors];
    
    RKObjectMapping *userMapping = [MappingProvider userMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:@"/login" keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self addResponseDescriptor:responseDescriptor];
}

@end
