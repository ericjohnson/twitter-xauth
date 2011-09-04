twitter-xauth
============

This is an extremely simple twitter client for Mac OS X and iOS, which
uses xauth for authentication. The only other feature provided are
status updates. I created this project because I wanted something
small and simple, and need only to be able to do status updates on
twitter. I'm posting it in hopes that it might be of use to someone
else.

See twitter-xauth.m for example usage. Fill in values for
CONSUMER_KEY, CONSUMER_SECRET, TWITTER_USERNAME, and
TWITTER_PASSWORD. Compiles on Mac OS X using gnu make.


Usage
=====

# Initialize TwitterXAuth

```objective-c
TwitterXAuth *twitter = [[TwitterXAuth alloc] initWithConsumerKey:@"your key" secret:@"your secret" andDelegate:self];
```
Make sure you implement the delegate methods you need:

```objective-c
# pragma mark - TwitterXAuth

- (void) twitterXAuthAuthorizationDidFail:(TwitterXAuth *)twitterXAuth
{
    NSLog(@"auth failed");
}

- (void) twitterXAuthDidAuthorize:(TwitterXAuth *)twitterXAuth
{
    NSLog(@"auth succeeded");
}
```
# Authenticate user

```objective-c
[twitter authorizeWithUsername:loginObject.userName andPassword:loginObject.password];
```

# Tweet on the user's behalf

```objective-c
[twitter tweet:@"Hi from Twitter-XAuth"];
```
Make sure you implement the tweet delegate methods if you need:

```objective-c
- (void) twitterXAuthTweetDidFail:(TwitterXAuth *)twitterXAuth
{
    NSLog(@"tweet failed";
}

- (void) twitterXAuthDidTweet:(TwitterXAuth *)twitterXAuth
{
    NSLog(@"tweet succeeded");
}
```

See more documentation about XAuth using the links below:

http://weblog.bluedonkey.org/?p=959
http://cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html
http://www.getsharekit.com/
http://www.gigliwood.com/weblog/Cocoa/Q__When_is_an_conne.html
http://dev.twitter.com/pages/xauth
http://dev.twitter.com/doc/post/oauth/access_token
http://dev.twitter.com/pages/auth#auth-request

Special thanks to Matt Gallagher of cocoawithlove.com for providing an
Objective-C implementation of Base64 encoding for Mac and iPhone.
