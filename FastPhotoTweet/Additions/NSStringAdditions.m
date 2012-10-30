//
//  NSStringAdditions.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/09.
//

#import "NSStringAdditions.h"

@implementation NSString (NSStringLinkLabelUtil)

- (NSString *)linkWrappingAll {
    
    @try {
        
        if ( self == nil ||
             self.length == 0 ||
            [self isEqualToString:@""] ) return self;
        
        NSError *error = nil;
        NSMutableArray *links = [NSMutableArray array];
        
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                       error:&error];
        NSArray *matches = [linkDetector matchesInString:self
                                                 options:0
                                                   range:NSMakeRange(0, self.length)];
        
        if ( error ) return self;
        
        for ( NSTextCheckingResult *match in matches ) {
            
            [links addObject:match.URL.absoluteString];
        }
        
        if ( links.count == 0 ) return self;
        
        NSMutableString *linkedText = [NSMutableString stringWithString:self];
        
        for ( NSString *link in links ) {
            
            NSString *wrappingLink = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", link, link];
            [linkedText replaceOccurrencesOfString:link
                                        withString:wrappingLink
                                           options:0
                                             range:NSMakeRange(0, linkedText.length)];
        }
        
        return [NSString stringWithString:linkedText];
        
    }@catch ( NSException *e ) {
        
        return self;
    }
}

- (NSString *)timelineMainText {
    
    return [NSString stringWithFormat:@"<html><body><span class=\"fontSize12\">%@</span></body></html>", self];
}

@end