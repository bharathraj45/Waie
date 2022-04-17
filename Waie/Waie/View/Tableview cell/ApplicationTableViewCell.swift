//
//  ApplicationTableViewCell.swift
//  Waie
//
//  Created by Bharath Raj Venkatesh on 17/04/22.
//

import UIKit

class ApplicationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var appImageView: UIImageView!
    
    static let identifier = "ApplicationTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ApplicationTableViewCell",
                     bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.appImageView.image = nil
    }
    
    func populate(applicationCellViewModel: ApplicationCellViewModel) {
        titleLabel.text = applicationCellViewModel.title
        descriptionLabel.text = applicationCellViewModel.explanation
        
        if let url = URL(string: applicationCellViewModel.url) {
            appImageView.loadImage(from: url)
        }
    }
}
