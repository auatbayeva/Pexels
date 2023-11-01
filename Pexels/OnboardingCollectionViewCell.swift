//
//  OnboardingCollectionViewCell.swift
//  Pexels
//
//  Created by Айбану Уатбаева on 06.10.2023.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "OnboardingCollectionViewCell"
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var innerStackView: UIStackView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(onboardingModel: OnboardingModel){
        imageView.image = UIImage(named: onboardingModel.imageName)
        titleLabel.text = onboardingModel.title
        subtitleLabel.text = onboardingModel.subtitle
    }
}
