#import "JGXPCInterface.h"
#import "MyProtocol.h"

@implementation JGXPCInterface

+(NSXPCInterface *)interface {
  return [NSXPCInterface interfaceWithProtocol:@protocol(MyProtocol)];
}

@end
