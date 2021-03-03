//
//  UVRSSFeed.m
//  rss-reader
//
//  Created by Uladzislau on 11/18/20.
//

#import "UVRSSFeed.h"
#import "NSArray+Util.h"

@interface UVRSSFeed ()

@property (nonatomic, copy, readwrite) NSString *link;
@property (nonatomic, copy, readwrite) NSString *summary;
@property (nonatomic, strong, readwrite) NSArray<UVRSSFeedItem *> *items;

@end

@implementation UVRSSFeed

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    if(!dictionary || !dictionary.count) {
        NSLog(@"Unwanted behavior:\n%s\nargument:\n%@", __PRETTY_FUNCTION__, dictionary);
        return nil;
    }
    
    UVRSSFeed *object = [UVRSSFeed new];
    
    object.link = dictionary[kRSSChannelLink];
    object.summary = dictionary[kRSSChannelDescription];
    object.items = [dictionary[kRSSChannelItems] map:^UVRSSFeedItem *(NSDictionary *rawItem) {
        return [UVRSSFeedItem objectWithDictionary:rawItem];
    }];
    
    return [object autorelease];
}

- (void)dealloc
{
    [_link release];
    [_items release];
    [_summary release];
    [super dealloc];
}

- (BOOL)isEqual:(id)other
{
    return [self.link isEqualToString:[other link]];
}

// MARK: - Interface

- (void)changeStateOf:(UVRSSFeedItem *)item state:(UVRSSItemOptionState)state {
    [[self.items find:^BOOL(UVRSSFeed *obj) {
        return [item isEqual:obj];
    }] setReadingState:state];
}

@end
