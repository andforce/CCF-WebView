//
//  DiscuzMessageTableViewController.m
//  Forum
//
//  Created by 迪远 王 on 2018/4/30.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "DiscuzMessageTableViewController.h"
#import "PrivateMessageTableViewCell.h"
#import "ForumShowPrivateMessageViewController.h"

#import "ForumUserProfileTableViewController.h"
#import "UIStoryboard+Forum.h"
#import "ForumTabBarController.h"

typedef enum {
    PrivateMessage = 0,
    NoticeMessage
} MessageType;

@interface DiscuzMessageTableViewController ()<ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    MessageType _messageType;
    UIStoryboardSegue *selectSegue;
}

@end
@implementation DiscuzMessageTableViewController{
    ViewForumPage *currentForumPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _messageType = PrivateMessage;

    if ([self isNeedHideLeftMenu]){
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;
    
    [self.messageSegmentedControl addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)didClicksegmentedControlAction:(UISegmentedControl *)Seg {
    NSInteger index = Seg.selectedSegmentIndex;
    switch (index) {
        case 0:
            _messageType = PrivateMessage;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
        case 1:
            _messageType = NoticeMessage;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
        default:
            _messageType = PrivateMessage;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
    }
}

- (void)onPullRefresh {
    [self refreshMessage:1];
}


- (void)refreshMessage:(int)page {

    switch (_messageType){
        case PrivateMessage: {
            [self.forumApi listPrivateMessage:page handler:^(BOOL isSuccess, ViewForumPage *message) {
                [self.tableView.mj_header endRefreshing];

                if (isSuccess) {

                    [self.tableView.mj_footer endRefreshing];

                    currentForumPage = message;

                    if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }

                    [self.dataList removeAllObjects];
                    [self.dataList addObjectsFromArray:message.dataList];

                    [self.tableView reloadData];
                }
            }];

            break;
        }
        case NoticeMessage: {
            [self.forumApi listNoticeMessage:page handler:^(BOOL isSuccess, ViewForumPage *message) {
                [self.tableView.mj_header endRefreshing];

                if (isSuccess) {

                    [self.tableView.mj_footer endRefreshing];

                    currentForumPage = message;

                    if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }

                    [self.dataList removeAllObjects];
                    [self.dataList addObjectsFromArray:message.dataList];

                    [self.tableView reloadData];
                }
            }];
            break;
        }
    }
}


- (void)onLoadMore {

    int toLoadPage = currentForumPage == nil ? 1 : currentForumPage.pageNumber.currentPageNumber + 1;
    switch (_messageType){
        case PrivateMessage: {
            [self.forumApi listPrivateMessage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *message) {
                [self.tableView.mj_footer endRefreshing];
                if (isSuccess) {

                    currentForumPage = message;

                    if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }

                    [self.dataList addObjectsFromArray:message.dataList];
                    [self.tableView reloadData];
                }
            }];
            break;
        }
        case NoticeMessage: {
            [self.forumApi listNoticeMessage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *message) {
                [self.tableView.mj_footer endRefreshing];
                if (isSuccess) {

                    currentForumPage = message;

                    if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }

                    [self.dataList addObjectsFromArray:message.dataList];
                    [self.tableView reloadData];
                }
            }];
            break;
        }
        default:
            break;
    }



}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"PrivateMessageTableViewCell";
    PrivateMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.showUserProfileDelegate = self;
    
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    
    Message *message = self.dataList[(NSUInteger) indexPath.row];
    
    [cell setData:message forIndexPath:indexPath];
    
    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
    return cell;
}

- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {

    NSIndexPath *indexPath = cell.indexPath;
    
    Message *deleteMessage = self.dataList[(NSUInteger) indexPath.row];
    NSInteger delType = _messageSegmentedControl.selectedSegmentIndex;
    [self.forumApi deletePrivateMessage:deleteMessage withType:(int)delType handler:^(BOOL isSuccess, id message) {
        if (isSuccess){
            [self.dataList removeObjectAtIndex:(NSUInteger) cell.indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.2f];
        }
    }];
    
    return YES;
}

-(void)reloadData{
    [self.tableView reloadData];
};

#pragma mark CCFThreadListCellDelegate
- (void)showUserProfile:(NSIndexPath *)indexPath {
    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    Message *message = self.dataList[(NSUInteger) indexPath.row];
    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:[message.pmAuthorId intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];
}


#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        ForumShowPrivateMessageViewController *controller = segue.destinationViewController;
        
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        Message *message = self.dataList[(NSUInteger) indexPath.row];
        
        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:message forKey:@"TransPrivateMessage"];
        [bundle putIntValue:(int)_messageSegmentedControl.selectedSegmentIndex forKey:@"TransPrivateMessageType"];
        
        
        [self transBundle:bundle forController:controller];
        
    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}


- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;
    
    [controller showLeftDrawer];
}

- (IBAction)writePrivateMessage:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
    
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"CreatePM"];
    [self.navigationController presentViewController:controller animated:YES completion:^{
        
    }];
}

@end