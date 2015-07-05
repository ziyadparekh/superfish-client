//
//  ContactsManager.m
//  superfish
//
//  Created by Ziyad Parekh on 6/18/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ContactsManager.h"
#import <RestKit/RestKit.h>
#import "MappingProvider.h"
#import "Contacts.h"

static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

static ContactsManager *sharedManager = nil;

@implementation ContactsManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

- (void)loadUserContacts:(void (^)(NSArray *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *currentUser = [userDefaults objectForKey:@"currentUser"];
    NSDictionary *queryParams = @{@"token" : currentUser[@"token"]};
    
    [self getObjectsAtPath:@"/contacts" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            NSArray *contacts = [[NSArray alloc] initWithArray:mappingResult.array];
            success(contacts);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

- (void)postUserContacts:(NSMutableDictionary *)contacts withBlock:(void (^)(NSArray *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *currentUser = [userDefaults objectForKey:@"currentUser"];
    NSDictionary *queryParams = @{@"token" : currentUser[@"token"]};
    //NSDictionary *queryParams = @{@"token" : TeporaryUserToken};
    
    [self postObject:contacts path:@"/contacts" parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            success(mappingResult.array);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

#pragma mark - Setup Helpers

- (void)setupRequestDescriptors
{
    [super setupRequestDescriptors];
    RKObjectMapping *contactsMapping = [MappingProvider postContactsMapping];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:contactsMapping objectClass:[NSMutableDictionary class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    [self addRequestDescriptor:requestDescriptor];
    
}

- (void)setupResponseDescriptors {
    [super setupResponseDescriptors];
    RKObjectMapping *contactsMapping = [MappingProvider contactMapping];
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *fetchContactsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:contactsMapping method:RKRequestMethodAny pathPattern:@"/contacts" keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [self addResponseDescriptor:fetchContactsResponseDescriptor];
}

@end
