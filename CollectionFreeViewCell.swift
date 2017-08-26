//
//  PhotoCollectionFreeView.swift
//  Cardee
//
//  Created by Leonid Nifantyev on 8/2/17.
//  Copyright © 2017 Alexander Lisovik. All rights reserved.
//

import Foundation
import UIKit

protocol CollectionFreeViewCellDelegate {
    func selectedCell(by index: Int)
}

class CollectionFreeViewCell: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var views: [UIView] = [UIView()]
    var horizontall = false
    var delegate: CollectionFreeViewCellDelegate?
    
    var cellCountInLine: CGFloat = 3
    var spaceBetweenView: CGFloat = 1
    
    var squareKoeff: CGFloat = 1
    private var _viewCollection: UICollectionView!
    private let _viewCellId = "viewCell"
    
    
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let flowLayot = UICollectionViewFlowLayout()
        
        
        if horizontall {
            
            flowLayot.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
        
        let collectionBounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width, height: self.bounds.size.height)
        
        _viewCollection = UICollectionView(frame: collectionBounds, collectionViewLayout: flowLayot)
        _viewCollection.backgroundColor = self.backgroundColor
        
        
        //register nib of cell
        _viewCollection.register(ViewCell.self, forCellWithReuseIdentifier: _viewCellId)
        
        _viewCollection.delegate = self
        _viewCollection.dataSource = self
        self.addSubview(_viewCollection)
        
    }

    func reloadData() {
        _viewCollection.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return views.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _viewCellId, for: indexPath) as? ViewCell {
        
        
            cell.configure(view: views[indexPath.row])
            cell.delegate = self
        
            
            return cell
        }
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectedCell(by: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenView //distance between photos
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = horizontall ? self._viewCollection.frame.height/squareKoeff : self._viewCollection.frame.width/cellCountInLine - CGFloat(views.count) * spaceBetweenView
        
        return CGSize(width: width, height: width * squareKoeff)
        

    }
    
    func selectCell(with indexPath: IndexPath) {
        
        _viewCollection.scrollToItem(at: indexPath, at: .left, animated: true)
        //delegate?.selectedCell(by: indexPath.row)
        
    }
    
    
}


extension CollectionFreeViewCell: ViewCellDelegate {
    
    func selectedCell(_ index: Int) {
        
        print("selected \(index)")
        if let delegate = delegate {
            delegate.selectedCell(by: index)
        }
    }
}


protocol ViewCellDelegate {
    func selectedCell(_ index: Int)
}


class ViewCell: UICollectionViewCell {
    
    var subview: UIView!
    
    var delegate: ViewCellDelegate?


    
    
   
    func configure(view: UIView) {
        subview = view
        subview.frame = self.bounds
        self.backgroundColor = .red
        self.addSubview(subview)
    }
    
    
   
}



