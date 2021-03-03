//
//  UVRSSFeed.h
//  rss-reader
//
//  Created by Uladzislau on 11/18/20.
//

#import <Foundation/Foundation.h>
#import "UVFeedChannelDisplayModel.h"
#import "UVFeedChannelKeys.h"
#import "UVRSSFeedItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface UVRSSFeed : NSObject <UVFeedChannelDisplayModel>

@property (nonatomic, copy, readonly) NSString *link;
@property (nonatomic, copy, readonly) NSString *summary;
@property (nonatomic, strong, readonly) NSArray<UVRSSFeedItem *> *items;

+ (instancetype _Nullable)objectWithDictionary:(NSDictionary *)dictionary;
- (void)changeStateOf:(UVRSSFeedItem *)item state:(UVRSSItemOptionState)state;

@end

NS_ASSUME_NONNULL_END
