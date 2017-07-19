
#import "HTTPConnection.h"

@class MultipartFormDataParser;

@interface MyHTTPConnection : HTTPConnection  {
    MultipartFormDataParser*        parser;
	NSFileHandle*					storeFile;
	
	NSMutableArray*					uploadedFiles;
}


@property (nonatomic) UInt64 contentLength;
@property (nonatomic) UInt64 transferLength;
@property (nonatomic) NSUInteger length;

@end
