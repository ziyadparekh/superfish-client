//
//  GroupManager.m
//  superfish
//
//  Created by Ziyad Parekh on 6/16/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "GroupManager.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "ZPGroup.h"

static NSString *TeporaryUserToken = @"557f9a2c3c5d63a12d000001_2fcea5359356eed3c494181d910d3c7dc7cbe76e0ad6e1ebba80d404740c4cd7";

static GroupManager *sharedManager = nil;

@implementation GroupManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

- (void)loadUserGroups:(void (^)(NSArray *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    NSDictionary *queryParams = @{@"token" : TeporaryUserToken};
    [self getObjectsAtPath:@"/groups" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            NSArray *groups = [[NSArray alloc] initWithArray:mappingResult.array];
            success(groups);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

#pragma mark - Setup Helpers

- (void) setupResponseDescriptors {
    [super setupResponseDescriptors];
    RKObjectMapping *groupMapping = [MappingProvider groupMapping];
    RKObjectMapping *messagingMapping = [MappingProvider messagesMapping];
    
    RKRelationshipMapping *rel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"messages" toKeyPath:@"messages" withMapping:messagingMapping];
    [groupMapping addPropertyMapping:rel];
    
    RKResponseDescriptor *fetchGroupsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:groupMapping method:RKRequestMethodGET pathPattern:@"/groups" keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [self addResponseDescriptor:fetchGroupsResponseDescriptor];
}

@end
