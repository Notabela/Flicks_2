//
//  ViewController.swift
//  Flicks_2
//
//  Created by daniel on 1/12/17.
//  Copyright © 2017 Notabela. All rights reserved.
//

import UIKit
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating
{

    @IBOutlet weak var movieFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet var noInternetView: UIView!

    var searchController: UISearchController!
    var isLoadingMoreData: Bool!
    var endPoint: String!
    var movies: Movies!
    var filteredMovies: Movies!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let reachability = Reachability()!
    var isShowingNoInternetView = false
       
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        addNoInternetView()
        setupCollectionView()
        setupSearchController()
        setupRefreshControl()
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }

    //MARK: Collection View Functions
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = movieCollectionView.dequeueReusableCell(withReuseIdentifier: "com.Notabela.movieCell", for: indexPath) as! MovieCell
        
        cell.movieItem = filteredMovies[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return filteredMovies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "detailsSegue", sender: collectionView.cellForItem(at: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = CGFloat(movieCollectionView.bounds.size.width/3.0)
        let height = CGFloat(movieCollectionView.bounds.size.width/2.0)
        
        return CGSize(width: width, height: height)
    }
    
    //MARK: Segue Function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "detailsSegue")
        {
            let destVc = segue.destination as! DetailsViewController
            let cell = sender as! UICollectionViewCell
            let indexPath = movieCollectionView.indexPath(for: cell)!
            destVc.movieItem = filteredMovies?[indexPath.row]
        }
    }
    
    //MARK: SearchBar Functions
    func updateSearchResults(for searchController: UISearchController)
    {
        if let searchText = searchController.searchBar.text
        {
            filteredMovies = searchText.isEmpty ? Movies(movies.movieItems, from: endPoint) : Movies(movies.movieItems.filter({
                (movie: MovieItem) -> Bool in
                    return (movie.title).range(of: searchText, options: .caseInsensitive) != nil
            }), from: endPoint)
            
            movieCollectionView.reloadData()
        }
    }
    
    func setupSearchController()
    {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barStyle = .black
        searchController.searchBar.isTranslucent = true
        
        searchController.searchBar.placeholder = "Search Here"
    }
    
    func setupCollectionView()
    {
        movieCollectionView.register(UINib(nibName: "MovieCell", bundle: nil), forCellWithReuseIdentifier: "com.Notabela.movieCell")
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        movieFlowLayout.scrollDirection = .vertical
        movieFlowLayout.minimumLineSpacing = 0
        movieFlowLayout.minimumInteritemSpacing = 0
        movieFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func setupRefreshControl()
    {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "pull to refresh", attributes: [NSForegroundColorAttributeName : UIColor.white])
        refreshControl.backgroundColor = UIColor.darkGray
        refreshControl.tintColor = appDelegate.globalTint
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        movieCollectionView.insertSubview(refreshControl, aboveSubview: movieCollectionView)
    }
    
    func refreshControlAction(_ sender: UIRefreshControl)
    {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: request)
        {
            (data, response, error) in
            
            OperationQueue.main.addOperation
            {
                    if error == nil && data != nil
                    {
                        self.movies = Movies(data: data!, from: self.endPoint)
                        self.filteredMovies = Movies(self.movies.movieItems, from: self.endPoint)
                        
                        sender.endRefreshing()
                        self.movieCollectionView.reloadData()
                        
                    }
            }
        }
        task.resume()
    }
    
    func addNoInternetView()
    {
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noInternetView)
        let bottomConstraint = noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -appDelegate.tabBarController.tabBar.frame.height)
        let leftConstraint = noInternetView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = noInternetView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let heightConstraint = noInternetView.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        view.layoutIfNeeded()
        
        noInternetView.isHidden = true
    }
    
    func reachabilityChanged(note: NSNotification)
    {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable
        {
            print("is reachable")
            if !self.noInternetView.isHidden
            {
                self.noInternetView.isHidden = true
            }
            
        } else {
            
            print("Network not reachable")
            if self.noInternetView.isHidden
            {
                self.noInternetView.isHidden = false
            }
        }
    }

    func getData()
    {
        let lastUpdate = UserDefaults.standard.object(forKey: "\(endPoint!)moviesCached") as? Date
        
        if lastUpdate != nil && Date().timeIntervalSince(lastUpdate!) < TimeInterval(18000) /* 5 hours */
        {
            var wasLoadedFromCache = false
            self.appDelegate.readMovies(endPoint: endPoint)
            {
                (movies: Movies?) in
                
                if let movieData = movies
                {
                    print("\(self.endPoint!) was loaded from cache")
                    self.movies = movieData
                    self.filteredMovies = movieData
                    wasLoadedFromCache = true
                    self.movieCollectionView.reloadData()
                }
            }
            
            if wasLoadedFromCache { return }
        }
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        
        let progressBar = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressBar.tintColor = appDelegate.globalTint
        
        let task = URLSession.shared.dataTask(with: request)
        {
            (data, response, error) in
            
            OperationQueue.main.addOperation
            {
                if error == nil && data != nil
                {
                    print("movie was retrieved from API")
                    
                    self.movies = Movies(data: data!, from: self.endPoint)
                    self.filteredMovies = Movies(self.movies.movieItems, from: self.endPoint)
                    
                    if self.appDelegate.saveMovies(self.movies, endPoint: self.endPoint)
                    {
                        let now = Date()
                        UserDefaults.standard.set(now, forKey: "\(self.endPoint!)moviesCached")
                        print("\(self.endPoint!) movies was saved")
                    }
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.movieCollectionView.reloadData()
                    
                }
            }
        }
        task.resume()
    }
}

