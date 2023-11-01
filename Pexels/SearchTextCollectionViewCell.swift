//
//  SearchTextCollectionViewCell.swift
//  Pexels
//
//  Created by Айбану Уатбаева on 21.10.2023.
//

import UIKit

protocol SearchTextCollectionViewCellDelegate {
    func searchTextCollectionViewCell(_ collectionView: UICollectionView, deleteButtonWasTapped indexPath: IndexPath)
}
class SearchTextCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "SearchTextCollectionViewCell"
    
    var delegate: SearchTextCollectionViewCellDelegate?
    var collectionView: UICollectionView?
    var indexPath: IndexPath?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 10
        
    }
    func set(title: String, collectionView: UICollectionView, indexPath: IndexPath, delegate: SearchTextCollectionViewCellDelegate){
        titleLabel.text = title
        self.indexPath = indexPath
        self.collectionView = collectionView
        self.delegate = delegate
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
       // let searchText: String = titleLabel.text!
        bounce(button: sender as! UIButton){
            print("Button pressed")
            guard let indexPath = self.indexPath, let collectionView = self.collectionView else {
                return
            }
            
            self.delegate?.searchTextCollectionViewCell(collectionView, deleteButtonWasTapped: indexPath)
        }
        
        
    }
    func bounce(button: UIButton, completion: @escaping (()->())) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    button.transform = CGAffineTransform.identity
                } completion: { completed in
                    if completed {
                        completion()
                    }
                }
            }
        )
    }
}
