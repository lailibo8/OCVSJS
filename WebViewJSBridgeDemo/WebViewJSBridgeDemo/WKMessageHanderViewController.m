//
//  WKMessageHanderViewController.m
//  WebViewJSBridgeDemo
//
//  Created by 赖利波 on 2020/8/17.
//  Copyright © 2020 叶建华. All rights reserved.
//

#import "WKMessageHanderViewController.h"
#import <WebKit/WebKit.h>
#import <JXTAlertView.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface WKMessageHanderViewController ()<WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *imagePickerController;

}
@property (weak, nonatomic) IBOutlet WKWebView *webView;
//@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WKMessageHanderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor orangeColor];

    // 2.加载网页
       NSString *indexPath = [[NSBundle mainBundle] pathForResource:@"WKWebView-WKScriptMessageHandler" ofType:@"html"];
       NSString *appHtml = [NSString stringWithContentsOfFile:indexPath encoding:NSUTF8StringEncoding error:nil];
       NSURL *baseUrl = [NSURL fileURLWithPath:indexPath];
       
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:userScript];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.autoresizesSubviews = YES;
       _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
       _webView.allowsBackForwardNavigationGestures = YES;
    _webView.configuration.userContentController = userContentController;
    
       [self.webView loadHTMLString:appHtml baseURL:baseUrl];
       

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"jsToOc"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"Share"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"Camera"];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"jsToOc"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"Share"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"Camera"];
}



- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name caseInsensitiveCompare:@"jsToOc"] == NSOrderedSame) {
        [JXTAlertView showToastViewWithTitle:message.name message:message.body duration:2 dismissCompletion:nil];
    }
    
    if ([message.name isEqualToString:@"Share"]) {
        [self ShareWithInformation:message.body];
        
    } else if ([message.name isEqualToString:@"Camera"]) {
        
        [self camera];
    }
}

#pragma mark - Method
- (void)ShareWithInformation:(NSDictionary *)dic
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *title = [dic objectForKey:@"title"];
    NSString *content = [dic objectForKey:@"content"];
    NSString *url = [dic objectForKey:@"url"];
    
    //在这里写分享操作的代码
    NSLog(@"要分享了哦😯");
    
    //OC反馈给JS分享结果
    NSString *JSResult = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    
    //OC调用JS
    [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}


- (void)camera
{
    //在这里写调用打开相册的代码
    [self selectImageFromPhotosAlbum];

}

#pragma mark 打开相册
- (void)selectImageFromPhotosAlbum
{
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [imagePickerController setAllowsEditing:YES];
    [imagePickerController setDelegate:self];
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


/******************************************调用系统打开相册相关代理********************************************/
#pragma mark UIImagePickerControllerDelegate
//该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    NSLog(@"选择图片完毕----image:%@-----info:%@",image,editingInfo);
}

//适用获取所有媒体资源，只需判断资源类型
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        
        UIImage *myImage = nil;
        myImage = info[UIImagePickerControllerEditedImage];
        
        //保存图片至相册
        UIImageWriteToSavedPhotosAlbum(myImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
    
    NSLog(@"save success!");
    
    //OC反馈给JS相册结果,将结果返回JS

    NSString *JSResult = [NSString stringWithFormat:@"cameraResult('%@')",@"保存相册照片成功"];
    
    [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

#pragma mark - WKNavigationDelegate

//! WKWebView在每次加载请求完成后会调用此方法
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError *error) {
        self.title = title;
    }];
}



- (IBAction)clickOne:(id)sender {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *jsString = [NSString stringWithFormat:@"ocToJsHaha('hello', 'oc_tokenString')"];

        [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSLog(@"error: %@", error.description);
            NSLog(@"response: %@", response);
        }];
        
        
    });
    
}
- (IBAction)clickTwo:(id)sender {
}
- (IBAction)clickThree:(id)sender {
}
- (IBAction)clickFour:(id)sender {
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


#pragma mark - Dealloc

- (void)dealloc {
    
    NSLog(@"%s", __func__);
}


@end
