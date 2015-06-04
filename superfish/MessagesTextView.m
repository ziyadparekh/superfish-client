//
//  MessagesTextView.m
//  superfish
//
//  Created by Ziyad Parekh on 6/4/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "MessagesTextView.h"

@implementation MessagesTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) init
{
    if (self = [super init]) {
        // do something
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.backgroundColor = [UIColor whiteColor];
    self.placeholder = NSLocalizedString(@"Message", nil);
    self.pastableMediaTypes = SLKPastableMediaTypeAll;
    
    self.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0].CGColor;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
