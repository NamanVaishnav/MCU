//
//  ViewModelCharacter.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import Foundation
import Moya

class ViewModelCharacter {
    
    var isFetching: Bool = false
    var offset = 0
    var totalListOnServerCount = 0 // it must be returned from server
    var pageSize = 10 // get 10 objects for instance
    var arrCharacters: [CharacterResult] = []
    var characterCancellation: Cancellable?
    
    
    func getCharacters(searchCharacter searchQuery: String = "", completion: @escaping (_ arrCharacters:[CharacterResult]) -> Void) {
        // return from function if already fetching list
        guard !isFetching else {return}
        if offset == 0 {
            // empty list for first call i.e offset = 0
            self.arrCharacters.removeAll()
        }
        isFetching = true
        characterCancellation = Network.request(target: .characters(pageSize, offset, searchQuery), resultType: ModelCharacter.self) { result in
            self.isFetching = false
            switch result {
            case .success(let response, let success):
                if success {
                    guard let objResponse = response as? ModelCharacter else { return }
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
