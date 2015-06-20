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

@implementation MappingProvider

+ (RKObjectMapping *)groupMapping
{
    // setup object mappings
    RKObjectMapping *groupMapping = [RKObjectMapping mappingForClass:[ZPGroup class]];
    [groupMapping addAttributeMappingsFromArray:@[@"name", @"activity", @"groupId", @"members"]];
    
    return groupMapping;
}

+ (RKObjectMapping *)messagesMapping
{
    RKObjectMapping *messagesMapping = [RKObjectMapping mappingForClass:[Messages class]];
    [messagesMapping addAttributeMappingsFromArray:@[@"content", @"time"]];
    
    return messagesMapping;
}

+ (RKObjectMapping *) messagesForGroupMapping
{
    RKObjectMapping *messagesMapping = [RKObjectMapping mappingForClass:[Messages class]];
    [messagesMapping addAttributeMappingsFromArray:@[@"sender", @"type", @"content", @"time", @"group"]];
    
    return messagesMapping;
}

+ (RKObjectMapping *)contactMapping
{
    // setup object mappings
    RKObjectMapping *contactsMapping = [RKObjectMapping mappingForClass:[Contacts class]];
    [contactsMapping addAttributeMappingsFromArray:@[@"username", @"number", @"id"]];
    
    return contactsMapping;
}

+ (RKObjectMapping *)newGroupMapping
{
    RKObjectMapping *newGroupMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [newGroupMapping addAttributeMappingsFromArray:@[@"name", @"members", @"token"]];
    
    return newGroupMapping;
}

@end
