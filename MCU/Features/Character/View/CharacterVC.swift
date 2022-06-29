//
//  CharacterVC.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import UIKit
import SDWebImage

/// CharacterVC - UICollectionViewController responsible for showing list of characters
class CharacterVC: UICollectionViewController {
    
    /// list of character which is coming from network will be store inside this array
    private var arrCharacters:[CharacterResult] = []
    /// default search history and user searched history will be store in this array
    private var arrSearchHistory:[String] = ["Tony Stark", "Natasha", "Hulk", "Thanos"]
    /// refence of viewmodel responsible to make network call and data manipulation
    private let viewModelCharacter = ViewModelCharacter()
    /// search controller which will be resides on navigation bar so that user can search characters from this controller
    private let searchController = UISearchController(searchResultsController: nil)
    /// search task to make network call after some amount of time
    private var searchTask: DispatchWorkItem?
    /// enum refrence which is act as an argument in methods to manipulate UI of screen
    private var cellType: MCUCellType = .skeletonCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.collectionView.collectionViewLayout = createLayout()
        showSearchController()
        callAPI()
    }
    
    /// register cell in collectionView
    private func registerCell(){
        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "CharacterCell", bundle: nil), forCellWithReuseIdentifier: "CharacterCell")
        self.collectionView!.register(UINib.init(nibName: "SkeletonCell", bundle: nil), forCellWithReuseIdentifier: "SkeletonCell")
        self.collectionView!.register(UINib.init(nibName: "EmptyCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCell")
        self.collectionView!.register(UINib.init(nibName: "SearchHistoryCell", bundle: nil), forCellWithReuseIdentifier: "SearchHistoryCell")
    }
    
    /// search controller configuration
    func showSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search characters"
        searchController.searchBar.tintColor = UIColor.red // #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationController?.navigationBar.sizeToFit()
    }
    
    /// execute network call to fetch list of characters
    /// - Parameter searchQuery: string which is resposible to query data according to user search
    func callAPI(withSearch searchQuery: String = "") {
        viewModelCharacter.getCharacters(searchCharacter: searchQuery) { arrCharacters in
            if arrCharacters.count > 0 {
                self.cellType = .normalCell
                self.arrCharacters = arrCharacters
            } else {
                self.cellType = .emptyCell
            }
            self.updateLayput(forCellType: self.cellType)
        }
    }
    
    /// update collectionView cell layout as per user actions
    /// - Parameter cellType: type of cell which need to be diplay on collectionView
    func updateLayput(forCellType cellType: MCUCellType) {
        self.cellType = cellType
        self.collectionView.collectionViewLayout = self.createLayout()
        self.collectionView.reloadData()
    }
    
    /// create layout for collectionview cell
    /// - Returns: compositionalLayout which later been assign to collectionView to render UI as per the given sected cell
    func createLayout() -> UICollectionViewCompositionalLayout {
        switch cellType {
        case .skeletonCell, .normalCell, .searchingCell:
            // Item
            let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 6)
            // Group
            let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.3), item: item, count: 2)
            // Section
            let section = NSCollectionLayoutSection(group: group)
            // return
            return UICollectionViewCompositionalLayout(section: section)
        case .emptyCell:
            // Item
            let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 6)
            // Group
            let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.6), item: item, count: 1)
            // Section
            let section = NSCollectionLayoutSection(group: group)
            // return
            return UICollectionViewCompositionalLayout(section: section)
        case .searchHistoryCell:
            // Item
            let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 6)
            // Group
            let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.05), item: item, count: 1)
            // Section
            let section = NSCollectionLayoutSection(group: group)
            // return
            return UICollectionViewCompositionalLayout(section: section)
        
        }

    }
 
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch cellType {
        case .skeletonCell:
            return 20
        case .emptyCell:
            return 1
        case .searchHistoryCell:
            return arrSearchHistory.count
        case .normalCell,.searchingCell:
            return arrCharacters.count
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch cellType {
        case .skeletonCell:
            guard let aCell: SkeletonCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as? SkeletonCell else {return UICollectionViewCell()}
            return aCell
        case .emptyCell:
            guard let aCell: EmptyCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as? EmptyCell else {return UICollectionViewCell()}
            return aCell
        case .searchHistoryCell:
            guard let aCell: SearchHistoryCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "SearchHistoryCell", for: indexPath) as? SearchHistoryCell else {return UICollectionViewCell()}
            let obj = arrSearchHistory[indexPath.row]
            aCell.lblSearch.text = obj
            return aCell
        
        case .normalCell,.searchingCell:
            guard let aCell: CharacterCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCell else {return UICollectionViewCell()}
            let obj = arrCharacters[indexPath.row]
            if let path = obj.thumbnail?.path, let ext = obj.thumbnail?.thumbnailExtension {
                let imgURL = path + "." + ext
                aCell.imgView.sd_setImage(with: URL(string: imgURL))
            }
            if let name = obj.name {
                aCell.btnName.isHidden = false
                aCell.btnName.setTitle(name, for: .normal)
            } else {
                aCell.btnName.isHidden = true
            }
            return aCell
        }
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch cellType {
        case .skeletonCell,
             .emptyCell,
             .searchHistoryCell:
            break
        case .normalCell,.searchingCell:
            if indexPath.item == self.arrCharacters.count - 4 && self.arrCharacters.count  < viewModelCharacter.totalListOnServerCount {
                viewModelCharacter.offset += viewModelCharacter.pageSize
                self.callAPI(withSearch: searchController.searchBar.text ?? "")
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch cellType {
        case .skeletonCell,
             .emptyCell,
             .normalCell,.searchingCell:
            break
        case .searchHistoryCell:
            if let callRequest = viewModelCharacter.characterCancellation{
                viewModelCharacter.offset = 0
                viewModelCharacter.isFetching = false
                callRequest.cancel()
            }
            let obj = arrSearchHistory[indexPath.row]
            searchController.searchBar.text = obj
            callAPI(withSearch: searchController.searchBar.text ?? "")
        }
    }
    
}

extension CharacterVC: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text?.count ?? 0 > 0 {
            viewModelCharacter.offset = 0
            self.searchTask?.cancel()
            let task = DispatchWorkItem { [weak self] in
                self?.reloadSearchTask()
            }
            self.searchTask = task
            // Execute task in 0.5 seconds (if not cancelled !)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task)
        } else if searchController.searchBar.text?.count == 0 {
            if searchController.isActive {
                self.updateLayput(forCellType: .searchHistoryCell)
            }
        }
    }
    
    /// Called from text did change after 0.5 seconds to avoid multiple api calls.
    /// - Parameter searchText: String that user enters on search field
    @objc func reloadSearchTask() {
        if let aSearchText = searchController.searchBar.text {
            self.callAPI(withSearch: aSearchText)
        }
    }
    
    // MARK: - UISearchBarDelegate Methods
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let callRequest = viewModelCharacter.characterCancellation{
            viewModelCharacter.offset = 0
            viewModelCharacter.isFetching = false
            callRequest.cancel()
        }
        callAPI(withSearch: "")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.updateLayput(forCellType: .searchHistoryCell)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.updateLayput(forCellType: .normalCell)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchQuery = searchBar.text, searchQuery.count > 0, !arrSearchHistory.contains(searchQuery) {
            arrSearchHistory.insert(searchQuery, at: 0)
        }
        self.view.endEditing(true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}
