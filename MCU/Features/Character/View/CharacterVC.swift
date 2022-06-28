//
//  CharacterVC.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import UIKit
import SDWebImage


class CharacterVC: UICollectionViewController {
    private var searchTask: DispatchWorkItem?
    private var cellType: MCUCellType = .skeletonCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "CharacterCell", bundle: nil), forCellWithReuseIdentifier: "CharacterCell")
        
        // Do any additional setup after loading the view.
        self.collectionView.collectionViewLayout = createLayout()
        callAPI()
    }
    
    func callAPI(withSearch searchQuery: String = "") {
        // call api to fetch characters
    }
    
    func updateLayput(forCellType cellType: MCUCellType) {
        self.cellType = cellType
        self.collectionView.collectionViewLayout = self.createLayout()
        self.collectionView.reloadData()
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        // Item
        let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 6)
        
        // Group
        let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.3), item: item, count: 2)
        // Section
        let section = NSCollectionLayoutSection(group: group)
        // return
        return UICollectionViewCompositionalLayout(section: section)
    }
 
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let aCell: CharacterCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCell else {return UICollectionViewCell()}
        
        return aCell
    }

}

