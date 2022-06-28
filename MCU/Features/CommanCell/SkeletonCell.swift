//
//  SkeletonCell.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import UIKit

class SkeletonCell: UICollectionViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewName: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        viewBG.layer.cornerRadius = 12.0
        viewBG.clipsToBounds = true
    }

}
