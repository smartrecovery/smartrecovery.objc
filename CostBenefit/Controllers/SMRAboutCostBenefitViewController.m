//
//  SMRStaticViewController.m
//  CostBenefit
//
//  Created by Aaron Schachter on 4/20/15.
//  Copyright (c) 2015 smartrecovery.org. All rights reserved.
//

#import "SMRAboutCostBenefitViewController.h"
#import <MMMarkdown/MMMarkdown.h>

@interface SMRAboutCostBenefitViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SMRAboutCostBenefitViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView.backgroundColor = UIColor.whiteColor;

    self.title = @"Cost Benefit Analysis";

    NSError  *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cba" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:content error:&error];
    UIFont *systemFont = [UIFont systemFontOfSize:14];
    NSString *aboutHTML = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {font-family: \"%@\";}</style></head><body>%@</body></html>", systemFont.familyName, htmlString];
    [self.webView loadHTMLString:aboutHTML baseURL:[[NSBundle mainBundle] bundleURL]];
}

@end
