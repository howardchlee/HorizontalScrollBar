//
//  ViewController.swift
//  HorizontalScrollBar
//
//  Created by Howard Lee on 2/18/16.
//  Copyright © 2016 howardlee. All rights reserved.
//

import UIKit

public class ViewController: UIViewController {

    @IBOutlet weak var horizontalCollectionView: UICollectionView!
    
    private var selectedItems: [UIImage] = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        horizontalCollectionView.dataSource = self
    }

    @IBAction func buttonTapped(sender: UIButton) {
        if let image = sender.imageView?.image {
            selectedItems.append(image)
//            horizontalCollectionView.reloadData()
            UIView.setAnimationsEnabled(false)
            horizontalCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: selectedItems.count - 1, inSection: 0)])
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedItems.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = horizontalCollectionView.dequeueReusableCellWithReuseIdentifier("circularCell", forIndexPath: indexPath) as! CircularCollectionViewCell
        cell.image = selectedItems[indexPath.item]
        UIView.setAnimationsEnabled(true)
        cell.animateInsert()
        return cell
    }
}

