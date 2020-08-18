
#import "ViewController.h"
#import <WebViewJavascriptBridge.h>
#import <WebKit/WebKit.h>
#import "WKMessageHanderViewController.h"
@interface ViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 2.加载网页
    NSString *indexPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:indexPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [NSURL fileURLWithPath:indexPath];
    
    
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.allowsBackForwardNavigationGestures = YES;
    
    
    [self.webView loadHTMLString:appHtml baseURL:baseUrl];
    
    // 3.开启日志
    [WebViewJavascriptBridge enableLogging];
    
    // 4.给webView建立JS和OC的沟通桥梁
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
    
    /* JS调用OC的API:访问相册 */
    [self.bridge registerHandler:@"openCamera" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"需要%@图片", data[@"count"]);
        
        UIImagePickerController *imageVC = [[UIImagePickerController alloc] init];
        imageVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imageVC animated:YES completion:nil];
    }];
    
    
    /* JS调用OC的API:弹窗互相传递参数
           data JS传递给OC的参数值
           responseCallback 传递给JS的参数值
       */
    [self.bridge registerHandler:@"showBackBtnIcon" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",data] message:@"世界真好" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            responseCallback(@"传给JS参数");

        }];
        [vc addAction:cancelAction];
        [vc addAction:okAction];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    
    [self.bridge registerHandler:@"showAlertTest" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",data] message:@"谢谢简书" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            responseCallback(@"你看看，我给传给JS参数，够不够，不够我再给你多传");

        }];
        [vc addAction:cancelAction];
        [vc addAction:okAction];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    
}

/*  获取用户信息  */
- (IBAction)getUserinfo {
    // 调用JS中的API
    [self.bridge callHandler:@"getJianshuInfo" data:@{@"userId":@"行走在北方"} responseCallback:^(id responseData) {
        NSString *userInfo = [NSString stringWithFormat:@"%@",responseData[@"JsonMessage"]];
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"从网页端获取的用户信息" message:userInfo preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [vc addAction:cancelAction];
        [vc addAction:okAction];
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

/* 弹框显示消息 */
- (IBAction)showInfo {
    // 调用JS中的API
    [self.bridge callHandler:@"alertWindow" data:@"调用了js中的Alert弹窗!" responseCallback:^(id responseData) {
        NSLog(@"=====%@",[responseData objectForKey:@"JsonMessage"]);
    }];
}

/* 控制界面动态跳转 */
- (IBAction)pushToNewWebSite {
    // 调用JS中的API
    [self.bridge callHandler:@"pushToNewWebSite" data:@{@"url":@"https://www.baidu.com"} responseCallback:^(id responseData) {
        
    }];
}

/* 刷新界面 */
- (IBAction)reloadWebPage {
//    [self.webView reload];
    
//    WKMessageHanderViewController *WKVC = [[WKMessageHanderViewController alloc] ini];
//    WKVC.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:WKVC animated:YES completion:nil];
    
}

/* 插入新图片 */
- (IBAction)insertImgToWebPage {
    
    NSDictionary *dict = @{
                           @"url" : @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1597410072788&di=555aaa318bd2a44dc173554195c15f8b&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2017-12-07%2F5a28ab84c7a63.jpg",
                           };
    // 调用JS中的API
    [self.bridge callHandler:@"insertImgToWebPage" data:dict responseCallback:^(id responseData) {
        
    }];
    
}

#pragma mark -- WKUIDelegate
// 显示一个按钮。点击后调用completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示两个按钮，通过completionHandler回调判断用户点击的确定还是取消按钮
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 显示一个带有输入框和一个确定按钮的，通过completionHandler回调用户输入的内容
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
