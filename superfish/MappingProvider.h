//
//  MappingProvider.h
//  superfish
//
//  Created by Ziyad Parekh on 6/16/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface MappingProvider : NSObject

+ (RKObjectMapping *)userLoginMapping;
+ (RKObjectMapping *)userMapping;
+ (RKObjectMapping *)newUserMapping;
+ (RKObjectMapping *)groupMapping;
+ (RKObjectMapping *)contactMapping;
+ (RKObjectMapping *)messagesMapping;
+ (RKObjectMapping *)newGroupMapping;
+ (RKObjectMapping *)messagesForGroupMapping;
+ (RKObjectMapping *)editGroupNameMapping;
+ (RKObjectMapping *)editGroupMembersMapping;

@end
