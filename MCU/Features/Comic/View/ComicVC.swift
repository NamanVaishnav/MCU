//
//  ComicVC.swift
//  MCU
//
//  Created by Naman Vaishnav on 29/06/22.
//

import UIKit


class ComicVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var arrComics:[ComicResult] = []
    private var arrSearchHistory:[String] = ["Star Wars", "Fantastic Four", "Moon knight", "Hulk"]
    private let viewModelComic = ViewModelComic()
    
    private var searchTask: DispatchWorkItem?
    private var cellType: MCUCellType = .skeletonCell
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "CharacterCell", bundle: nil), forCellWithReuseIdentifier: "CharacterCell")
        self.collectionView!.register(UINib.init(nibName: "SkeletonCell", bundle: nil), forCellWithReuseIdentifier: "SkeletonCell")
        self.collectionView!.register(UINib.init(nibName: "EmptyCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCell")
        self.collectionView!.register(UINib.init(nibName: "SearchHistoryCell", bundle: nil), forCellWithReuseIdentifier: "SearchHistoryCell")

        self.collectionView.collectionViewLayout = createLayout()
        configureSearchBarTextField()
        callAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    /// register cell in collectionView
    private func registerCell(){
        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: "CharacterCell", bundle: nil), forCellWithReuseIdentifier: "CharacterCell")
        self.collectionView!.register(UINib.init(nibName: "SkeletonCell", bundle: nil), forCellWithReuseIdentifier: "SkeletonCell")
        self.collectionView!.register(UINib.init(nibName: "EmptyCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCell")
        self.collectionView!.register(UINib.init(nibName: "SearchHistoryCell", bundle: nil), forCellWithReuseIdentifier: "SearchHistoryCell")
    }
    
    
    /// configure search bar text field
    func configureSearchBarTextField() {
        searchBar.placeholder = "Search comic"
        searchBar.tintColor = UIColor.red // #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        for subView in searchBar.subviews {
            for subsubView in subView.subviews {
                if let textField = subsubView as? UITextField {
                    var bounds: CGRect
                    bounds = textField.frame
                    textField.bounds = bounds
                    textField.layer.cornerRadius = 8
                    textField.layer.borderWidth = 1.0
                    textField.layer.borderColor = UIColor.white.cgColor
                    textField.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    /// execute network call to fetch list of comic
    /// - Parameters:
    ///   - searchQuery: string which is resposible to query data according to user search
    ///   - filter: filter for comic timeline
    func callAPI(withSearch searchQuery: String = "", forFilter filter: FilterType = .thisMonth) {
        viewModelComic.getComics(searchCharacter: searchQuery, forFilter: filter) { arrComic in
            if arrComic.count > 0 {
                self.cellType = .normalCell
                self.arrComics = arrComic
            } else {
                self.cellType = .emptyCell
            }
            self.updateLayput(forCellType: self.cellType)
        }
    }
    
    /// action for filter
    /// - Parameter sender: sender
    @IBAction func actionFilter(_ sender: Any) {
        
        let searchQuery = searchBar.text ?? ""
        let lastWeek = UIAction(title: FilterType.lastWeek.rawValue) { (action) in
            self.callAPI(withSearch: searchQuery, forFilter: .lastWeek)
        }
        
        let thisWeek = UIAction(title: FilterType.thisWeek.rawValue) { (action) in
            self.callAPI(withSearch: searchQuery, forFilter: .thisWeek)
        }
 
        let nextWeek = UIAction(title: FilterType.nextWeek.rawValue) { (action) in
            self.callAPI(withSearch: searchQuery, forFilter: .nextWeek)
        }
        
        let thisMonth = UIAction(title: FilterType.thisMonth.rawValue) { (action) in
            self.callAPI(withSearch: searchQuery, forFilter: .thisMonth)
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [lastWeek , thisWeek , nextWeek, thisMonth])
        
        btnFilter.menu = menu
        btnFilter.showsMenuAsPrimaryAction = true
    }
    
    
    /// update collection view layout
    /// - Parameter cellType: type of cell which will get rendered on collection view
    func updateLayput(forCellType cellType: MCUCellType) {
        self.cellType = cellType
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout = self.createLayout()
            self.collectionView.reloadData()
        }
    }
    
    /// create layout
    /// - Returns: compostional layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        switch cellType {
        case .skeletonCell, .normalCell, .searchingCell:
            // Item
            let item = CompositionalLayout.createItem(width: .fractionalWidth(1), height: .fractionalHeight(1), spacing: 6)
            
            // Group
            let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.4), item: item, count: 2)
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
            let group = CompositionalLayout.createGroup(alignment: .horizontal, width: .fractionalWidth(1), height: .fractionalHeight(0.08), item: item, count: 1)
            // Section
            let section = NSCollectionLayoutSection(group: group)
            // return
            return UICollectionViewCompositionalLayout(section: section)
        
        }
    }
}

extension ComicVC: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch cellType {
        case .skeletonCell:
            return 20
        case .emptyCell:
            return 1
        case .searchHistoryCell:
            return arrSearchHistory.count
        case .normalCell,.searchingCell:
            return arrComics.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            let obj = arrComics[indexPath.row]
            if let path = obj.thumbnail?.path, let ext = obj.thumbnail?.thumbnailExtension {
                let imgURL = path + "." + ext
                aCell.imgView.sd_setImage(with: URL(string: imgURL))
            }
            if let name = obj.title {
                aCell.btnName.isHidden = false
                aCell.btnName.setTitle(name, for: .normal)
            } else {
                aCell.btnName.isHidden = true
            }
            return aCell
        }
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch cellType {
        case .skeletonCell,
             .emptyCell,
             .searchHistoryCell:
            break
        case .normalCell,.searchingCell:
            if indexPath.item == self.arrComics.count - 4 && self.arrComics.count  < viewModelComic.totalListOnServerCount {
                viewModelComic.offset += viewModelComic.pageSize
                self.callAPI(withSearch: searchBar.text ?? "")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch cellType {
        case .skeletonCell,
             .emptyCell,
             .normalCell,.searchingCell:
            break
        case .searchHistoryCell:
            if let callRequest = viewModelComic.characterCancellation{
                viewModelComic.offset = 0
                viewModelComic.isFetching = false
                callRequest.cancel()
            }
            let obj = arrSearchHistory[indexPath.row]
            searchBar.text = obj
            callAPI(withSearch: searchBar.text ?? "")
        }
    }
}

extension ComicVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.updateLayput(forCellType: .searchHistoryCell)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count ?? 0 > 0 {
            viewModelComic.offset = 0
            self.searchTask?.cancel()
            let task = DispatchWorkItem { [weak self] in
                self?.reloadSearchTask()
            }
            self.searchTask = task
            // Execute task in 0.5 seconds (if not cancelled !)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task)
        } else if searchBar.text?.count == 0 {
            if searchBar.showsCancelButton {
                self.updateLayput(forCellType: .searchHistoryCell)
            }
        }
    }
  
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.updateLayput(forCellType: .normalCell)
        self.searchBar.showsCancelButton = false
    }
    /// Called from text did change after 0.5 seconds to avoid multiple api calls.
    /// - Parameter searchText: String that user enters on search field
    @objc func reloadSearchTask() {
        if let aSearchText = searchBar.text {
            self.callAPI(withSearch: aSearchText)
        }
    }
    
    // MARK: - UISearchBarDelegate Methods
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let callRequest = viewModelComic.characterCancellation{
            viewModelComic.offset = 0
            viewModelComic.isFetching = false
            callRequest.cancel()
        }
        callAPI(withSearch: "")
        self.searchBar.showsCancelButton = false
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchQuery = searchBar.text, searchQuery.count > 0 , !arrSearchHistory.contains(searchQuery){
            arrSearchHistory.insert(searchQuery, at: 0)
        }
        self.view.endEditing(true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}
