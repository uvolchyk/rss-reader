//
//  AppDelegate.m
//  rss-reader
//
//  Created by Uladzislau on 11/17/20.
//

#import "AppDelegate.h"
#import "FeedXMLParser.h"
#import "FeedProvider.h"
#import "FeedPresenter.h"
#import "FeedViewController.h"
#import "ErrorManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupAppearance];
    return YES;
}

// MARK: -

- (void)setupAppearance {
    FeedXMLParser *parser = [FeedXMLParser new];
    FeedProvider *dataProvider = [[FeedProvider alloc] initWithParser:[parser autorelease]];
    FeedPresenter *presenter = [[FeedPresenter alloc] initWithProvider:[dataProvider autorelease] errorManager:[[ErrorManager new] autorelease]];
    FeedViewController *controller = [[FeedViewController alloc] initWithPresenter:[presenter autorelease]];
    
    self.window.rootViewController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [self.window makeKeyAndVisible];
    
    [controller release];
}

// MARK: Lazy

- (UIWindow *)window {
    if(!_window) {
        _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    return _window;
}

// MARK: -

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
