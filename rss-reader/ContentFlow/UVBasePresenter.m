//
//  ErrorPresenter.m
//  rss-reader
//
//  Created by Uladzislau Volchyk on 16.12.20.
//

#import "UVBasePresenter.h"
#import "UVNetwork.h"

NSInteger const RSSReaderErrorCodeKey = 10000;
NSString *const RSSReaderDomainKey =    @"com.rss-reader.uvolchyk";

@interface UVBasePresenter ()

@property (nonatomic, retain, readwrite) id<UVDataRecognizerType> dataRecognizer;
@property (nonatomic, retain, readwrite) id<UVSourceManagerType> sourceManager;
@property (nonatomic, retain, readwrite) id<UVNetworkManagerType> network;

@end

@implementation UVBasePresenter

- (instancetype)initWithRecognizer:(id<UVDataRecognizerType>)recognizer
                     sourceManager:(id<UVSourceManagerType>)manager
                           network:(id<UVNetworkManagerType>)network
{
    self = [super init];
    if (self) {
        _dataRecognizer = [recognizer retain];
        _sourceManager = [manager retain];
        _network = [network retain];
    }
    return self;
}

- (void)dealloc
{
    [_dataRecognizer release];
    [_sourceManager release];
    [_network release];
    [super dealloc];
}

// MARK: -

- (NSError *)provideErrorOfType:(RSSError)type {
    switch (type) {
        case RSSErrorTypeBadNetwork: {
            return [NSError errorWithDomain:RSSReaderDomainKey code:RSSReaderErrorCodeKey userInfo:@{
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(BAD_INTERNET_CONNECTION_TITLE, ""),
                NSLocalizedDescriptionKey: NSLocalizedString(BAD_INTERNET_CONNECTION_DESCRIPTION, "")
            }];
        }
        case RSSErrorTypeParsingError: {
            return [NSError errorWithDomain:RSSReaderDomainKey code:RSSReaderErrorCodeKey userInfo:@{
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(BAD_RSS_FEED_TITLE, ""),
                NSLocalizedDescriptionKey: NSLocalizedString(BAD_RSS_FEED_DESCRIPTION, "")
            }];
        }
        case RSSErrorTypeBadURL: {
            return [NSError errorWithDomain:RSSReaderDomainKey code:RSSReaderErrorCodeKey userInfo:@{
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(BAD_URL_TITLE, ""),
                NSLocalizedDescriptionKey: NSLocalizedString(BAD_URL_DESCRIPTION, "")
            }];
        }
        case RSSErrorNoRSSLinks: {
            return [NSError errorWithDomain:RSSReaderDomainKey code:RSSReaderErrorCodeKey userInfo:@{
                NSLocalizedFailureReasonErrorKey: NSLocalizedString(NO_RSS_LINKS_TITLE, ""),
                NSLocalizedDescriptionKey: NSLocalizedString(NO_RSS_LINKS_DESCRIPTION, "")
            }];
        }
        case RSSErrorTypeNone:
            return nil;
    }
}

@end