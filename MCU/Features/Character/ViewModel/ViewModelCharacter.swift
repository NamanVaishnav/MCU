//
//  ViewModelCharacter.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import Foundation
import Moya
import DataCache

class ViewModelCharacter {
    
    /// used to determine whether data is being fetch from server or not
    var isFetching: Bool = false
    /// offset will be the integer of amout of data which has been already rendered on UI
    var offset = 0
    /// list of data which are avaliable on server
    var totalListOnServerCount = 0 // it must be returned from server
    /// size of response which we required in single request
    var pageSize = 10 // get 10 objects for instance
    /// list of characters which will be filled from network response
    var arrCharacters: [CharacterResult] = []
    /// network call cancellation
    var characterCancellation: Cancellable?
    
    
    /// fetch list of MCU characters from network
    /// - Parameters:
    ///   - searchQuery: search reseult which need to be requested by end user
    ///   - completion: handler which will get invoke once response arrived
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
                        if searchQuery.count == 0 { // cache characters
                            self.storeCharacterData(forArray: self.arrCharacters)
                        }
                        completion(self.arrCharacters)
                    } else {
                        completion(self.fetchCharacterData())
                    }
                }
            case .failure(let err, _):
                completion(self.fetchCharacterData())
                print(err.localizedDescription)
            }
        }
    }
    
    /// cache charcter data
    /// - Parameter arrChar: list of character which came from network will be passed as a parameter to store on disk
    fileprivate func storeCharacterData(forArray arrChar: [CharacterResult]) {
        do {
            try DataCache.instance.write(codable: arrChar, forKey: NetworkCache.character.rawValue)
        } catch {
            print("Write error \(error.localizedDescription)")
        }
    }
    
    /// fetch character data
    /// - Returns: list of character will get returned which has bee stored earlient in case of network failiure
    fileprivate func fetchCharacterData() -> [CharacterResult] {
        do {
            let arrcachedCharacters: [CharacterResult]? = try DataCache.instance.readCodable(forKey: NetworkCache.character.rawValue)
            if let arrcachedCharacters = arrcachedCharacters, arrcachedCharacters.count > 0 {
                return arrcachedCharacters
            } else {
                return []
            }
        } catch {
            debugPrint("Character Read error \(error.localizedDescription)")
            return []
        }
    }
}
