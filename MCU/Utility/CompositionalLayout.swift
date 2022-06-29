//
//  CompositionalLayout.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import Foundation
import UIKit

/// enum whether collectionView Layout flow either horizontal or vertical
enum CompositionalGroupAlignment {
    case vertical
    case horizontal
}

/// composition layout to build cell layout on collectionview
struct CompositionalLayout {
    
    /// create collection layout item
    /// - Parameters:
    ///   - width: width of item
    ///   - height: height of item
    ///   - spacing: spacing around an item
    /// - Returns: describe item layout and return NSCollectionLayoutItem
    static func createItem(width: NSCollectionLayoutDimension,
                           height: NSCollectionLayoutDimension,
                           spacing: CGFloat) -> NSCollectionLayoutItem {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: width, heightDimension: height))
        item.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        return item
    }
    
    
    /// create collection layout group with multiple items
    /// - Parameters:
    ///   - alignment: define horizontal or vertical layout of group
    ///   - width: width of group
    ///   - height: height of group
    ///   - items: number of items in group
    /// - Returns: return entire collection layout group
    static func createGroup(alignment: CompositionalGroupAlignment,
                            width: NSCollectionLayoutDimension,
                            height: NSCollectionLayoutDimension,
                            items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: width, heightDimension: height), subitems: items)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: width, heightDimension: height), subitems: items)
        }
    }
    
    /// create collection layout group with single items
    /// - Parameters:
    ///   - alignment: define horizontal or vertical layout of group
    ///   - width: width of group
    ///   - height: height of group
    ///   - items: number of items in group
    /// - Returns: return entire collection layout group
    static func createGroup(alignment: CompositionalGroupAlignment,
                            width: NSCollectionLayoutDimension,
                            height: NSCollectionLayoutDimension,
                            item: NSCollectionLayoutItem,
                            count: Int) -> NSCollectionLayoutGroup {
        switch alignment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: width, heightDimension: height), subitem: item, count: count)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: width, heightDimension: height), subitem: item, count: count)
        }
    }
}
