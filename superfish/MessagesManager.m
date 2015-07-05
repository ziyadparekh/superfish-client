//
//  MessagesManager.m
//  superfish
//
//  Created by Ziyad Parekh on 6/19/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "MessagesManager.h"
#import "MappingProvider.h"

static MessagesManager *sharedManager = nil;

static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

@implementation MessagesManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

- (void)loadGroupMessagesForGroup:(NSString *)groupId withOffset:(int)offset withBlock:(void (^)(NSArray *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *currentUser = [userDefaults objectForKey:@"currentUser"];
    NSDictionary *queryParams = @{@"token": currentUser[@"token"],
                                  @"limit": @20,
                                  @"offset": [NSNumber numberWithInt:offset]};
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/group/%@/messages", groupId] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            success(mappingResult.array);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}


@end
