//
//  YelpifyTests.swift
//  YelpifyTests
//
//  Created by Mark Anderson on 2/21/16.
//  Copyright © 2016 markmakingmusic. All rights reserved.
//

import XCTest
@testable import Yelpify

class YelpifyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSavingToImageCacheProducesExpectedResults() {
        let e = self.expectationWithDescription("testSavingToImageCacheProducesExpectedResults")
        var imageCache = MAImageCache()
        MANetworkManager.searchWithOffset(imageCache.count()) { (results, error) -> Void in
            let imageURLs = results.reduce([NSURL](), combine: { (var output, dict) in
                let urlString = dict["image_url"] as! String
                output.append(NSURL(string: urlString)!)
                return output
            })
            imageCache.cacheImagesFromURLStrings(imageURLs, withCompletionBlock: {
                XCTAssertEqual(imageURLs.count, Int(imageCache.count()))
                imageCache = MAImageCache.unarchive()
                XCTAssertEqual(imageURLs.count, Int(imageCache.count()))
                e.fulfill()
            })
        }
        self.waitForExpectationsWithTimeout(120) {
            if $0 != nil { print("Error: \($0)") }
        }
    }

    func testSearchWithOffsetMethodReturnsValidResultsWithImageURLField() {
        let e = self.expectationWithDescription("testSearchWithOffsetMethodReturnsValidResultsWithImageURLField")
        let randoNumber: UInt = 43
        MANetworkManager.searchWithOffset(randoNumber) { (results, error) in
            XCTAssertNotNil(results)
            XCTAssertNil(error)
            e.fulfill()
        }
        self.waitForExpectationsWithTimeout(120) {
            if $0 != nil { print("Error: \($0)") }
        }
    }
}
