//
//  MainViewController.swift
//  Pexels
//
//  Created by Айбану Уатбаева on 13.10.2023.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHistoryCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var searchHistoryCollectionViewHeight: NSLayoutConstraint!
    
    var searchPhotosResponce: SearchPhotosResponce? {
        didSet {
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()
            }
            
        }
    }
    var photos: [Photo] {
        return searchPhotosResponce?.photos ?? []
    }
    let savedSearchTextArrayKey: String = "savedSearchTextArrayKey"
    var searchTextArray: [String] = [] {
        didSet {
            searchHistoryCollectionView.reloadData()
            searchHistoryCollectionViewHide()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Pexels"
        searchBar.delegate = self
        
        // Image collection view SETUP
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        imageCollectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.refreshControl = UIRefreshControl()
        imageCollectionView.refreshControl?.addTarget(self, action: #selector(search), for: .valueChanged)
        
        // Search history Collection view SETUP
        let flowLayout = searchHistoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        searchHistoryCollectionView.register(UINib(nibName: SearchTextCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SearchTextCollectionViewCell.identifier)
        searchHistoryCollectionView.dataSource = self
        
        resetSearchTextArray()
        
        
        searchHistoryCollectionView.delegate = self
        
    }
    
    @objc
    func search(){
        
        self.searchPhotosResponce = nil
        
        guard let searchText = searchBar.text else {
            print("Search bar text is nil")
            return
        }
        
        guard !searchText.isEmpty else {
            print("Search text is empty")
            return
        }
        //Save search text
        save(searchText: searchText)
        
        let endpoint: String = "https://api.pexels.com/v1/search"
        guard var urlComponents =  URLComponents(string: endpoint) else {
            print("Couldn't create URLComponents instance from endpoint - \(endpoint)")
            return
        }
        
        let parameters = [
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        urlComponents.queryItems = parameters
        
        guard let url: URL = urlComponents.url else {
            print("URL is nil")
            return
        }
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let APIKey: String = "yYMuvKXAL4gOogI6btr2u2rdEnuBoB3lmuEHPRsH7qgUlmVHWkF2TJuW"
        urlRequest.addValue(APIKey, forHTTPHeaderField: "Authorization")
        
        if imageCollectionView.refreshControl?.isRefreshing == false {
            imageCollectionView.refreshControl?.beginRefreshing()
        }
        let urlSession: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = urlSession.dataTask(with: urlRequest, completionHandler: searchPhotosHandler(data:urlResponse:error:))
        
        dataTask.resume()
        
    }
    
    func searchPhotosHandler(data: Data?, urlResponse: URLResponse?, error: Error?){
        
        DispatchQueue.main.async {
            if self.imageCollectionView.refreshControl?.isRefreshing == true {
                self.imageCollectionView.refreshControl?.endRefreshing()
            }
        }
       
        
        print("Method searchPhotosHandler was called")
        
        if let error = error {
            
            print("Search photos endpoint error - \(error.localizedDescription)")
            
        }else if let data = data {
            
            print("Search photos endpoint data - \(data)")
            
            do {
                
//                let jsonObject = try JSONSerialization.jsonObject(with: data)
//                print("Search photos endpoint jsonObject - \(jsonObject)")
                let searchPhotosResponce = try JSONDecoder().decode(SearchPhotosResponce.self, from: data)
                print("Search photos endpoint searchPhotosResponce - \(searchPhotosResponce)")
                self.searchPhotosResponce = searchPhotosResponce
            } catch let error {
                print("Search photos endpoint serialization error - \(error.localizedDescription)")
            }
            
        }
        
        if let urlResponse = urlResponse, let httpResponce = urlResponse as? HTTPURLResponse {
            print("Search photos endpoint http responce status code - \(httpResponce.statusCode)")
        }
    }
    func save(searchText: String){
        var existingArray: [String] = getSavedSearchTextArray()
        existingArray.append(searchText)
        
        UserDefaults.standard.set(existingArray, forKey: savedSearchTextArrayKey)
        
        resetSearchTextArray()
    }
    func getSavedSearchTextArray()->[String]{
        let array: [String] = UserDefaults.standard.stringArray(forKey: savedSearchTextArrayKey) ?? []
        return array
    }
    func resetSearchTextArray() {
        
        self.searchTextArray = getUniqueSearchTextArray()
    
    }
    
    func searchHistoryCollectionViewHide(){
        if self.searchTextArray.count > 0 && self.searchHistoryCollectionViewHeight.constant != 60 {
            searchHistoryCollectionViewHeight.constant = 60
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
        } else {
            searchHistoryCollectionViewHeight.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func getUniqueSearchTextArray() -> [String] {
        
        let sortedSearchTextArray: [String] = getSortedSearchTextArray()
        var sortedSearchTextArrayWithUniqueValues: [String] = []
        
        sortedSearchTextArray.forEach { searchText in
            if !sortedSearchTextArrayWithUniqueValues.contains(searchText) {
                sortedSearchTextArrayWithUniqueValues.append(searchText)
            }
        }
        return sortedSearchTextArrayWithUniqueValues
    }
    
    func getSortedSearchTextArray() -> [String] {
        let savedSearchTextArray: [String] = getSavedSearchTextArray()
        let reversedSavedSearchTextArray: [String] = savedSearchTextArray.reversed()
        return reversedSavedSearchTextArray
    }
    func deleteAtIndex(index: Int){
        self.searchTextArray.remove(at: index)
        UserDefaults.standard.set(self.searchTextArray, forKey: savedSearchTextArrayKey)
    }
   
}
extension MainViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        switch collectionView {
        case imageCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
            cell.setup(photo: self.photos[indexPath.item])
            return cell
        case searchHistoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTextCollectionViewCell.identifier, for: indexPath) as! SearchTextCollectionViewCell
            cell.set(title: searchTextArray[indexPath.item], collectionView: collectionView, indexPath: indexPath, delegate: self)
            return cell
        default:
            return UICollectionViewCell()
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        
        switch collectionView {
        case imageCollectionView:
            return photos.count
        case searchHistoryCollectionView:
            return searchTextArray.count
        default:
            return 0
            
        }
    }
}
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout: UICollectionViewFlowLayout? = collectionViewLayout as? UICollectionViewFlowLayout
        let horizontalSpacing: CGFloat = (flowLayout?.minimumInteritemSpacing ?? 0) + collectionView.contentInset.left + collectionView.contentInset.right
        let width: CGFloat = (collectionView.frame.width - horizontalSpacing) / 2
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        switch collectionView {
        case imageCollectionView:
            let photo = self.photos[indexPath.item]
            let url = photo.src.large2X
            
            let vc = ImageScrollViewController(imageURL: url)
            self.navigationController?.pushViewController(vc, animated: true)
        case searchHistoryCollectionView:
            let searchText: String = searchTextArray[indexPath.item]
            searchBar.text = searchText
            search()
        default:
            return
            
        }
        
    }
}
extension MainViewController: SearchTextCollectionViewCellDelegate {
    func searchTextCollectionViewCell(_ collectionView: UICollectionView, deleteButtonWasTapped indexPath: IndexPath) {
        print("Delete pressed with word: \(searchTextArray[indexPath.item])")
        deleteAtIndex(index: indexPath.item)
    }
}
