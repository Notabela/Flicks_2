//
//  DetailsViewController.swift
//  Flicks_2
//
//  Created by daniel on 1/12/17.
//  Copyright © 2017 Notabela. All rights reserved.
//

import UIKit
import AFNetworking

class DetailsViewController: UIViewController
{
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var movieDetails: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    
    @IBOutlet var noInternetView: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var movieItem: MovieItem!
    let reachability = Reachability()!
    var originalCenter: CGPoint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupPosterView()
        addNoInternetView()
        
        detailsView.layer.cornerRadius = 10
        movieTitle.text = movieItem.title
        movieDetails.text = movieItem.overview
        
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(onPanDetailsView(_:)))
        detailsView.addGestureRecognizer(panRecognizer)
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
    
    func onPanDetailsView(_ sender: UIPanGestureRecognizer)
    {
        //let location = sender.location(in: self.view)
        let translation = sender.translation(in: self.view)
        //let velocity = sender.velocity(in: self.view)

        if sender.state == UIGestureRecognizerState.began
        {
            originalCenter = detailsView.center
        }
        else if sender.state == UIGestureRecognizerState.changed
        {
            var center = originalCenter
            center?.y += translation.y
            
            let customTabBar = (UIApplication.shared.delegate as? AppDelegate)?.tabBarController
            let minCenterY = (navigationController?.navigationBar.frame.height)! + detailsView.frame.height/2 + 50
            let maxCenterY = self.view.frame.height - (customTabBar?.tabBar.frame.height)! - 70 + detailsView.frame.height/2
            
            center?.y = (center?.y)! < minCenterY ? minCenterY : (center?.y)!
            center?.y = (center?.y)! > maxCenterY ? maxCenterY : (center?.y)!
            
            detailsView.center = center!
        }

    }
    
    //MARK: Private Functions
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
            print("reachable")
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

    func setupPosterView()
    {
        let smallImageRequest = URLRequest(url: movieItem.lowPosterUrl)
        let largeImageRequest = URLRequest(url: movieItem.highPosterUrl)
        
        posterView.setImageWith(smallImageRequest, placeholderImage: nil, success: {
            
            (smallImageRequest, smallImageResponse, smallImage) -> Void in
            
            self.posterView.alpha = 0.0
            self.posterView.image = smallImage;
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                
                self.posterView.alpha = 1.0
                
            }, completion: { (sucess) -> Void in
                
                self.posterView.setImageWith(largeImageRequest, placeholderImage: smallImage, success:{
                    
                    (largeImageRequest, largeImageResponse, largeImage) -> Void in
                    
                    self.posterView.image = largeImage;
                    
                }, failure: nil)
            })
        }, failure: nil)

    }

}
