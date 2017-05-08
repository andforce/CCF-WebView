//
// Created by 迪远 王 on 2017/5/7.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "ForumLoginWebViewController.h"
#import "IGXMLNode+Children.h"

#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "NSUserDefaults+Extensions.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "AppDelegate.h"
#import "UIStoryboard+Forum.h"

@interface ForumLoginWebViewController () <UIWebViewDelegate> {

}

@end

@implementation ForumLoginWebViewController {

}

- (void)viewDidLoad {
    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

//    for (UIView *view in [[self.webView subviews][0] subviews]) {
//        if ([view isKindOfClass:[UIImageView class]]) {
//            view.hidden = YES;
//        }
//    }
    [self.webView setOpaque:NO];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.chiphell.com/member.php?mod=logging&action=login&mobile=2"]]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *lJs = @"document.documentElement.outerHTML";
    NSString * html = [webView stringByEvaluatingJavaScriptFromString:lJs];

    IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode * logined = [document queryNodeWithXPath:@"/html/body/div[1]"];

    NSString * name = [logined childrenAtPosition:0].text;

    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    [self.forumApi listAllForums:^(BOOL isSuccess, id msg) {
        if (isSuccess) {
            NSMutableArray<Forum *> *needInsert = msg;
            ForumCoreDataManager *formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
            // 需要先删除之前的老数据
            [formManager deleteData:^NSPredicate * {
                return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
            }];

            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
                ForumEntry *newsInfo = (ForumEntry *) target;
                newsInfo.forumId = [src valueForKey:@"forumId"];
                newsInfo.forumName = [src valueForKey:@"forumName"];
                newsInfo.parentForumId = [src valueForKey:@"parentForumId"];
                newsInfo.forumHost = appDelegate.forumHost;

            }];

            UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
            [stortboard changeRootViewControllerTo:kForumTabBarControllerId];

        }
    }];
    NSLog(@"shouldStartLoadWithRequest %@", html);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"shouldStartLoadWithRequest %@", @"webViewDidStartLoad");
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *urlString = [[request URL] absoluteString];


    if ([urlString isEqualToString:@"https://www.chiphell.com/?mobile=2"]){
        NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    }
    NSLog(@"shouldStartLoadWithRequest %@", urlString);
    return YES;
}
- (IBAction)cancelLogin:(id)sender {
}
@end