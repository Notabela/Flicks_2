//
//  Movie.swift
//  Flicks_2
//
//  Created by daniel on 1/13/17.
//  Copyright © 2017 Notabela. All rights reserved.
//

import Foundation

class Movies: NSObject, NSCoding
{
    let movieItems: [MovieItem]
    let endPoint: String
    
    var count: Int? { return movieItems.count }
    
    init(_ movies: [MovieItem], from endPoint: String)
    {
        movieItems = movies
        self.endPoint = endPoint
    }
    
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.movieItems, forKey: "movieItems")
        aCoder.encode(self.endPoint, forKey: "endPoint")
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        let storedItems = aDecoder.decodeObject(forKey: "movieItems") as? [MovieItem]
        let storedEndpoint = aDecoder.decodeObject(forKey: "endPoint") as? String
        
        guard storedItems != nil && storedEndpoint != nil else
        {
            return nil
        }
        
        self.init(storedItems!, from: storedEndpoint!)
    }
    
    convenience init?(data: Data, from endPoint: String)
    {
        var jsonObject: Dictionary<String, AnyObject>?
        var movieItems: [MovieItem] = []
        
        do
        {
        jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>
        } catch {
            
            return nil
        }
        
        guard let movies = jsonObject?["results"] as? Array<AnyObject> else {
            return nil
        }
        
        
        for movie in movies
        {
            let movieItem = MovieItem(movie as! Dictionary<String, AnyObject>)
            movieItems.append(movieItem)
        }
        
        self.init(movieItems, from: endPoint)
    }
    
    subscript(index: Int) -> MovieItem?
    {
        guard index < movieItems.count else {
            return nil
        }
        
        return movieItems[index]
    }
}
