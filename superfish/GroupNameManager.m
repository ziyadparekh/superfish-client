//
//  GroupNameManager.m
//  superfish
//
//  Created by Ziyad Parekh on 6/27/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "GroupNameManager.h"
#import "MappingProvider.h"

static GroupNameManager *sharedManager = nil;

@implementation GroupNameManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

- (void)updateGroupName:(NSMutableDictionary *)group withBlock:(void (^)(NSArray *array))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/group/%@/name", group[@"groupId"]];
    [self putObject:group path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            NSLog(@"success");
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
    RKObjectMapping *editGroupNameMapping = [MappingProvider editGroupNameMapping];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:editGroupNameMapping objectClass:[NSMutableDictionary class] rootKeyPath:nil method:RKRequestMethodPUT];

    [self addRequestDescriptor:requestDescriptor];
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
