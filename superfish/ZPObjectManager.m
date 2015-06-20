//
//  ZPObjectManager.m
//  superfish
//
//  Created by Ziyad Parekh on 6/16/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "ZPObjectManager.h"
#import <RestKit/RestKit.h>

@implementation ZPObjectManager

+ (instancetype)sharedManager
{
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080"];
    
    ZPObjectManager *sharedManager  = [self managerWithBaseURL:url];
    sharedManager.requestSerializationMIMEType = RKMIMETypeJSON;
    /*
     THIS CLASS IS MAIN POINT FOR CUSTOMIZATION:
     - setup HTTP headers that should exist on all HTTP Requests
     - override methods in this class to change default behavior for all HTTP Requests
     - define methods that should be available across all object managers
     */
    
    [sharedManager setupRequestDescriptors];
    [sharedManager setupResponseDescriptors];
    
    return sharedManager;
}

- (void)setupResponseDescriptors
{
    
}
- (void)setupRequestDescriptors
{
    
}

@end
