
#import <Foundation/Foundation.h>
#import "TwitterXAuth.h"

//update these:
#define CONSUMER_KEY @""
#define CONSUMER_SECRET @""
#define TWITTER_USERNAME @""
#define TWITTER_PASSWORD @""

@interface TestTwitterXAuth : NSObject <TwitterXAuthDelegate>
+ (void) testTwitterXAuth;
+ (void) twitterXAuthDidAuthorize:(TwitterXAuth *)twitterXAuth;
+ (void) twitterXAuthDidTweet:(TwitterXAuth *)twitterXAuth;
@end

@implementation TestTwitterXAuth

static TwitterXAuth * twitterXAuth = nil;

+ (void) testTwitterXAuth
{
  [twitterXAuth release];
  twitterXAuth = [[TwitterXAuth alloc] init];

  twitterXAuth.consumerKey = CONSUMER_KEY;
  twitterXAuth.consumerSecret = CONSUMER_SECRET;
  twitterXAuth.username = TWITTER_USERNAME;
  twitterXAuth.password = TWITTER_PASSWORD;
  twitterXAuth.delegate = self;
  
  [twitterXAuth authorize];
}

+ (void) twitterXAuthDidAuthorize:(TwitterXAuth *)twitterXAuth
{
  NSLog(@"authorization successful");
  NSLog(@"sending tweet");
  [twitterXAuth tweet:@"test tweet"];
}

+ (void) twitterXAuthDidTweet:(TwitterXAuth *)twitterXAuth;
{
  NSLog(@"successfully tweeted");
  exit(0);
}

@end


int main(int argc, char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  [TestTwitterXAuth testTwitterXAuth];
  
  [[NSRunLoop currentRunLoop] run];
  
  [pool release];
  return 0;
}
