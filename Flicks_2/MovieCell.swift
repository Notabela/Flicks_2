//
//  MovieCell.swift
//  Flicks_2
//
//  Created by daniel on 1/12/17.
//  Copyright © 2017 Notabela. All rights reserved.
//

import UIKit
import AFNetworking

class MovieCell: UICollectionViewCell
{

    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var posterLabel: UILabel!
    
    var movieItem: MovieItem!
    {
        didSet
        {
            posterLabel.text = movieItem.title
            
            let imageRequest = URLRequest(url: movieItem.defaultPosterUrl)
            
            self.posterView.setImageWith(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                
                    if imageResponse != nil
                    {
                        self.posterView.alpha = 0.0
                        self.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.posterView.alpha = 1.0
                        })
                    }
                    else {
                        
                        self.posterView.image = image
                    }
            }, failure: nil)
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        posterLabel.sizeToFit()
        posterLabel.preferredMaxLayoutWidth = posterLabel.frame.size.width
    }

}
