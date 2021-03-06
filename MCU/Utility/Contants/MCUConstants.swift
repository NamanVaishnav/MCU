//
//  MCUConstants.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import Foundation

/// MCU Constants  relavant to network
enum MCUConstant {
    enum ListPageLimit {
        static let limit = 10
    }
    enum APIUrl {
        static let base_url = "https://gateway.marvel.com/v1/public"
    }
    enum APIPath {
        static let characterList = "/characters"
        static let comicList = "/comics"
    }
    enum APIKey {
        static let publicKey = "91f8fe474b907e3478f97fcbe8c979d5"
        static let privateKey = "6828acd63a2c4fbe740f1cee084eb4760f4ac651"
    }
}

/// result either success or failure
enum Results<Value, Bool> {
    case success(Value, Bool)
    case failure(Error, Bool)
}

/// type of cell which will be rendered on collectionview
enum MCUCellType {
    case skeletonCell
    case normalCell
    case emptyCell
    case searchingCell
    case searchHistoryCell
}

/// list of cache constants
enum NetworkCache: String{
    case character
    case comic
}
