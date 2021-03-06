//
// XMLReader.h
//
#import <Foundation/Foundation.h>

@interface XMLReader : NSObject
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError *__autoreleasing *errorPointer;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end