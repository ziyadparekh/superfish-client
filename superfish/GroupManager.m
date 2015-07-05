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

static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *currentUser = [userDefaults objectForKey:@"currentUser"];
    if (currentUser != nil) {
        NSDictionary *queryParams = @{@"token" : currentUser[@"token"]};
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
