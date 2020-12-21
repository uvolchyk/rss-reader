//
//  UVSite.h
//  rss-reader
//
//  Created by Uladzislau Volchyk on 14.12.20.
//

#import <Foundation/Foundation.h>
#import "RSSSourceViewModel.h"
#import "RSSLink.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSSSource : NSObject <RSSSourceViewModel, NSSecureCoding, NSCopying>

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, retain, readonly) NSURL *url;
@property (nonatomic, retain, readonly) NSArray<RSSLink *> *rssLinks;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryFromObject;
- (instancetype)initWithTitle:(NSString *)title
                          url:(NSURL *)url
                        links:(NSArray<RSSLink *> *)links
                     selected:(BOOL)selected;
- (NSArray<RSSLink *> *)selectedLinks;
- (void)switchAllLinksSelected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
