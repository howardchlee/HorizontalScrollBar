//
//  TastePickingScrollBar.swift
//  HorizontalScrollBar
//
//  Created by Howard Lee on 2/22/16.
//  Copyright © 2016 howardlee. All rights reserved.
//

import UIKit

// MARK: - Taste Pickable Protocol

/// Protocol for a model that can be placed into taste picking scroll bar
public protocol TastePickable {
    var displayImage: UIImage { get }
}

// MARK: - Circular Image Collection View Cell

public class CircularImageCollectionViewCell: UICollectionViewCell {
    // MARK: Public properties
    public var image: UIImage? = nil {
        didSet {
            imageView?.image = image
        }
    }
    
    // MARK: Private properties
    @IBOutlet var imageView: UIImageView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        if imageView == nil {
            imageView = UIImageView(frame: contentView.frame)
            contentView.addSubview(imageView)

            let views = ["imageView": imageView]
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[imageView]", options: [], metrics: nil, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: [], metrics: nil, views: views))
        }
    }
    
    // MARK: Layout methods
    override public func prepareForReuse() {
        imageView?.image = nil
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalInRect: bounds).CGPath
        imageView.layer.mask = mask
    }
}

// Mark: - Taste Picking Scroll Bar Flow Layout

/** Custom flow layout for the taste picking scroll bar.  This scroll bar does several things:
    - Defaults the scroll direction to horizontal
    - Scrolls the collection view to the last item after an insert
    - Custom appearance / disappearance animation using Affine Transformation
*/
public class TastePickingScrollBarFlowLayout: UICollectionViewFlowLayout {
    var insertedIndexPath:NSIndexPath?
    
    public override init() {
        super.init()
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        scrollDirection = .Horizontal
    }
    
    override public func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
        attributes?.transform = CGAffineTransformMakeScale(0.1, 0.1)
        attributes?.alpha = 1.0
        if itemIndexPath.item > 0 {
            if attributes?.frame.maxX > collectionView?.bounds.maxX {
                attributes?.frame = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: itemIndexPath.row - 1, inSection: 0))!.frame
            }
        }
        return attributes
    }
    
    override public func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        super.prepareForCollectionViewUpdates(updateItems)
        
        let insertedIndexPaths = updateItems.filter({ (item) -> Bool in
            return item.updateAction == .Insert
        })
        insertedIndexPath = insertedIndexPaths.maxElement { (leftItem, rightItem) -> Bool in
            return leftItem.indexPathAfterUpdate!.row > rightItem.indexPathAfterUpdate!.row
            }?.indexPathAfterUpdate
    }
    
    override public func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        guard let insertedIndexPath = insertedIndexPath else { return }
        collectionView?.scrollToItemAtIndexPath(insertedIndexPath, atScrollPosition: .Right, animated: true)
        self.insertedIndexPath = nil
    }
}

public class TastePickingScrollBar: UICollectionView {

    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        collectionViewLayout = TastePickingScrollBarFlowLayout()
        registerClass(CircularImageCollectionViewCell.self, forCellWithReuseIdentifier: "circularCell")
    }
}