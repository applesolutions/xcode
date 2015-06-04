//
//  Constants.m
//  Mooncode
//
//  Created by amaury soviche on 30/05/15.
//  Copyright (c) 2015 Amaury Soviche. All rights reserved.
//

@import Foundation;

//*********UI MESSAGES**********
NSString *const loadingMessage = @"Thank you for downloading our App!\n \nNow downloading the content, it should take less than a minute and only happen once. \n \nMake sure you are connected to the Internet !";
NSString *const noInternetConnectionMessage = @"It seems you are not connected to the internet... \nReconnect and try again :)";
NSString *const noCollectionToDisplayMessage = @"This shop has no product yet, come back later !";

//********* shop constants ******
NSString *const website_url = @"https://buyonesnap.myshopify.com";
NSString *const website_cart_url = @"https://buyonesnap.myshopify.com";

//**** server keys from our server*******

//***** server key from shopify server******

//****** phone memory keys *******

//displayed & featured collections (from our server)
NSString *const kMOONdisplayedCollections = @"displayedCollections";
NSString *const kMOONfeaturedCollections = @"featuredCollections";

//organized Shopify products & collections : id = collections / id = products
NSString *const kMOONdicShopifyCollections = @"dicCollections";
NSString *const kMOONdicShopifyProducts = @"dicProducts";

//NSUserDefaults

//storyboard names ( storyboard + ViewControllers )


//sahring keys
NSInteger const kMOONShareOnTwitterFromSettings = 0;
NSInteger const kMOONShareOnTwitterFromProductDetails = 1;
