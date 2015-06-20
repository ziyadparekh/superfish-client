//
//  ZPObjectManager.h
//  superfish
//
//  Created by Ziyad Parekh on 6/16/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "RKObjectManager.h"

@interface ZPObjectManager : RKObjectManager

+ (instancetype)sharedManager;

- (void)setupResponseDescriptors;
- (void)setupRequestDescriptors;

@end
