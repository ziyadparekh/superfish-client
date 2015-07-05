//
//  GroupMembersManager.m
//  superfish
//
//  Created by Ziyad Parekh on 6/28/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "GroupMembersManager.h"
#import "MappingProvider.h"

static GroupMembersManager *sharedManager = nil;

@implementation GroupMembersManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

- (void)updateGroupMembers:(NSMutableDictionary *)group withBlock:(void (^)(NSArray *array))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/group/%@/members", group[@"groupId"]];
    [self putObject:group path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            success(mappingResult.array);
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
    RKObjectMapping *editGroupMembersMapping = [MappingProvider editGroupMembersMapping];
    
    RKRequestDescriptor *membersDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:editGroupMembersMapping objectClass:[NSMutableDictionary class] rootKeyPath:nil method:RKRequestMethodPUT];

    [self addRequestDescriptor:membersDescriptor];
}

- (void)setupResponseDescriptors
{
    [super setupResponseDescriptors];
    RKObjectMapping * emptyMapping = [RKObjectMapping mappingForClass:[NSNull class]];
    RKResponseDescriptor * responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:emptyMapping
                                                                                             method:RKRequestMethodPUT
                                                                                        pathPattern:nil keyPath:nil
                                                                                        statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [self addResponseDescriptor:responseDescriptor];
}



@end
