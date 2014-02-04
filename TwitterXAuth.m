// TwitterXAuth.m
//
// Created by Eric Johnson on 08/27/2010.
// Copyright 2010 Eric Johnson. All rights reserved.
//
// Permission is given to use this source code file, free of charge, in any
// project, commercial or otherwise, entirely at your risk, with the condition
// that any redistribution (in part or whole) of source code must retain
// this copyright and permission notice. Attribution in compiled projects is
// appreciated but not required.

#import "TwitterXAuth.h"

#include <CommonCrypto/CommonHMAC.h>
#import "NSData+Base64.h"

// this code possible thanks to:
// http://weblog.bluedonkey.org/?p=959
// http://cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html
// http://www.getsharekit.com/
// http://www.gigliwood.com/weblog/Cocoa/Q__When_is_an_conne.html
// http://dev.twitter.com/pages/xauth
// http://dev.twitter.com/doc/post/oauth/access_token
// http://dev.twitter.com/pages/auth#auth-request

@implementation NSString (URLEncode)
- (NSString *) urlEncode
{
  NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
										 (CFStringRef)self,
										 NULL,
										 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
										 kCFStringEncodingUTF8);
  return [encodedString autorelease];
}
@end

@interface TwitterXAuth ()
- (void) resetNonce;
- (void) resetTimestamp;
- (NSString *) nonce;
- (NSString *) timestamp;
- (NSString *) baseString;
- (NSString *) signature;
- (NSString *) authorizationHeader;
@end

@implementation TwitterXAuth

@synthesize consumerKey, password, username, consumerSecret, token, tokenSecret;
@synthesize delegate;

- (id) init
{
  if ((self = [super init])) {
    state = TwitterXAuthStateDefault;
    data = [[NSMutableData alloc] init];
    self.tokenSecret = @"";
  }
  return self;
}

- (void) dealloc
{
  [data release];
  [tweet release];
  [super dealloc];
}

- (void) resetNonce
{
  [nonce release];
  nonce = nil;
}

- (void) resetTimestamp
{
  [timestamp release];
  timestamp = nil;
}

- (NSString *) nonce
{
  if (nonce == nil)
    nonce = [[NSString stringWithFormat:@"%d", arc4random()] retain];
  return nonce;
}

- (NSString *) timestamp
{
  if (timestamp == nil)
    timestamp = [[NSString stringWithFormat:@"%d", (int)(((float)([[NSDate date] timeIntervalSince1970])) + 0.5)] retain];
  return timestamp;
}

- (NSString *) baseString
{
  //method&url&parameters
  NSString * method = @"POST";
  NSString * url = nil;
  url = [twitterURL urlEncode];

  NSString * parameters;

  NSString * oauth_consumer_key = [self.consumerKey urlEncode];
  NSString * oauth_nonce = [self.nonce urlEncode];
  NSString * oauth_signature_method = [[NSString stringWithString:@"HMAC-SHA1"] urlEncode];
  NSString * oauth_timestamp = [self.timestamp urlEncode];
  NSString * oauth_version = [[NSString stringWithString:@"1.0"] urlEncode];
  NSString * x_auth_mode = [[NSString stringWithString:@"client_auth"] urlEncode];
  NSString * x_auth_password = [self.password urlEncode];
  NSString * x_auth_username = [self.username urlEncode];

  NSArray * params = [NSArray arrayWithObjects:
			      [NSString stringWithFormat:@"%@%%3D%@", @"oauth_consumer_key", oauth_consumer_key],
			      [NSString stringWithFormat:@"%@%%3D%@", @"oauth_nonce", oauth_nonce],
			      [NSString stringWithFormat:@"%@%%3D%@", @"oauth_signature_method", oauth_signature_method],
			      [NSString stringWithFormat:@"%@%%3D%@", @"oauth_timestamp", oauth_timestamp],
			      [NSString stringWithFormat:@"%@%%3D%@", @"oauth_version", oauth_version],
			      nil];
  if (state == TwitterXAuthStateAuthorize)
    params = [params arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@%%3D%@", @"x_auth_mode", x_auth_mode],
							    [NSString stringWithFormat:@"%@%%3D%@", @"x_auth_password", [x_auth_password urlEncode]],
							    [NSString stringWithFormat:@"%@%%3D%@", @"x_auth_username", [x_auth_username urlEncode]],
							    nil]];
  if (state == TwitterXAuthStateTweet)
    params = [params arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@%%3D%@", @"oauth_token", [self.token urlEncode]],
							    [NSString stringWithFormat:@"%@%%3D%@", @"status", [[tweet urlEncode] urlEncode]],
							    nil]];
  //sort paramaters alphabetically
  params = [params sortedArrayUsingSelector:@selector(compare:)];
  
  parameters = [params componentsJoinedByString:@"%26"];

  NSArray * baseComponents = [NSArray arrayWithObjects:
				      method,
				      url,
				      parameters,
				      nil];
  NSString * baseString = [baseComponents componentsJoinedByString:@"&"];

  return baseString;
}

- (NSString *) signature
{
  NSString * secret = [NSString stringWithFormat:@"%@&%@", self.consumerSecret, self.tokenSecret];

  NSData * secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
  NSData * baseData = [self.baseString dataUsingEncoding:NSUTF8StringEncoding];
  
  //uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
  uint8_t digest[20] = {0};
  CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length,
	 baseData.bytes, baseData.length, digest);
  //NSData * signatureData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
  NSData * signatureData = [NSData dataWithBytes:digest length:20];
  return [signatureData base64EncodedString];
}

- (NSString *) authorizationHeader
{
  NSArray * keysAndValues = [NSArray arrayWithObjects:
				     [NSString stringWithFormat:@"%@=\"%@\"", @"oauth_nonce", [self.nonce urlEncode]],
				     [NSString stringWithFormat:@"%@=\"%@\"", @"oauth_signature_method", [[NSString stringWithString:@"HMAC-SHA1"] urlEncode]],
				     [NSString stringWithFormat:@"%@=\"%@\"", @"oauth_timestamp", [self.timestamp urlEncode]],
				     [NSString stringWithFormat:@"%@=\"%@\"", @"oauth_consumer_key", [self.consumerKey urlEncode]],
				     [NSString stringWithFormat:@"%@=\"%@\"", @"oauth_signature", [self.signature urlEncode]],
				     [NSString stringWithFormat:@"%@=\"%@\"", @"oauth_version", [[NSString stringWithString:@"1.0"] urlEncode]],
				     nil];
  if (state == TwitterXAuthStateTweet && self.token && [self.token length] > 0)
    keysAndValues = [keysAndValues arrayByAddingObject:[NSString stringWithFormat:@"%@=\"%@\"", @"oauth_token", [self.token urlEncode]]];
  return [NSString stringWithFormat:@"OAuth %@", [keysAndValues componentsJoinedByString:@", "]];
}

- (void) authorize
{
  //send POST to https://api.twitter.com/oauth/access_token with parameters: x_auth_username, x_auth_password, x_auth_mode

  [self resetTimestamp];
  [self resetNonce];
  
  state = TwitterXAuthStateAuthorize;

  [twitterURL release];
  twitterURL = [[NSString stringWithString:@"https://api.twitter.com/oauth/access_token"] retain];
  NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:twitterURL]];
  [postRequest setHTTPMethod: @"POST"];
  NSArray * parameterArray = [NSArray arrayWithObjects:
				      [NSString stringWithFormat:@"%@=%@", @"x_auth_mode", @"client_auth"],
				      [NSString stringWithFormat:@"%@=%@", @"x_auth_password", [self.password urlEncode]],
				      [NSString stringWithFormat:@"%@=%@", @"x_auth_username", [self.username urlEncode]],
				      nil];
  [postRequest setHTTPBody:[[parameterArray componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
	
  
  [postRequest addValue:self.authorizationHeader
	       forHTTPHeaderField:@"Authorization"];

  [data setLength:0];
  [NSURLConnection connectionWithRequest:postRequest
		   delegate:self];
}

- (void) tweet:(NSString *)status
{

  [self resetTimestamp];
  [self resetNonce];
  
  state = TwitterXAuthStateTweet;

  [tweet release];
  tweet = [status copy];

  [twitterURL release];
  twitterURL = [[NSString stringWithString:@"http://api.twitter.com/1/statuses/update.json"] retain];
  NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:twitterURL]];
  [postRequest setHTTPMethod: @"POST"];
  NSArray * parameterArray = [NSArray arrayWithObjects:
				      [NSString stringWithFormat:@"%@=%@", @"status", [status urlEncode]],
				      nil];
  [postRequest setHTTPBody:[[parameterArray componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding]];
  [postRequest addValue:self.authorizationHeader
	       forHTTPHeaderField:@"Authorization"];
  [data setLength:0];
  [NSURLConnection connectionWithRequest:postRequest
		   delegate:self];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  if (state == TwitterXAuthStateAuthorize && delegate && [delegate respondsToSelector:@selector(twitterXAuthAuthorizationDidFail:)])
    [delegate twitterXAuthAuthorizationDidFail:self];
  if (state == TwitterXAuthStateTweet && delegate && [delegate respondsToSelector:@selector(twitterXAuthTweetDidFail:)])
    [delegate twitterXAuthTweetDidFail:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData
{
  [data appendData:newData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  if ([response respondsToSelector:@selector(statusCode)]) {
    int statusCode = [((NSHTTPURLResponse *)response) statusCode];
    if (statusCode >= 400) {
      [connection cancel];
      NSDictionary * errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:NSLocalizedString(@"Server returned status code %d",@""),
									      statusCode]
							     forKey:NSLocalizedDescriptionKey];
      NSError * statusError = [NSError errorWithDomain:@"HTTP Property Status Code" //NSHTTPPropertyStatusCodeKey
						  code:statusCode
					      userInfo:errorInfo];
      [self connection:connection didFailWithError:statusError];
    }
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSLog(@"connectionDidFinishLoading");
  if (state == TwitterXAuthStateAuthorize) {
    NSLog(@"authorize");
    NSString * response = [[[NSString alloc] initWithData:data
						 encoding:NSUTF8StringEncoding] autorelease];
    NSArray * parameters = [response componentsSeparatedByString:@"&"];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * parameter in parameters) {
      NSArray * keyAndValue = [parameter componentsSeparatedByString:@"="];
      if (keyAndValue == nil || [keyAndValue count] != 2)
	continue;
      NSString * key = [keyAndValue objectAtIndex:0];
      NSString * value = [keyAndValue lastObject];
      [dictionary setObject:value forKey:key];
    }
    if ([dictionary objectForKey:@"oauth_token_secret"])
      self.tokenSecret = [dictionary objectForKey:@"oauth_token_secret"];
    if ([dictionary objectForKey:@"oauth_token"])
      self.token = [dictionary objectForKey:@"oauth_token"];
    if (delegate && [delegate respondsToSelector:@selector(twitterXAuthDidAuthorize:)])
      [delegate twitterXAuthDidAuthorize:self];
  } else if (state == TwitterXAuthStateTweet) {
    NSLog(@"tweet");
    if (delegate && [delegate respondsToSelector:@selector(twitterXAuthDidTweet:)])
      [delegate twitterXAuthDidTweet:self];
  }
}

@end
