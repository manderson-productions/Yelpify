# Yelpify

An example project using the Yelp API to pull in a list of businesses to display them in a UICollectionView. The project uses CocoaPods, specifically the TDOAuth pod. The Pods directory and dependencies have been included in this project repository, however if there are any issues/warnings/errors, please do the following just to be sure:

`cd Yelpify`

`pod install`

Yelpify uses the Yelp API to populate a UICollectionView with image_urls associated with a business. If you decide to allow 'Location Services When In Use', these image_urls will correspond to businesses in your 'locality'. Otherwise, these image_urls will correspond to businesses in the Brooklyn locality. In order to load more images from image_urls, simply scroll to the bottom until the spinner indicates new images being loaded. If a request fails for any reason (lost internet connection, etc.), images that were previously loaded will persist in the image cache. This cache will persist across app sessions, and will be reset when the app is uninstalled.
