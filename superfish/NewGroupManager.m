//
//  NewGroupManager.m
//  superfish
//
//  Created by Ziyad Parekh on 6/18/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "NewGroupManager.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"

static NSString *TeporaryUserToken = @"557f9a2c3c5d63a12d000001_2fcea5359356eed3c494181d910d3c7dc7cbe76e0ad6e1ebba80d404740c4cd7";

static NewGroupManager *sharedManager = nil;

@implementation NewGroupManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

- (void)createNewGroup:(NSMutableDictionary *)group withBlock:(void (^)(NSArray *))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    [self postObject:group path:@"/group" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            NSArray *newGroup = [[NSArray alloc] initWithArray:mappingResult.array];
            success(newGroup);
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
    RKObjectMapping *newGroupMapping = [MappingProvider newGroupMapping];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:newGroupMapping objectClass:[NSMutableDictionary class] rootKeyPath:nil method:RKRequestMethodAny];
    [self addRequestDescriptor:requestDescriptor];
}

- (void) setupResponseDescriptors {
    [super setupResponseDescriptors];
    
    RKObjectMapping *groupMapping = [MappingProvider groupMapping];
    RKObjectMapping *messagingMapping = [MappingProvider messagesMapping];
    
    RKRelationshipMapping *rel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"messages" toKeyPath:@"messages" withMapping:messagingMapping];
    [groupMapping addPropertyMapping:rel];
    
    RKResponseDescriptor *fetchGroupsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:groupMapping method:RKRequestMethodAny pathPattern:@"/group" keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [self addResponseDescriptor:fetchGroupsResponseDescriptor];
}

@end
