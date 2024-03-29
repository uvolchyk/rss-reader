//
//  NSString+StringExtractor.h
//  rss-reader
//
//  Created by Uladzislau Volchyk on 12/1/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Util)

- (NSString *)stringBetweenStart:(NSString *)start andFinish:(NSString *)finish;
- (NSString *)substringFromString:(NSString *)string;
- (NSString *)stringByStrippingHTML;
+ (NSString *)htmlStringFromData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
