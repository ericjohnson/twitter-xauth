
#import <Foundation/Foundation.h>

@interface NSString (URLEncode)
- (NSString *) urlEncode;
@end

@class TwitterXAuth;

@protocol TwitterXAuthDelegate <NSObject>
@optional
- (void) twitterXAuthAuthorizationDidFail:(TwitterXAuth *)twitterXAuth;
- (void) twitterXAuthDidAuthorize:(TwitterXAuth *)twitterXAuth;
- (void) twitterXAuthTweetDidFail:(TwitterXAuth *)twitterXAuth;
- (void) twitterXAuthDidTweet:(TwitterXAuth *)twitterXAuth;
@end

typedef enum {
  TwitterXAuthStateDefault,
  TwitterXAuthStateAuthorize,
  TwitterXAuthStateTweet,
} TwitterXAuthState;

@interface TwitterXAuth : NSObject
{
  NSString * nonce;
  NSString * timestamp;
  NSString * consumerKey;
  NSString * password;
  NSString * username;
  NSString * consumerSecret;
  NSString * token;
  NSString * tokenSecret;
  NSMutableData * data;
  TwitterXAuthState state;
  id<TwitterXAuthDelegate> delegate;
  NSString * tweet;
  NSString * twitterURL;
}
@property (nonatomic,copy) NSString * consumerKey;
@property (nonatomic,copy) NSString * password;
@property (nonatomic,copy) NSString * username;
@property (nonatomic,copy) NSString * consumerSecret;
@property (nonatomic,copy) NSString * token; //oauth_token
@property (nonatomic,copy) NSString * tokenSecret; //oauth_token_secret
@property (nonatomic,assign) id<TwitterXAuthDelegate> delegate;
- (void) authorize;
- (void) tweet:(NSString *)status;
@end
