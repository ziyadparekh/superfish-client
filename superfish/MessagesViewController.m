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
#import "Messages.h"
#import "MessagesManager.h"
#import "MappingProvider.h"
#import "GroupDetailsTableViewController.h"
#import "Helpers.h"


#import "SRWebSocket.h"
#import <RestKit/RestKit.h>
#import "UIImageView+WebCache.h"
#import "URBMediaFocusViewController.h"
#import "AYVibrantButton.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";
static NSString *REGEX_JPG_PNG = @"(https?:\/\/.*\.(?:png|jpg|jpeg))";
static NSString *REGEX_GIF = @"(https?:\/\/.*\.(?:gif))";
// TODO:: REMOVE THESE
static NSString *TemporaryGroupId = @"557fb60a3c5d63b6ab000001";
static NSString *TeporaryUserToken = @"557fa14f3c5d63a5cc000001_a34fecc9a98c34eb45e77f9153bf8d4959facacd2db395fb67cbf3a1d5fd6ddc";

@interface MessagesViewController () <SRWebSocketDelegate, GroupDetailsDelegate>

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSArray *emojis;
@property (strong, nonatomic) NSArray *colorArray;
@property (nonatomic, strong) NSArray *searchResult;
@property (nonatomic) int offset;

@property (nonatomic, strong) URBMediaFocusViewController *mediaFocusController;

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
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = NO;
    self.tableView.scrollsToTop = NO;
    
    self.messages = [[NSMutableArray alloc] init];
    self.offset = 0;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MessagesTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0]];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    
    self.typingIndicatorView.canResignByTouch = YES;
    
    self.mediaFocusController = [[URBMediaFocusViewController alloc] init];
    self.mediaFocusController.delegate = self;
    
    self.emojis = @[@"image", @"animate", @"map", @"google", @"stock"];
    self.colorArray = @[@"brownColor", @"redColor", @"blueColor", @"yellowColor", @"greenColor"];
    
    [self.autoCompletionView registerClass:[MessagesTableViewCell class] forCellReuseIdentifier:AutoCompletionCellIdentifier];
    [self registerPrefixesForAutoCompletion:@[@":"]];
    
    self.title = [self.group getGroupName:self.group];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Zapf Dingbats" size:21], NSFontAttributeName, nil]];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0];;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.currentUser = [userDefaults objectForKey:@"currentUser"];
    
    self.tableView.tableHeaderView = [self getLoadMoreViewForTableHeader];
    
    [self loadMessages];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.messages.count > 0) {
        unsigned long lastRow = self.messages.count - 1;
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)showGroupDetails
{
    NSLog(@"%@", self.group);
    
}

- (NSDictionary *)allIcons
{
    return @{
        @"image" : @"\uf083",
        @"animate": @"\uf03d",
        @"map" : @"\uf041",
        @"google" : @"\uf1a0",
        @"stock": @"\uf0d6"
    };
}

- (FAKFontAwesome *)formatIconsWithCode:(NSString *)code
{
    NSString *key = [[Helpers allIcons] objectForKey:code];
    FAKFontAwesome *icon = [FAKFontAwesome iconWithCode:key size:9];
    return icon;
}


- (UIView *)getLoadMoreViewForTableHeader
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    view.backgroundColor = [UIColor clearColor];
    AYVibrantButton *button = [[AYVibrantButton alloc] initWithFrame:CGRectMake(0, 0, 320, 40) style:AYVibrantButtonStyleTranslucent];
    button.vibrancyEffect = nil;
    button.text = @"Load More";
    button.font = [UIFont fontWithName:@"Zapf Dingbats" size:18.0];
    button.backgroundColor = [UIColor colorWithRed:32.0/255 green:206.0/255 blue:153.0/255 alpha:1.0];
    button.borderWidth = 1.0;
    [button addGestureRecognizer:[self getTapGestureRecognizer]];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [view addSubview:button];
    return view;
}

- (UIGestureRecognizer *)getTapGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LoadMoreButtonWasPressed:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    return tapGesture;
}

- (void)LoadMoreButtonWasPressed:(UIGestureRecognizer *)gesture
{
    
    NSLog(@"%@", gesture.view);
    self.offset += 20;
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
    
    RKResponseDescriptor *responseDiscriptor = [RKResponseDescriptor responseDescriptorWithMapping:messagesMapping method:RKRequestMethodGET pathPattern:[NSString stringWithFormat:@"/group/%@/messages", self.group.groupId] keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:responseDiscriptor];
}

- (void)loadMessages
{
    RKObjectMapping *messagesMapping = [MappingProvider messagesForGroupMapping];
    RKResponseDescriptor *responseDiscriptor = [RKResponseDescriptor responseDescriptorWithMapping:messagesMapping method:RKRequestMethodGET pathPattern:[NSString stringWithFormat:@"/group/%@/messages", self.group.groupId] keyPath:@"response" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [[MessagesManager sharedManager] addResponseDescriptor:responseDiscriptor];
    
    [[MessagesManager sharedManager] loadGroupMessagesForGroup:self.group.groupId withOffset:self.offset withBlock:^(NSArray *messages) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[messages count])];
        [self.messages insertObjects:[[messages reverseObjectEnumerator] allObjects] atIndexes:indexes];
        if (messages.count < 20) {
            self.tableView.tableHeaderView = nil;
        }
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"There was an error : %@", error);
    }];
}

- (void)sendReadMessagesSignal
{
    NSError *error;
    NSDictionary *message = @{@"content": @"",
                              @"type": @"Read",
                              @"groupId": self.group.groupId};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:kNilOptions error:&error];
    NSString *msgString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [_webSocket send:msgString];
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
    
    NSString *formattedUrl = [NSString stringWithFormat:@"ws://localhost:8080/ws/%@?token=%@", self.group.groupId, self.currentUser[@"token"]];
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
    [self sendReadMessagesSignal];
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
    newMessage.avatar = [msg valueForKey:@"avatar"];

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
    [self sendReadMessagesSignal];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        if (self.delegate != nil) {
            [self.delegate didGoBackToGroupViewControllerFrom:self];
        }
    }
    
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
                              @"type": @"Text",
                              @"avatar": self.currentUser[@"avatar"],
                              @"groupId": self.group.groupId};
    
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


// Uncomment these methods to enable autocompletion mode
- (BOOL)canShowAutoCompletion
{
    // Asks of the autocompletion view should be shown
    NSArray *array = nil;
    NSString *prefix = self.foundPrefix;
    NSString *word = self.foundWord;
    
    self.searchResult = nil;
    
    if ([prefix isEqualToString:@":"] && word.length > 1) {
        array = [self.emojis filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    }
    
    if (array.count > 0) {
        array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    self.searchResult = [[NSMutableArray alloc] initWithArray:array];
    
    return self.searchResult.count > 0;
}

- (CGFloat)heightForAutoCompletionView
{
    // Asks for the height of the autocompletion view
 
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight*self.searchResult.count;
}



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
    else {
        return self.searchResult.count;
    }
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
    
    if (!cell.textLabel.text) {
        UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFocusView:)];
        tapPress.numberOfTapsRequired = 1;
        tapPress.numberOfTouchesRequired = 1;
        [cell.attachmentView addGestureRecognizer:tapPress];
    }
    
    cell.attachmentView.image = nil;
    NSString *attachment = [self getAttachment:message.content];
    if (attachment) {
        [cell.attachmentView sd_setImageWithURL:[NSURL URLWithString:attachment]];
        cell.attachmentView.layer.shouldRasterize = YES;
        cell.attachmentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        message.attachment = YES;
    }
    
    cell.titleLabel.text = message.sender;
    cell.bodyLabel.text = message.content;
    
    [cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:message.avatar]];
    cell.thumbnailView.layer.shouldRasterize = YES;
    cell.thumbnailView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    cell.indexPath = indexPath;
    cell.usedForMessage = YES;
    
    // Cells must inherit the table views transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (void)showFocusView:(UITapGestureRecognizer *)gestureRecognizer
{
    UIImageView *tappedImageView = (UIImageView *)gestureRecognizer.view;
    UIImage *img = tappedImageView.image;
    [self.mediaFocusController showImage:img fromView:tappedImageView];
}

- (NSString *)getAttachment:(NSString *)content
{
    if ([self isStringGifData:content]) {
        return [self isStringGifData:content];
    } else if ([self isStringJPEGData:content]) {
        return [self isStringJPEGData:content];
    } else {
        return nil;
    }
}

- (NSString *)isStringGifData:(NSString *)content
{
    NSString *gifData = [self didMessageContainImageURL:content withPattern:REGEX_GIF];
    if (gifData) {
        return gifData;
    }
    return nil;
}

-(NSString *)isStringJPEGData:(NSString *)content
{
    NSString *jpegData = [self didMessageContainImageURL:content withPattern:REGEX_JPG_PNG];
    if (jpegData) {
        return jpegData;
    }
    return nil;
}

- (NSString *)didMessageContainImageURL:(NSString *)content withPattern:(NSString *)regexString
{
    NSError *regexError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&regexError];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:content options:0 range:NSMakeRange(0, [content length])];
    if (numberOfMatches > 0) {
        NSTextCheckingResult *match = [regex firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
        NSString *subString = [content substringWithRange:match.range];
        return subString;
    }
    return nil;
}

- (MessagesTableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagesTableViewCell *cell = (MessagesTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
    cell.indexPath = indexPath;
    
    NSString *item = self.searchResult[indexPath.row];
    FAKFontAwesome *faIcon = [self formatIconsWithCode:item];
    [faIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor]];

    UIImage *iconImage = [faIcon imageWithSize:CGSizeMake(11, 11)];
    
    cell.titleLabel.text = item;
    cell.thumbnailView.image = iconImage;
    cell.thumbnailView.backgroundColor = [UIColor whiteColor];
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


// Uncomment this method to handle the cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.autoCompletionView]) {
        NSString* hubot = @"hubot ";
        NSMutableString *item = [self.searchResult[indexPath.row] mutableCopy];
        
//        if ([self.foundPrefix isEqualToString:@"@"] && self.foundPrefixRange.location == 0) {
//            [item appendString:@":"];
//        }
//        else if ([self.foundPrefix isEqualToString:@":"]) {
//            [item appendString:@":"];
//        }
        
        [item appendString:@" "];
        NSString* result = [hubot stringByAppendingString:item];
        
        [self acceptAutoCompletionWithString:result keepPrefix:NO];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MessageToDetailsSegue"]) {
        GroupDetailsTableViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.delegate = self;
        destinationViewController.group = self.group;
    }
}

- (void)didUpdateGroupName:(NSString *)groupName
{
    self.title = groupName;
}

#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    
}

@end
