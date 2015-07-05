//
//  NewUserManger.m
//  superfish
//
//  Created by Ziyad Parekh on 7/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "NewUserManager.h"
#import "MappingProvider.h"

static NewUserManager *sharedManager = nil;

@implementation NewUserManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

- (void)createNewUser:(NSMutableDictionary *)user withBlock:(void (^)(User *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    [self postObject:user path:@"/signup" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            User *newUser = [mappingResult.array firstObject];
            NSLog(@"%@", newUser);
            success(newUser);
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
    
    RKObjectMapping *newUserMapping = [MappingProvider newUserMapping];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:newUserMapping objectClass:[NSMutableDictionary class] rootKeyPath:nil method:RKRequestMethodPOST];
    [self addRequestDescriptor:requestDescriptor];
}

- (void)setupResponseDescriptors
{
    [super setupResponseDescriptors];
    
    RKObjectMapping *userMapping = [MappingProvider userMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodPOST pathPattern:@"/signup" keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self addResponseDescriptor:responseDescriptor];
}

@end
