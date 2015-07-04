//
//  MessagesTableViewCell.m
//  superfish
//
//  Created by Ziyad Parekh on 6/4/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "MessagesTableViewCell.h"

@implementation MessagesTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews
{
    [self.contentView addSubview:self.thumbnailView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.bodyLabel];
    [self.contentView addSubview:self.attachmentView];
    
    NSDictionary *views = @{@"thumbnailView": self.thumbnailView,
                            @"titleLabel": self.titleLabel,
                            @"bodyLabel": self.bodyLabel,
                            @"attachmentView": self.attachmentView
                            };
    
    NSDictionary *metrics = @{@"thumbSize": @(kAvatarSize),
                              @"trailing": @10,
                              @"leading": @5,
                              @"attchSize": @80,
                              };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[thumbnailView(thumbSize)]-trailing-[titleLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[thumbnailView(thumbSize)]-trailing-[bodyLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[thumbnailView(thumbSize)]-trailing-[attachmentView]-trailing-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-trailing-[thumbnailView(thumbSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[titleLabel]-leading-[bodyLabel(>=0)]-leading-[attachmentView(>=0,<=attchSize)]-trailing-|" options:0 metrics:metrics views:views]];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.font = [UIFont fontWithName:@"Zapf Dingbats" size:16.0];
    self.bodyLabel.font = [UIFont systemFontOfSize:16.0];
    self.attachmentView.image = nil;
}

#pragma mark - Getters

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.numberOfLines = 0;
        
        _titleLabel.font = [UIFont fontWithName:@"Zapf Dingbats" size:16.0];
        _titleLabel.textColor = [UIColor grayColor];
    }
    return _titleLabel;
}

- (UILabel *)bodyLabel
{
    if (!_bodyLabel) {
        _bodyLabel = [NIAttributedLabel new];
        _bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bodyLabel.backgroundColor = [UIColor clearColor];
        _bodyLabel.userInteractionEnabled = NO;
        _bodyLabel.numberOfLines = 0;
        _bodyLabel.autoDetectLinks = YES;
        _bodyLabel.deferLinkDetection = YES;
        
        _bodyLabel.font = [UIFont systemFontOfSize:16.0];
        _bodyLabel.textColor = [UIColor darkGrayColor];
    }
    return _bodyLabel;
}

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSLog(@"%@", result.URL);
    [[UIApplication sharedApplication] openURL:result.URL];
}

- (UIImageView *)thumbnailView
{
    if (!_thumbnailView) {
        _thumbnailView = [UIImageView new];
        _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailView.userInteractionEnabled = NO;
        _thumbnailView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
        _thumbnailView.layer.cornerRadius = kAvatarSize/15.0;
        _thumbnailView.layer.masksToBounds = YES;
    }
    return _thumbnailView;
}

- (UIImageView *)attachmentView
{
    if (!_attachmentView) {
        _attachmentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        _attachmentView.translatesAutoresizingMaskIntoConstraints = NO;
        _attachmentView.userInteractionEnabled = YES;
        _attachmentView.backgroundColor = [UIColor clearColor];
        _attachmentView.contentMode = UIViewContentModeScaleAspectFill;
        _attachmentView.layer.cornerRadius = kAvatarSize/4.0;
        _attachmentView.layer.masksToBounds = YES;
    }
    return _attachmentView;
}

- (BOOL)needsPlaceholder
{
    return self.thumbnailView.image ? NO : YES;
}


@end
