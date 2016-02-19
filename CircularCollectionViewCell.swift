//
//  CircularCollectionViewCell.swift
//  i2
//
//  Created by Howard Lee on 2/18/16.
//  Copyright © 2016 Hulu, LLC. All rights reserved.
//

import UIKit

public class CircularCollectionViewCell: UICollectionViewCell {
    // MARK: - Public properties
    public var image: UIImage? = nil {
        didSet {
            imageView?.image = image
        }
    }
    
    // MARK: Private properties
    @IBOutlet weak var imageView: UIImageView!
    
    
    public func animateInsert() {
        if let imageView = imageView {
            imageView.transform = CGAffineTransformMakeScale(0.1, 0.1)
            imageView.contentMode = .ScaleAspectFill
            
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(ovalInRect: imageView.bounds).CGPath
            imageView.layer.mask = mask
            
            UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                imageView.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
}
