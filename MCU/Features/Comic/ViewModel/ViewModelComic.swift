//
//  ViewModelComic.swift
//  MCU
//
//  Created by Naman Vaishnav on 29/06/22.
//

import Foundation
import Moya

enum FilterType: String{
    case lastWeek
    case thisWeek
    case nextWeek
    case thisMonth
}

class ViewModelComic {
    
    /// used to determine whether data is being fetch from server or not
    var isFetching: Bool = false
    /// offset will be the integer of amout of data which has been already rendered on UI
    var offset = 0
    /// list of data which are avaliable on server
    var totalListOnServerCount = 0 // it must be returned from server
    /// size of response which we required in single request
    var pageSize = 10 // get 10 objects for instance
    /// list of characters which will be filled from network response
    var arrCharacters: [ComicResult] = []
    /// network call cancellation
    var characterCancellation: Cancellable?
    
    /// fetch list of MCU comics from network
    /// - Parameters:
    ///   - searchQuery: search reseult which need to be requested by end user
    ///   - completion: handler which will get invoke once response arrived
    func getComics(searchCharacter searchQuery: String = "", forFilter filter: FilterType = .thisMonth, completion: @escaping (_ arrComic:[ComicResult]) -> Void) {
        // return from function if already fetching list
        guard !isFetching else {return}
        if offset == 0 {
            // empty list for first call i.e offset = 0
            self.arrCharacters.removeAll()
        }
        isFetching = true
        characterCancellation = Network.request(target: .comics(pageSize, offset, searchQuery, filter.rawValue), resultType: ModelComic.self) { result in
            self.isFetching = false
            switch result {
            case .success(let response, let success):
                if success {
                    guard let objResponse = response as? ModelComic else { return }
                    self.totalListOnServerCount = objResponse.data?.total ?? 0
                    if let result = objResponse.data?.results {
                        if self.offset == 0 {
                            // fetch response from server for first fetch
                            self.arrCharacters = result
                        } else {
                            // append if already exist ( pagination )
                            self.arrCharacters.append(contentsOf: result)
                        }
                        completion(self.arrCharacters)
                    } else {
                        completion(self.arrCharacters)
                    }
                }
            case .failure(let err, _):
                completion(self.arrCharacters)
                print(err.localizedDescription)
            }
        }
    }
}
