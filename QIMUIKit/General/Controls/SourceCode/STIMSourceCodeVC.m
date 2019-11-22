//
//  STIMSourceCodeVC.m
//  qunarChatIphone
//
//  Created by admin on 15/7/23.
//
//

#import "STIMSourceCodeVC.h"
#import "NSBundle+STIMLibrary.h"

@interface STIMSourceCodeVC ()

@end

@implementation STIMSourceCodeVC{
    UIWebView *_webView;
}

- (void)dealloc{
    [self setSourceCodeDic:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setTitle:@"代码段"];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_webView setScalesPageToFit:YES];
    [_webView setMultipleTouchEnabled:YES];
    [self.view addSubview:_webView];
    
    NSString *htmlPath = [NSBundle stimDB_myLibraryResourcePathWithClassName:@"STIMSourceCode" BundleName:@"STIMSourceCode" pathForResource:@"applicationCode" ofType:@"html"];
    NSString *cssFile = [NSBundle stimDB_myLibraryResourcePathWithClassName:@"STIMSourceCode" BundleName:@"STIMSourceCode" pathForResource:@"application" ofType:@"css"];
    NSString *jsFile = [NSBundle stimDB_myLibraryResourcePathWithClassName:@"STIMSourceCode" BundleName:@"STIMSourceCode" pathForResource:@"application" ofType:@"js"];

    NSString *htmlContent =  [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:htmlPath] encoding:NSUTF8StringEncoding];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"[CSSFILE]" withString:[NSString stringWithFormat:@"file://%@",cssFile]];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"[JSFILE]" withString:[NSString stringWithFormat:@"file://%@",jsFile]];
    NSString *code = [self.sourceCodeDic objectForKey:@"Code"];
    NSString *codeType = [self.sourceCodeDic objectForKey:@"CodeType"];
    NSString *codeStyle = [self.sourceCodeDic objectForKey:@"CodeStyle"];
    NSString *html = [htmlContent stringByReplacingOccurrencesOfString:@"[CODETEXT]" withString:[code stimDB_stringByEscapingXMLEntities]];
    html = [html stringByReplacingOccurrencesOfString:@"[CODETYPE]" withString:codeType];
    if (codeStyle.length <= 0) {
        codeStyle = @"white";
    }
    html = [html stringByReplacingOccurrencesOfString:@"[CODESTYLE]" withString:codeStyle];
    NSArray *array = [code componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                                characterSetWithCharactersInString:@"\n\r"]];
    NSMutableString *lines = [NSMutableString string];
    for (int i = 1; i<=array.count; i++) {
        [lines appendFormat:@"<a href=\"#L%d\" id=\"L%d\" rel=\"#L%d\"><i class=\"icon-link\"></i>%d</a>",i,i,i,i];
    }
    html = [html stringByReplacingOccurrencesOfString:@"[CODELINENUMBER]" withString:lines];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    UIInterfaceOrientation orientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
        {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            orientation = UIInterfaceOrientationLandscapeLeft;
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
            break;
        default:
        {
            orientation = UIInterfaceOrientationPortrait;
        }
            break;
    }
    return orientation;
}

@end
