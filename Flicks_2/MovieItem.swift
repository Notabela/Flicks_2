//
//  MovieItem.swift
//  Flicks_2
//
//  Created by daniel on 1/13/17.
//  Copyright © 2017 Notabela. All rights reserved.
//

import Foundation

class MovieItem: NSObject, NSCoding
{
    let title: String
    let overview: String
    let rawReleaseDate: String
    let releaseDate: String?
    let rating: Double?
    let posterPath: String
    
    let highPosterString: String
    let defaultPosterString: String
    let lowPosterString: String

    var highPosterUrl: URL { return URL(string: highPosterString)! }
    var defaultPosterUrl: URL { return URL(string: defaultPosterString)! }
    var lowPosterUrl: URL { return URL(string: lowPosterString)! }
    
    init(_ movie: Dictionary<String, AnyObject>)
    {
        title = movie["original_title"] as! String
        overview = movie["overview"] as! String
        posterPath = movie["poster_path"] as! String
        rawReleaseDate = movie["release_date"] as! String
        defaultPosterString = "https://image.tmdb.org/t/p/w342\(posterPath)"
        lowPosterString = "https://image.tmdb.org/t/p/w45\(posterPath)"
        highPosterString = "https://image.tmdb.org/t/p/original\(posterPath)"
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let date = format.date(from: rawReleaseDate)
        format.dateFormat = "MMMM dd, yyyy"
        releaseDate = format.string(from: date!)
        
        rating = movie["vote_average"] as? Double
    }
    
    func encode(with aCoder: NSCoder)
    {
        var dictToStore: Dictionary<String, AnyObject> = [:]
        dictToStore["original_title"] = self.title as AnyObject?
        dictToStore["overview"] = self.overview as AnyObject?
        dictToStore["poster_path"] = self.posterPath as AnyObject?
        dictToStore["release_date"] = self.rawReleaseDate as AnyObject?
        dictToStore["rating"] = (self.rating ?? nil) as AnyObject?
        
        aCoder.encode(dictToStore, forKey: "feedDict")
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        let dict = aDecoder.decodeObject(forKey: "feedDict") as? Dictionary<String, AnyObject>
        
        guard dict != nil else
        {
            return nil
        }
        
        self.init(dict!)
    }
}
