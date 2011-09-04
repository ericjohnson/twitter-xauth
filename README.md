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


Requisites
==========

Your Twitter app must have XAuth enabled.  To do so, follow the instructions on this page:
https://dev.twitter.com/docs/oauth/xauth

Installation
===========

You'll need to copy the following files into your project:
* TwitterXAuth.h
* TwitterXAuth.m
* NSData+Base64.h (assuming you're not already using this)
* NSData+Base64.m (assuming you're not already using this)

Then make sure you import in whatever controllers you need:

```objective-c
#import "TwitterXAuth.h"
```
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
# Single Sign On
Should you need to log a user in to your backend with Twitter, you'll need to grab the user's token and tokenSecret from the TwitterXAuth object.  The easiest way to do this is to implement the twitterXAuthDidRetrieveToken:andSecret method:

```objective-c
- (void) twitterXAuthDidRetrieveToken:(NSString *)token andTokenSecret:(NSString *)secret
{
  // Do something useful with the token and secret
}
```
It's important to note that you probably want to choose to implement either twitterXAuthDidAuthorize OR twitterXAuthDidRetrieveToken:andSecret because they both will be called upon authorization if they are implemented.

More
====

See more documentation about XAuth using the links below:

* http://weblog.bluedonkey.org/?p=959
* http://cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html
* http://www.getsharekit.com/
* http://www.gigliwood.com/weblog/Cocoa/Q__When_is_an_conne.html
* http://dev.twitter.com/pages/xauth
* http://dev.twitter.com/doc/post/oauth/access_token
* http://dev.twitter.com/pages/auth#auth-request

Special thanks to Matt Gallagher of cocoawithlove.com for providing an
Objective-C implementation of Base64 encoding for Mac and iPhone.
