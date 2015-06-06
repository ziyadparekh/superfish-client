//
//  MessagesViewController.m
//  superfish
//
//  Created by Ziyad Parekh on 6/4/15.
//  Copyright (c) 2015 Ziyad Parekh. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessagesTableViewCell.h"
#import "MessagesTextView.h"
#import "MessagePost.h"
#import "Messages.h"


#import "SRWebSocket.h"
#import <RestKit/RestKit.h>
#import "FLAnimatedImageView+AFNetworking.h"

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";
// TODO:: REMOVE THESE
static NSString *TemporaryGroupId = @"5563b70a3c5d631c51000001";
static NSString *TeporaryUserToken = @"555e8e2e3c5d6387f9000001_bdbc5703808422d840e76aa1d0480f103c634becf814baf6aa2b5d5f05de12a8";

@interface MessagesViewController () <SRWebSocketDelegate>

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSArray *emojis;

- (IBAction)reconnect:(id)sender;

@end

@implementation MessagesViewController {
    SRWebSocket *_webSocket;
}


#pragma mark - Initializer

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self registerClassForTextView:[MessagesTextView class]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self registerClassForTextView:[MessagesTextView class]];
    }
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do view setup here.
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = YES;
    self.inverted = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MessagesTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    
    self.typingIndicatorView.canResignByTouch = YES;
    
    [self.autoCompletionView registerClass:[MessagesTableViewCell class] forCellReuseIdentifier:AutoCompletionCellIdentifier];
    [self registerPrefixesForAutoCompletion:@[@"/"]];
    
    [self configureRestkit];
    [self loadMessages];
    
}

#pragma mark - RestKit Configuration

- (void)configureRestkit
{
    NSURL *baseUrl = [NSURL URLWithString:@"http://localhost:8080"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *messagesMapping = [RKObjectMapping mappingForClass:[Messages class]];
    [messagesMapping addAttributeMappingsFromArray:@[@"sender",
                                                     @"type",
                                                     @"content",
                                                     @"time",
                                                     @"group"]];
    
    RKResponseDescriptor *responseDiscriptor = [RKResponseDescriptor responseDescriptorWithMapping:messagesMapping method:RKRequestMethodGET pathPattern:[NSString stringWithFormat:@"/group/%@/messages", TemporaryGroupId] keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:responseDiscriptor];
}

- (void)loadMessages
{
    NSDictionary *queryParams = @{@"token": TeporaryUserToken,
                                  @"limit": @20,
                                  @"offset": @0
                                  };
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/group/%@/messages", TemporaryGroupId] parameters:queryParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.messages = [[[mappingResult.array reverseObjectEnumerator] allObjects] mutableCopy];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"There was an error : %@", error);
    }];
}

- (void)editCellMessage:(UIGestureRecognizer *)gesture
{
    MessagesTableViewCell *cell = (MessagesTableViewCell *)gesture.view;
    Messages *message = self.messages[cell.indexPath.row];
    
    [self editText:message.content];
    
    [self.tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)editLastMessage:(id)sender
{
    if (self.textView.text.length > 0) {
        return;
    }
    
    NSInteger lastSectionIndex = [self.tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex] - 1;
    
    Messages *lastMessage = [self.messages objectAtIndex:lastRowIndex];
    [self editText:lastMessage.content];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - SocketRocket Delegate

- (void)_reconnect
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    NSString *formattedUrl = [NSString stringWithFormat:@"ws://localhost:8080/ws/%@?token=%@", TemporaryGroupId, TeporaryUserToken];
    NSURL *websocketUrl = [NSURL URLWithString:formattedUrl];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websocketUrl];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:urlRequest];
    _webSocket.delegate = self;
    NSLog(@"Opening connection to %@", formattedUrl);
    [_webSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    [self.rightButton setEnabled:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    _webSocket = nil;
    // TODO:: disable send button
    [self.rightButton setEnabled:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *msg = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    Messages *newMessage = [Messages new];
    newMessage.content = [msg valueForKey:@"content"];
    newMessage.group = [msg valueForKey:@"group"];
    newMessage.time = [msg valueForKey:@"time"];
    newMessage.type = [msg valueForKey:@"type"];
    newMessage.sender = [msg valueForKey:@"sender"];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count inSection:0];

    [self.tableView beginUpdates];
    [self.messages insertObject:newMessage atIndex:self.messages.count];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    _webSocket = nil;
    [self.rightButton setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _reconnect];
}

- (void)reconnect:(id)sender
{
    [self _reconnect];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
}

#pragma mark - SLKTextViewController Events

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status
{
    // Notifies the view controller that the keyboard changed status.
    // Calling super does nothing
}

- (void)textWillUpdate
{
    // Notifies the view controller that the text will update.
    // Calling super does nothing
    
    [super textWillUpdate];
}

- (void)textDidUpdate:(BOOL)animated
{
    // Notifies the view controller that the text did update.
    // Must call super
    
    [super textDidUpdate:animated];
}

- (BOOL)canPressRightButton
{
    // Asks if the right button can be pressed
    
    return [super canPressRightButton];
}

- (void)didPressRightButton:(id)sender
{
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    // Must call super
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    NSError *error;
    NSDictionary *message = @{@"content": [self.textView.text copy],
                              @"groupId": TemporaryGroupId};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:kNilOptions error:&error];
    NSString *msgString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [_webSocket send:msgString];
    
    [super didPressRightButton:sender];
}



/*
// Uncomment these methods for aditional events
- (void)didPressLeftButton:(id)sender
{
    // Notifies the view controller when the left button's action has been triggered, manually.
 
    [super didPressLeftButton:sender];
}
 
- (id)keyForTextCaching
{
    // Return any valid key object for enabling text caching while composing in the text view.
    // Calling super does nothing
}

- (void)didPasteMediaContent:(NSDictionary *)userInfo
{
    // Notifies the view controller when a user did paste a media content inside of the text view
    // Calling super does nothing
}

- (void)willRequestUndo
{
    // Notification about when a user did shake the device to undo the typed text
 
    [super willRequestUndo];
}
*/

#pragma mark - SLKTextViewController Edition

/*
// Uncomment these methods to enable edit mode
- (void)didCommitTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
 
    [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the left "Cancel" button
 
    [super didCancelTextEditing:sender];
}
*/

#pragma mark - SLKTextViewController Autocompletion

/*
// Uncomment these methods to enable autocompletion mode
- (BOOL)canShowAutoCompletion
{
    // Asks of the autocompletion view should be shown
 
    return NO;
}

- (CGFloat)heightForAutoCompletionView
{
    // Asks for the height of the autocompletion view
 
    return 0.0;
}
*/


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Returns the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return self.messages.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [self messageCellForRowAtIndexPath:indexPath];
    } else {
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    }
}

- (MessagesTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagesTableViewCell *cell = (MessagesTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    Messages *message = self.messages[indexPath.row];
    
    cell.attachmentView.image = nil;
    cell.attachmentView.animatedImage = nil;
    
    if ([self didMessageContainImageURL:message.content]) {
        [cell.attachmentView setImageWithURL:[NSURL URLWithString:message.content]];
        cell.attachmentView.layer.shouldRasterize = YES;
        cell.attachmentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        message.attachment = YES;
    } else if ([self didMessageContainGifURL:message.content]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:message.content]];
        [cell.attachmentView setAnimatedImageWithURLRequest:request placeholderImage:nil success:nil failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failure downloading gif, %@", error);
        }];
        cell.attachmentView.layer.shouldRasterize = YES;
        cell.attachmentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        message.attachment = YES;
    }
    
    cell.titleLabel.text = message.sender;
    cell.bodyLabel.text = message.attachment ? @"Attachment" : message.content;
    
    cell.indexPath = indexPath;
    cell.usedForMessage = YES;
    
    // Cells must inherit the table views transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (BOOL)didMessageContainImageURL:(NSString *)content
{
    NSError *regexError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(https?:\/\/.*\.(?:png|jpg|jpeg))" options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:content options:0 range:NSMakeRange(0, [content length])];
    if (numberOfMatches > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)didMessageContainGifURL:(NSString *)content
{
    NSError *regexError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(https?:\/\/.*\.(?:gif))" options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:content options:0 range:NSMakeRange(0, [content length])];
    if (numberOfMatches > 0) {
        return YES;
    }
    return NO;
}

- (MessagesTableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagesTableViewCell *cell = (MessagesTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
    cell.indexPath = indexPath;
    
//    NSString *item = self.searchResult[indexPath.row];
//    
//    if ([self.foundPrefix isEqualToString:@"#"]) {
//        item = [NSString stringWithFormat:@"# %@", item];
//    }
//    else if ([self.foundPrefix isEqualToString:@":"]) {
//        item = [NSString stringWithFormat:@":%@:", item];
//    }
    
    cell.titleLabel.text = @"dibsy";
    cell.titleLabel.font = [UIFont systemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        Messages *message = self.messages[indexPath.row];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame) - kAvatarSize;
        width -= 25.0;
        
        CGRect titleBounds = [message.sender boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect bodyBounds = [message.content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        if (message.content.length == 0) {
            return 0.0;
        }
        
        CGFloat height = CGRectGetHeight(titleBounds);
        height += CGRectGetHeight(bodyBounds);
        height += 40.0;
        if (message.attachment) {
            height += 80.0 + 10.0;
        }
        
        if (height < kMinimumHeight) {
            height = kMinimumHeight;
        }
        return height;
    } else {
        return kMinimumHeight;
    }
}



#pragma mark - <UITableViewDelegate>

/*
// Uncomment this method to handle the cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {

    }
    if ([tableView isEqual:self.autoCompletionView]) {

        [self acceptAutoCompletionWithString:<#@"any_string"#>];
    }
}
*/


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    
}

@end
