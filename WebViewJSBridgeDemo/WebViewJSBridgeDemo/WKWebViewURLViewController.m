//
//  WKWebViewURLViewController.m
//  WebViewJSBridgeDemo
//
//  Created by 赖利波 on 2020/8/18.
//  Copyright © 2020 叶建华. All rights reserved.
//

#import "WKWebViewURLViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>

@interface WKWebViewURLViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (strong, nonatomic)   WKWebView                   *webView;

@end

@implementation WKWebViewURLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [WKUserContentController new];
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 30.0;
        configuration.preferences = preferences;
        
        self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
        
        
    //    NSString *urlStr = @"http://www.baidu.com";
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    //    [self.webView loadRequest:request];
        
        NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"WKWebView-URL.html" ofType:nil];
        NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        [self.view addSubview:self.webView];
}

#pragma mark - private method
- (void)handleCustomAction:(NSURL *)URL
{
    NSString *host = [URL host];
    if ([host isEqualToString:@"scanClick"]) {
        NSLog(@"扫一扫");
    } else if ([host isEqualToString:@"shareClick"]) {
        [self share:URL];
    } else if ([host isEqualToString:@"getLocation"]) {
        [self getLocation];
    } else if ([host isEqualToString:@"setColor"]) {
        [self changeBGColor:URL];
    } else if ([host isEqualToString:@"payAction"]) {
        [self payAction:URL];
    } else if ([host isEqualToString:@"shake"]) {
        [self shakeAction];
    } else if ([host isEqualToString:@"goBack"]) {
        [self goBack];
    }
  
}

- (void)getLocation
{
    // 获取位置信息
    
    // 将结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"广东省深圳市南山区学府路XXXX号"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
   
}

- (void)share:(NSURL *)URL
{
    NSArray *params =[URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
    
    NSString *title = [tempDic objectForKey:@"title"];
    NSString *content = [tempDic objectForKey:@"content"];
    NSString *url = [tempDic objectForKey:@"url"];
    // 在这里执行分享的操作
    
    // 将分享结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)changeBGColor:(NSURL *)URL
{
    NSArray *params =[URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
    CGFloat r = [[tempDic objectForKey:@"r"] floatValue];
    CGFloat g = [[tempDic objectForKey:@"g"] floatValue];
    CGFloat b = [[tempDic objectForKey:@"b"] floatValue];
    CGFloat a = [[tempDic objectForKey:@"a"] floatValue];
    
    self.view.backgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

- (void)payAction:(NSURL *)URL
{
    NSArray *params =[URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
//    NSString *orderNo = [tempDic objectForKey:@"order_no"];
//    long long amount = [[tempDic objectForKey:@"amount"] longLongValue];
//    NSString *subject = [tempDic objectForKey:@"subject"];
//    NSString *channel = [tempDic objectForKey:@"channel"];
    
    // 支付操作
    
    // 将支付结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"payResult('%@', 1)",@"支付成功"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)shakeAction
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void)goBack
{
    [self.webView goBack];
}


#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"haleyaction"]) {
        
        [self handleCustomAction:URL];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
