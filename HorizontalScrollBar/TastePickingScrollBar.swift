//
//  TastePickingScrollBar.swift
//  HorizontalScrollBar
//
//  Created by Howard Lee on 2/22/16.
//  Copyright © 2016 howardlee. All rights reserved.
//

import UIKit

// MARK: - Circular Image Collection View Cell

/// The cell type used in Tast Picking horizontal scroll bar
public class CircularImageCollectionViewCell: UICollectionViewCell {
    // MARK: Public properties

    /// the image to be displayed in the collection view cell.
    public var image: UIImage? = nil {
        didSet {
            imageView?.image = image
        }
    }
    
    // MARK: Private properties
    @IBOutlet var imageView: UIImageView!
    
    // MARK: Init Methods
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

// MARK: - Circular Dotted Decoration View

public class CircularDottedDecorationView: UICollectionReusableView {
    override public func layoutSubviews() {
        super.layoutSubviews()
        let circleLayer = CAShapeLayer()
        layer.addSublayer(circleLayer)

        let path = UIBezierPath(ovalInRect: bounds)
        let dashes: [CGFloat] = [12]
        circleLayer.path = path.CGPath
        circleLayer.lineDashPattern = dashes
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.lineWidth = 2
        circleLayer.strokeColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1).CGColor
    }
}

// MARK: - Taste Picking Scroll Bar Flow Layout

/** Custom flow layout for the taste picking scroll bar.  This scroll bar does several things:
    - Defaults the scroll direction to horizontal
    - Scrolls the collection view to the last item after an insert
    - Custom appearance / disappearance animation using Affine Transformation. The collection view can use
      UIView.animateWithDuration to configure the actual speed / delay / damping of the animation
    - Custom placeholder dotted circles
*/
public class TastePickingScrollBarFlowLayout: UICollectionViewFlowLayout {

    /// Specifies the number of placeholder dotted circles needed for the view
    public var dottedCircleCount = 5
    
    /// Specifies whether the current update operation is an insert
    var inserting = false
    
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
        registerClass(CircularDottedDecorationView.self, forDecorationViewOfKind: "dottedCircle")
    }
    
    override public func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
        if inserting {
            attributes?.transform = CGAffineTransformMakeScale(0.1, 0.1)
            attributes?.alpha = 1.0
            if itemIndexPath.item > 0 {
                // if the new item is going to appear outside the bounds of the collection view, we preset its frame to the last time
                // so it would be created before the scroll view starts the scroll.
                if attributes?.frame.maxX > collectionView?.bounds.maxX {
                    attributes?.frame = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: itemIndexPath.row - 1, inSection: 0))!.frame
                }
            }
        }
        return attributes
    }
    
    override public func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)
        attributes?.transform = CGAffineTransformMakeScale(0.1, 0.1)
        attributes?.alpha = 0
        return attributes
    }
    
    override public func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        assert(updateItems.count == 1, "Taste Picking scroll bar can only handle one update operation at a time!")
        super.prepareForCollectionViewUpdates(updateItems)
        
        let updateItem = updateItems.first!
        if updateItem.updateAction == .Insert {
            inserting = true
        } else {
            inserting = false
        }
    }
    
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attrs = super.layoutAttributesForElementsInRect(rect) else { return nil }
        var decorationViewAttrs: [UICollectionViewLayoutAttributes] = []
        
        // draw the dotted circles by pre-calculating where the cells would be.
        for var i = 0; i < dottedCircleCount; i++ {
            let attr = UICollectionViewLayoutAttributes(forDecorationViewOfKind: "dottedCircle", withIndexPath: NSIndexPath(forItem: i, inSection: 0))
            let x = CGFloat(i) * (itemSize.width + minimumInteritemSpacing)
            let h = itemSize.height
            attr.frame = CGRectMake(x, 0, h, h)
            decorationViewAttrs.append(attr)
        }
        
        return attrs + decorationViewAttrs
    }
    
    override public func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        if inserting == true {
            let indexPath = NSIndexPath(forItem: collectionView!.numberOfItemsInSection(0) - 1, inSection: 0)
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Right, animated: true)
        }
    }
}

// MARK: - Taste Picking Scroll Bar

public class TastePickingScrollBar: UICollectionView {
    
    let CircularImageCellReuseIdentifier = "CircularImageCellReuseIdentifier"
    
    public var dottedCircleCount = 5

    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let layout = TastePickingScrollBarFlowLayout()
        layout.dottedCircleCount = dottedCircleCount
        collectionViewLayout = layout
        showsHorizontalScrollIndicator = false
        registerClass(CircularImageCollectionViewCell.self, forCellWithReuseIdentifier: CircularImageCellReuseIdentifier)
    }
    
    // Override insert animation so the insert animation is a spring animation
    override public func insertItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1, options: [], animations: { () -> Void in
            super.insertItemsAtIndexPaths(indexPaths)
            }, completion: nil)
    }
    
    // Convenience method for dequeuing a circular cell
    public func dequeueCircularImageCellForIndexPath(indexPath: NSIndexPath) -> CircularImageCollectionViewCell {
        return dequeueReusableCellWithReuseIdentifier(CircularImageCellReuseIdentifier, forIndexPath: indexPath) as! CircularImageCollectionViewCell
    }
}