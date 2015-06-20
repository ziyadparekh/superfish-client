//
//  ContactsManager.h
//  superfish
//
//  Created by Ziyad Parekh on 6/18/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"

@interface ContactsManager : ZPObjectManager

- (void) loadUserContacts:(void (^)(NSArray *contacts))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

@end
