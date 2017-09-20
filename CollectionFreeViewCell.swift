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
    func moved(to index: Int)
    
}

class CollectionFreeViewCell: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var delegate: CollectionFreeViewCellDelegate?  {
        didSet {
            print("delegate is set")
        }
    }
    
    var views: [UIView] = [UIView]()
    var horizontall = false
    
    var cellCountInLine: CGFloat = 3
    
    var spaceBetweenView: CGFloat = 1
    var isPagingEnabled = false
    var isFramed: Bool = true
    var cellBackgroundColor = UIColor.red
    
    
    var _currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)
        
    var squareKoeff: CGFloat = 1
    
    fileprivate var _viewCollection: UICollectionView!
    private let _viewCellId = "viewCell"
    

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let flowLayot = UICollectionViewFlowLayout()
        
        if horizontall {
            flowLayot.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
        let margin: CGFloat = isFramed ? 8 : 0
        
        let collectionBounds = CGRect(x: self.bounds.origin.x + margin, y: self.bounds.origin.y + margin, width: self.bounds.size.width - margin*2, height: self.bounds.size.height - margin*2)
        
        _viewCollection = UICollectionView(frame: collectionBounds, collectionViewLayout: flowLayot)
        _viewCollection.backgroundColor = self.backgroundColor
        _viewCollection.isPagingEnabled = isPagingEnabled
        
        
        //register nib of cell
        _viewCollection.register(ViewCell.self, forCellWithReuseIdentifier: _viewCellId)
        
        _viewCollection.delegate = self
        _viewCollection.dataSource = self
        self.addSubview(_viewCollection)
        
    }

    func reloadData() {
        _viewCollection?.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return views.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _viewCellId, for: indexPath) as? ViewCell {
            cell.color = cellBackgroundColor
            cell.configure(view: views[indexPath.row])
            cell.delegate = self
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectedCell(by: indexPath.row)
    }
    
    
    
    //show full cell w/o frame between cells
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isPagingEnabled {
            if (scrollView == _viewCollection) {
                var currentCellOffset = _viewCollection.contentOffset
                currentCellOffset.x += _viewCollection.frame.size.width / 2;
                let indexPath = _viewCollection.indexPathForItem(at: currentCellOffset)
                _viewCollection.scrollToItem(at: indexPath!, at: .centeredHorizontally, animated: true)
                
            }
        }
        for cell in _viewCollection.visibleCells  as [UICollectionViewCell]    {
            let indexPath = _viewCollection.indexPath(for: cell as UICollectionViewCell)
            
            print(indexPath ?? "no cell")
            
            
            if indexPath != _currentIndexPath {
                _currentIndexPath = indexPath!
                delegate?.moved(to: _currentIndexPath.row)
                
            }
        }
    }
    
    
    
    func selectCell(with indexPath: IndexPath) {
        _viewCollection.scrollToItem(at: indexPath, at: .left, animated: true)
        
    }
}




extension CollectionFreeViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenView //distance between photos
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        //IN TESTING
        if isPagingEnabled {
            width = self._viewCollection.frame.width
            height = self._viewCollection.frame.height
        } else {
            width = self._viewCollection.frame.width/cellCountInLine - cellCountInLine * spaceBetweenView
            height = width * squareKoeff
        }
        return CGSize(width: width, height: height)
        
        
    }

    
    
    
    
}






extension CollectionFreeViewCell: ViewCellDelegate {
    
    func selectedCell(_ index: Int) {
        
        print("selected \(index)")
        delegate?.selectedCell(by: index)
        
    }
}


protocol ViewCellDelegate {
    func selectedCell(_ index: Int)
}


class ViewCell: UICollectionViewCell {
    
    var subview: UIView!
    var delegate: ViewCellDelegate?
    var color = UIColor.red

   
    func configure(view: UIView) {
        subview = view
        subview.frame = self.bounds
        self.backgroundColor = color
        self.addSubview(subview)
        
    }
    
   
    
    
   
}



