//
//  MessagesTableViewCell.h
//  superfish
//
//  Created by Ziyad Parekh on 6/4/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAvatarSize 30.0
#define kMinimumHeight 50.0

@interface MessagesTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *bodyLabel;
@property (strong, nonatomic) UIImageView *thumbnailView;
@property (strong, nonatomic) UIImageView *attachmentView;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (nonatomic, readonly) BOOL needsPlaceholder;
@property (nonatomic) BOOL usedForMessage;

@end
