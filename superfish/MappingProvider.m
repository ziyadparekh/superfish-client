//
//  MappingProvider.m
//  superfish
//
//  Created by Ziyad Parekh on 6/16/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "MappingProvider.h"
#import "ZPGroup.h"
#import "Messages.h"
#import "Contacts.h"
#import "User.h"

@implementation MappingProvider

+ (RKObjectMapping *)userLoginMapping
{
    RKObjectMapping *userLoginMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [userLoginMapping addAttributeMappingsFromArray:@[@"username", @"password"]];
    
    return userLoginMapping;
}

+ (RKObjectMapping *)userMapping
{
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[User class]];
    [userMapping addAttributeMappingsFromArray:@[@"username", @"number", @"token", @"avatar"]];
    
    return userMapping;
}

+ (RKObjectMapping *)newUserMapping
{
    RKObjectMapping *newUserMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [newUserMapping addAttributeMappingsFromArray:@[@"username", @"number", @"password"]];
    
    return newUserMapping;
}

+ (RKObjectMapping *)groupMapping
{
    // setup object mappings
    RKObjectMapping *groupMapping = [RKObjectMapping mappingForClass:[ZPGroup class]];
    [groupMapping addAttributeMappingsFromArray:@[@"name", @"activity", @"groupId", @"members", @"admin"]];
    
    return groupMapping;
}

+ (RKObjectMapping *)editGroupNameMapping
{
    RKObjectMapping *groupNameMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [groupNameMapping addAttributeMappingsFromArray:@[@"name", @"token"]];
    
    return groupNameMapping;
}

+ (RKObjectMapping *)editGroupMembersMapping
{
    RKObjectMapping *groupMembersMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [groupMembersMapping addAttributeMappingsFromArray:@[@"members", @"token"]];
    
    return groupMembersMapping;
}

+ (RKObjectMapping *)messagesMapping
{
    RKObjectMapping *messagesMapping = [RKObjectMapping mappingForClass:[Messages class]];
    [messagesMapping addAttributeMappingsFromArray:@[@"content", @"time", @"read"]];
    
    return messagesMapping;
}

+ (RKObjectMapping *) messagesForGroupMapping
{
    RKObjectMapping *messagesMapping = [RKObjectMapping mappingForClass:[Messages class]];
    [messagesMapping addAttributeMappingsFromArray:@[@"sender", @"type", @"content", @"time", @"group", @"read", @"avatar"]];
    
    return messagesMapping;
}

+ (RKObjectMapping *)contactMapping
{
    // setup object mappings
    RKObjectMapping *contactsMapping = [RKObjectMapping mappingForClass:[Contacts class]];
    [contactsMapping addAttributeMappingsFromArray:@[@"username", @"number", @"id"]];
    
    return contactsMapping;
}

+ (RKObjectMapping *)postContactsMapping
{
    RKObjectMapping *contactsMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [contactsMapping addAttributeMappingsFromArray:@[@"contacts"]];
    
    return contactsMapping;
}

+ (RKObjectMapping *)newGroupMapping
{
    RKObjectMapping *newGroupMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [newGroupMapping addAttributeMappingsFromArray:@[@"name", @"members", @"token"]];
    
    return newGroupMapping;
}

@end
