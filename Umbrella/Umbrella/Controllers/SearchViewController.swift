//
//  ViewController4.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//


import UIKit
import MapKit



class SearchViewController:UIViewController {
    
    
   //MARK: - Properties
   
    var lat:String?
    var lon:String?
    

    
    
    var searchController: UISearchController!
    
    
    private let backgroundView:UIView = {
        
        let view = UIView()
        
        return view
        
        
    }()

    
    private let searchResultTable = UITableView()
        
       
   
    private let searchBar = UISearchBar()
        
       
  
    
    var searchRegion : String?
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configUI()
        initSearchBar()
        self.alert("지금버전은 검색지역 온도만 확인가능합니다")
    }
    
    //MARK: - Functions
    
    fileprivate func initSearchBar(){
        let controller = SearchController()
        controller.delegate = self
        
        searchController = UISearchController(searchResultsController: controller)
        searchController.searchResultsUpdater = controller
        
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "도시 또는 공항 검색"
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        backgroundView.addSubview(searchBar)
    }
    
    func configUI() {
        
        view.backgroundColor = .white
        
     
        view.addSubview(backgroundView)
        backgroundView.anchor(top: view.topAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 50,paddingLeft: 0,paddingBottom: 680,paddingRight: 0)
        backgroundView.backgroundColor = .white
        
        
    }
    
    
    //MARK: - Actions
    
}

extension SearchViewController: SearchResultDelegate {
    func foundResult(mapItem: MKMapItem) {
        let locality = mapItem.placemark.locality ?? " "
        let country = mapItem.placemark.country ?? " "
        let latitude: String = "\(mapItem.placemark.coordinate.latitude)"
        let longitude: String = "\(mapItem.placemark.coordinate.longitude)"
        let mapItemArray: [String] = [locality, country, latitude, longitude]
        

        dismiss(animated: true)
        
 
        NotificationCenter.default.post(name: NSNotification.Name("test"), object: mapItemArray)
        
        
        searchController.searchBar.text = ""
    }
}



extension SearchViewController {
    func alert(_ message: String, completion: (()->Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                completion?()
            }
            alert.addAction(okAction)
            self.present(alert, animated: false)
        }
    }
}
