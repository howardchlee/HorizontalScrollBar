//
//  ViewController.swift
//  HorizontalScrollBar
//
//  Created by Howard Lee on 2/18/16.
//  Copyright © 2016 howardlee. All rights reserved.
//

import UIKit

public class ViewController: UIViewController {

    @IBOutlet weak var horizontalCollectionView: TastePickingScrollBar!

    private var selectedItems: [UIImage] = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.delegate = self
        let layout = horizontalCollectionView.collectionViewLayout as! TastePickingScrollBarFlowLayout
        let height = horizontalCollectionView.bounds.height
        layout.itemSize = CGSizeMake(height, height)
        horizontalCollectionView.collectionViewLayout = layout
    }

    @IBAction func buttonTapped(sender: UIButton) {
        if let image = sender.imageView?.image {
            if selectedItems.contains(image) {
                let index = selectedItems.indexOf(image)!
                selectedItems.removeAtIndex(index)
                horizontalCollectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
            } else {
                let newIndexPath = NSIndexPath(forItem: selectedItems.count, inSection: 0)
                selectedItems.append(image)
                self.horizontalCollectionView.insertItemsAtIndexPaths([newIndexPath])
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedItems.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = horizontalCollectionView.dequeueCircularImageCellForIndexPath(indexPath)
        cell.image = self.selectedItems[indexPath.item]
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedItems.removeAtIndex(indexPath.item)
        horizontalCollectionView.deleteItemsAtIndexPaths([indexPath]);
    }
}