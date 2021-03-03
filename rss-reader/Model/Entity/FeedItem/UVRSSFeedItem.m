//
//  UVRSSFeedItem.m
//  rss-reader
//
//  Created by Uladzislau on 11/17/20.
//

#import "UVRSSFeedItem.h"
#import "NSDate+StringConvertible.h"
#import "NSString+Util.h"

static NSString *const kDatePresentationFormat  = @"dd.MM.yyyy HH:mm";
static NSString *const kDateRawFormat           = @"EE, d LLLL yyyy HH:mm:ss Z";

@interface UVRSSFeedItem ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, copy, readwrite) NSString *summary;
@property (nonatomic, copy, readwrite) NSString *category;
@property (nonatomic, strong, readwrite) NSDate *pubDate;

@end

@implementation UVRSSFeedItem

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    if(!dictionary || !dictionary.count) {
        NSLog(@"Unwanted behavior:\n%s\nargument:\n%@", __PRETTY_FUNCTION__, dictionary);
        return nil;
    }
    
    UVRSSFeedItem *object = [[UVRSSFeedItem alloc] init];
    
    object.title = dictionary[kRSSItemTitle];
    object.url = [NSURL URLWithString:dictionary[kRSSItemLink]];
    object.summary = dictionary[kRSSItemSummary];
    object.category = dictionary[kRSSItemCategory];
    object.pubDate = [NSDate dateFromString:dictionary[kRSSItemPubDate] withFormat:kDateRawFormat];
    object.expand = NO;
    object.readingState = UVRSSItemNotStartedOpt;
    return object;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ --- %u, %p", self.url, self.readingState, &self];
}

- (BOOL)isEqual:(id)other
{
    return [self.url isEqual:[other url]];
}

// MARK: - UVFeedItemDisplayModel

- (NSString *)articleDate {
    return [self.pubDate stringWithFormat:kDatePresentationFormat];
}

@end
