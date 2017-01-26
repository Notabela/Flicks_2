//
//  AppDelegate.swift
//  Flicks_2
//
//  Created by daniel on 1/12/17.
//  Copyright © 2017 Notabela. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController!
    let globalTint = UIColor(red: 225/255, green: 214/255, blue: 43/255, alpha: 1)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let nowPlayingNavController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavController.topViewController as! MoviesViewController
        nowPlayingViewController.endPoint = "now_playing"
        nowPlayingViewController.tabBarItem.title = "Now Playing"
        nowPlayingViewController.tabBarItem.image = UIImage(named: "now_playing.png")
        
        let topRatedNavController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let topRatedViewController = topRatedNavController.topViewController as! MoviesViewController
        topRatedViewController.endPoint = "top_rated"
        topRatedViewController.tabBarItem.title = "Top Rated"
        topRatedViewController.tabBarItem.image = UIImage(named: "top_rated.png")
        
 
        tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingNavController, topRatedNavController]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().isTranslucent = true
        tabBarController.tabBar.barStyle = .black
        tabBarController.tabBar.isTranslucent = true
        tabBarController.tabBar.tintColor = globalTint
        
        return true
    }
    
    func moviesFilePath(endPoint: String) -> String
    {
        
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let filePath = paths[0].appendingPathComponent("\(endPoint)File.plist")
        return filePath.path
    }
    
    func saveMovies(_ movies: Movies, endPoint: String) -> Bool
    {
        let success = NSKeyedArchiver.archiveRootObject(movies, toFile: moviesFilePath(endPoint: endPoint))
        assert(success, "failed to write archive")
        return success
    }
    
    func readMovies(endPoint: String, completion: (_ movies: Movies?) -> Void)
    {
        let path = moviesFilePath(endPoint: endPoint)
        let unarchivedObject = NSKeyedUnarchiver.unarchiveObject(withFile: path)
        completion(unarchivedObject as? Movies)
    }


}



