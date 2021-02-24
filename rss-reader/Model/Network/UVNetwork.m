//
//  UVNetwork.m
//  rss-reader
//
//  Created by Uladzislau Volchyk on 1.01.21.
//

#import "UVNetwork.h"
#import "UVErrorDomain.h"
#import "Reachability.h"

static NSString *const SECURE_SCHEME = @"https";
static NSString *const STUB_RELATIVE_PATH = @"";

@interface UVNetwork ()

@property (nonatomic, strong) id<ReachabilityType> reachability;

@property (nonatomic, strong) NSMutableDictionary<id, void(^)(void)> *observers;

@end

@implementation UVNetwork

// MARK: -

- (void)fetchDataFromURL:(NSURL *)url
              completion:(void (^)(NSData *, NSError *))completion {
    [NSThread detachNewThreadWithBlock:^{
        @autoreleasepool {
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
            completion(data, error);
        }
    }];
}

- (NSURL *)validateAddress:(NSString *)address error:(out NSError **)error {
    if (!address || !address.length) {
        [self provideErrorForReference:error];
        return nil;
    }
    NSURL *newURL = [NSURL URLWithString:STUB_RELATIVE_PATH
                           relativeToURL:[NSURL URLWithString:address]].absoluteURL;
    
    if (!newURL.host) {
        [self provideErrorForReference:error];
        return nil;
    }
    
    return [self enhanceSchemeOfURL:newURL error:error];
}

- (NSURL *)validateURL:(NSURL *)url error:(out NSError **)error {
    if(!url || !url.absoluteString.length) {
        [self provideErrorForReference:error];
        return nil;
    }
    NSURL *newURL = [NSURL URLWithString:STUB_RELATIVE_PATH
                           relativeToURL:url].absoluteURL;
    return [self enhanceSchemeOfURL:newURL error:error];
}

- (BOOL)isConnectionAvailable {
    return
    self.reachability.currentReachabilityStatus == ReachableViaWWAN ||
    self.reachability.currentReachabilityStatus == ReachableViaWiFi;
}

// MARK: - Posting

// TODO: -
- (void)registerObserver:(id)observer callback:(void (^)(void))callback {
    self.observers[observer] = callback;
}

- (void)unregisterObserver:(id)observer {
    self.observers[observer] = nil;
}

// MARK: - Private

- (NSError *)urlError {
    return [NSError errorWithDomain:UVNetworkErrorDomain code:100000 userInfo:nil];
}

- (BOOL)provideErrorForReference:(out NSError **)error {
    if (error) {
        *error = [self urlError];
    }
    return YES;
}

- (NSURL *)enhanceSchemeOfURL:(NSURL *)url error:(out NSError **)error {
    if (!url) {
        [self provideErrorForReference:error];
        return nil;
    }
    if (!url.scheme) {
        NSURLComponents *comps = [NSURLComponents componentsWithURL:url
                                            resolvingAgainstBaseURL:YES];
        comps.scheme = SECURE_SCHEME;
        url = comps.URL;
    }
    return url;
}

- (id<ReachabilityType>)reachability {
    if (!_reachability) {
        _reachability = Reachability.reachabilityForInternetConnection;
        if ([_reachability startNotifier]) {
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(dothings) name:kReachabilityChangedNotification object:nil];
        }
        
    }
    return _reachability;
}

- (NSMutableDictionary<id,void (^)(void)> *)observers {
    if (!_observers) {
        _observers = [NSMutableDictionary new];
    }
    return _observers;
}

- (void)dothings {
    NSLog(@"%@", @"changed!!!");
}

@end
