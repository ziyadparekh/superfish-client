//
//  GroupsTableViewCell.m
//  superfish
//
//  Created by Ziyad Parekh on 6/9/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "GroupsTableViewCell.h"

CGFloat chatTableViewCellHeight = 72.0;
CGFloat chatTableViewCellInsetLeft = 30.0;

@implementation GroupsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.groupNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.groupNameLabel.backgroundColor = [UIColor whiteColor];
        self.groupNameLabel.font = [UIFont boldSystemFontOfSize:17];
        
        self.lastMessageSentDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lastMessageSentDateLabel.backgroundColor = [UIColor whiteColor];
        self.lastMessageSentDateLabel.font = [UIFont systemFontOfSize:15];
        self.lastMessageSentDateLabel.textColor = [UIColor lightGrayColor];
        self.lastMessageSentDateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        self.lastMessageTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lastMessageTextLabel.backgroundColor = [UIColor whiteColor];
        self.lastMessageTextLabel.font = [UIFont systemFontOfSize:15];
        self.lastMessageTextLabel.numberOfLines = 2;
        self.lastMessageTextLabel.textColor = self.lastMessageSentDateLabel.textColor;
        
        [self.contentView addSubview:self.groupNameLabel];
        [self.contentView addSubview:self.lastMessageSentDateLabel];
        [self.contentView addSubview:self.lastMessageTextLabel];
        
        [self.groupNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.groupNameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:chatTableViewCellInsetLeft]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.groupNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:6]];
        
        [self.lastMessageTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.groupNameLabel attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:28]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-7]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-4]];
        
        [self.lastMessageSentDateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageSentDateLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.groupNameLabel attribute:NSLayoutAttributeRight multiplier:1 constant:2]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageSentDateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-7]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageSentDateLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.groupNameLabel attribute:NSLayoutAttributeBaseline multiplier:1 constant:0]];
        
    }
    return self;
}

@end
