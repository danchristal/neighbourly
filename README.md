# Neighbourly
Final Project for Lighthouse Labs (2 week build time)
By Dan

iOS application developed in Swift 3.0.

Neighbourly is a trade only community created to allow users to exchange goods &
services in their neighbourhood without exchanging money.
 - Everyone has items of little value they no longer have use for.
 - Creates a sense of community while interacting with nearby neighbours.

Users can quickly snap a photo and upload a quick description of the item along with the desired 
item(s) or service they are seeking in return. The users current location is then used to determine the current neighbourhood they are located in which is displayed to other users.

The longer a user continues to exchange an item, the more the score for that individual item increases.

Neighbourly uses Firebase realtime database in order to allow users to see the newest posts at all times without needing to refresh. 

CoreLocation is used to determine the new posts general area, in terms of the current neighbourhood, to allow other users to determine how near posts are.

Push notifications are then used to notify users of pending and accepted trade requests.

CocoaPods:
- Firebase - BaaS for the project.
