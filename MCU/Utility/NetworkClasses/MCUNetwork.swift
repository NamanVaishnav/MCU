//
//  MCUNetwork.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import Foundation
import Moya
import CryptoKit

let provider = MoyaProvider<Marvel>()

enum Marvel {
    static private let publicKey = MCUConstant.APIKey.publicKey
    static private let privateKey = MCUConstant.APIKey.privateKey
  
    case characters(_ limit: Int,_ offset: Int,_ search: String)
    case comics(_ limit: Int,_ offset: Int,_ search: String,_ dateFilter: String)
}

extension Marvel: TargetType {
    public var baseURL: URL {
        return URL(string: MCUConstant.APIUrl.base_url)!
    }
    
    public var path: String {
        switch self {
        case .characters: return MCUConstant.APIPath.characterList
        case .comics: return MCUConstant.APIPath.comicList
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .characters, .comics: return .get
        }
    }
    
    public var task: Task {
        let ts = "\(Date().timeIntervalSince1970)"
        let hashString = ts+"\(MCUConstant.APIKey.privateKey)"+"\(MCUConstant.APIKey.publicKey)"
        let digest = Insecure.MD5.hash(data: hashString.data(using: .utf8) ?? Data())
        let hash = digest.map {
            String(format: "%02hhx", $0)
        }.joined()
        let authParams = ["apikey": MCUConstant.APIKey.publicKey, "ts": ts, "hash": hash]
        
        switch self {
        case .characters(let limit, let offset, let searchQuery):
            return .requestParameters(parameters: ["limit": limit, "offset": offset] + authParams + (searchQuery.count > 0 ? ["nameStartsWith" : searchQuery] : [:]),
                                            encoding: URLEncoding.default)
        case .comics(let limit, let offset, let searchQuery, let dateFilter):
            return .requestParameters(parameters: ["format": "comic",
                                                         "formatType": "comic",
                                                         "orderBy": "-onsaleDate",
                                                         "dateDescriptor": dateFilter, //"lastWeek",
                                                         "limit": limit,
                                                         "offset": offset
                                                  ] + authParams + (searchQuery.count > 0 ? ["titleStartsWith" : searchQuery] : [:]),
                                            encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}

// MARK: - NETWORK Wraper class
class Network {
    ///   - completion: typealias for Results
    public typealias Completion<T: Codable> = (Results<Any?, Bool>) -> Void
    
    @discardableResult
    class func request<T: Codable>(target: Marvel, isSilent: Bool = false, resultType: T.Type, completion: @escaping Completion<T?>) -> Cancellable {
        
        debugPrint("==== URL ===== \(target.baseURL)")
        debugPrint("==== PATH ==== \(target.path)")
        debugPrint("==== METHOD ==== \(target.method.rawValue)")
        debugPrint("==== HEADER ==== \(target.headers ?? [:])")
        debugPrint("==== PARAMETER ==== \(target.task)")
        
        return provider.request(target) { (result) in
            
            switch result {
            case let .success(response):
                switch response.statusCode {
                case 200...300  : // greater or equal than 200 and less or equal than 300
                    do {
                        let data = try JSONDecoder().decode(resultType.self, from: response.data)
                        debugPrint(data)
                        let jsonResponse = try JSONSerialization.jsonObject(with:
                            response.data, options: [])
                        debugPrint(jsonResponse) // Response result

                        completion(.success(data, true))
                    } catch let error {
                        
                        debugPrint("---ParsingError---\(error)")
                        debugPrint("NOT ABLE TO PARSE DATA")
                        debugPrint(error.localizedDescription)
                        completion(.success(nil, true))
                    }
                  
                default:
                    debugPrint("NOT ABLE TO PARSE DATA")
                }
                
            case .failure(let error):
                switch error {
                    
                case let .underlying(nsError as NSError, response):
                    debugPrint(nsError.code)
                    debugPrint(nsError.domain)
                    debugPrint(response ?? "NA")
                default:
                    break
                }
                completion(.failure(error, false))
            }
        }
    }
}

