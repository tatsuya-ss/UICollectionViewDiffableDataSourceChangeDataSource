//
//  UIDiffableDataSourceCollectionViewCell.swift
//  UICollectionViewDiffableDataSourceChangeDataSource
//
//  Created by 坂本龍哉 on 2022/01/03.
//

import UIKit

final class UIDiffableDataSourceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var numberLabel: UILabel!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(number: Int) {
        numberLabel.text = String(number)
    }

}
