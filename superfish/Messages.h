//
//  Messages.h
//  superfish
//
//  Created by Ziyad Parekh on 6/3/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Messages : NSObject

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *sender;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *group;
@property (nonatomic) BOOL attachment;

@end
