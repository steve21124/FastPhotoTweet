//
//  NSArray+AppendUtil.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/02.
//

#import "NSArray+AppendUtil.h"
#import "TWTweet.h"

@implementation NSArray (NSArrayAppendUtil)

- (id)appendToTop:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( unitArray == nil ||
        [unitArray count] == 0 ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( [(NSArray *)unitArray isEmpty] ) return self;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        
        NSInteger i = 0;
        for ( id item in unitArray ) {
            
            [tempArray insertObject:item
                             atIndex:i];
            i++;
        }
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendToBottom:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( unitArray == nil ||
        [unitArray count] == 0 ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( [(NSArray *)unitArray isEmpty] ) return self;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        
        for ( id item in unitArray ) {
            
            [tempArray addObject:item];
        }
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToTop:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( unitArray == nil ||
        [unitArray count] == 0 ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( [(NSArray *)unitArray isEmpty] ) return self;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        
        NSInteger i = 0;
        for ( id item in unitArray ) {
            
            BOOL notHave = YES;
            for ( id myItem in self ) {
                
                if ( [myItem isEqual:item] ) {
                    
                    notHave = NO;
                    break;
                }
            }
            
            if ( notHave ) {
                
                [tempArray insertObject:item atIndex:i];
                i++;
            }
        }
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToBottom:(id)unitArray returnMutable:(BOOL)returnMutable {
    
    if ( unitArray == nil ||
        [unitArray count] == 0 ) return self;
    
    if ( [NSArray checkClass:unitArray] ) {
        
        if ( [(NSArray *)unitArray isEmpty] ) return self;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];

        for ( id item in unitArray ) {
            
            BOOL notHave = YES;
            for ( id myItem in self ) {
                
                if ( [myItem isEqual:item] ) {
                    
                    notHave = NO;
                    break;
                }
            }
            
            if ( notHave ) [tempArray addObject:item];
        }

        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToTop:(id)dictionariesArray forXPath:(NSString *)xpath separator:(NSString *)separator returnMutable:(BOOL)returnMutable {
    
    if ( dictionariesArray == nil ||
        [dictionariesArray count] == 0 ) return self;
    
    if ( [NSArray checkClass:dictionariesArray] ) {
        
        if ( [(NSArray *)dictionariesArray isEmpty] ) return self;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        
        BOOL isOnlyDictionary = YES;
        for ( id item in dictionariesArray ) {
            
            if ( ![item isKindOfClass:[NSDictionary class]] ) {
                
                isOnlyDictionary = NO;
                break;
            }
        }
        
        for ( id item in self ) {
            
            if ( ![item isKindOfClass:[NSDictionary class]] ) {
                
                isOnlyDictionary = NO;
                break;
            }
        }
        
        if ( isOnlyDictionary ) {
            
            int i = 0;
            for ( NSDictionary *item in dictionariesArray ) {
                
                BOOL notHave = YES;
                for ( NSDictionary *myItem in self ) {
                    
                    id targetMyItem = [myItem objectForXPath:xpath separator:separator];
                    id targetItem = [item objectForXPath:xpath separator:separator];
                    
                    if ( [targetMyItem isNotEmpty] &&
                         [targetItem isNotEmpty] ) {
                        
                        if ( [targetMyItem isEqual:targetItem] ) {
                            
                            notHave = NO;
                            break;
                        }
                    }
                }
                
                if ( notHave ) {
                    
                    [tempArray insertObject:item atIndex:i];
                    i++;
                }
            }
        }
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

- (id)appendOnlyNewToTop:(id)dictionariesArray forXPath:(NSString *)xpath returnMutable:(BOOL)returnMutable {
    
    return [self appendOnlyNewToTop:dictionariesArray
                           forXPath:xpath
                          separator:@"/"
                      returnMutable:returnMutable];
}

- (id)appendOnlyNewTweetToTop:(id)tweetDictionariesArray returnMutable:(BOOL)returnMutable {
    
    if ( tweetDictionariesArray == nil ||
        [tweetDictionariesArray count] == 0 ) return self;
    
    if ( [NSArray checkClass:tweetDictionariesArray] ) {
        
        if ( [(NSArray *)tweetDictionariesArray isEmpty] ) return self;
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self];
        
        NSInteger i = 0;
        for ( TWTweet *tweet in tweetDictionariesArray ) {
            
            BOOL notHave = YES;
            for ( TWTweet *myTweew in self ) {
                
                NSString *myTweetID = myTweew.tweetID;
                NSString *tweetID = tweet.tweetID;
                
                if ( [myTweetID isNotEmpty] &&
                     [tweetID isNotEmpty] ) {
                    
                    if ( [myTweetID isEqualToString:tweetID] ) {
                        
                        notHave = NO;
                        break;
                    }
                }
            }
            
            if ( notHave ) {
                
                [tempArray insertObject:tweet atIndex:i];
                i++;
            }
        }
        
        return returnMutable ? tempArray : [NSArray arrayWithArray:tempArray];
    }
    
    return self;
}

+ (BOOL)checkClass:(id)object {
    
    if ( [object isKindOfClass:[NSArray class]] ) {
        
        return YES;
    }
    
    return NO;
}

@end
