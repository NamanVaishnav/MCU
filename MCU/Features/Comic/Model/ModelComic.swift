//
//  ModelComic.swift
//  MCU
//
//  Created by Naman Vaishnav on 29/06/22.
//

import Foundation

// MARK: - ModelComic
struct ModelComic: Codable {
    let code: Int?
    let status: String?
    let data: ComicClass?
}

// MARK: - DataClass
struct ComicClass: Codable {
    let offset, limit, total, count: Int?
    let results: [ComicResult]?
}

// MARK: - Result
struct ComicResult: Codable {
    let title: String?
    let thumbnail: Thumbnail?
    
    enum CodingKeys: String, CodingKey {
        case title
        case thumbnail
    }
}
