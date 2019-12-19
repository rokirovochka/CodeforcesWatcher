//
//  UserViewController.swift
//  newsGuess
//
//  Created by Никита Максаковский on 11.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var titlePhoto: UIImageView!
    @IBOutlet weak var maxrating: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var deleteUser: UIBarButtonItem!
    var userData: UserViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        configureViews()
        configure()
    }
    
    private func commonInit() {
        titlePhoto.layer.cornerRadius = 50
        titlePhoto.clipsToBounds = true
    }
    
    private func configureViews() {
        title = userData?.handle
        let backButton = UIBarButtonItem(
              title: "",
              style: .plain,
              target: nil,
              action: nil
        )
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func configure() {
        maxrating.text = "Макс. рейтинг: "
        rating.text = "Текущий рейтинг: "
        name.text = "Имя: "
        rank.text = "Ранг: "
        if let tmpMaxRating = userData?.maxRating {
            maxrating.text! += String(tmpMaxRating)
        } else {
            maxrating.text! += Constants.noInfo
        }
        if let tmpRating = userData?.rating {
            rating.text! += String(tmpRating)
        } else {
            rating.text! += Constants.noInfo
        }
        if let tmpRank = userData?.rank {
            rank.text! += String(tmpRank)
        } else {
            rank.text! += Constants.noInfo
        }
        if let tmpFirstName = userData?.firstName {
            name.text! += tmpFirstName + " "
        }
        if let tmpLastName = userData?.lastName {
            name.text! += tmpLastName
        } else {
            if userData?.firstName == nil {
                name.text! += Constants.noInfo
            }
        }
        guard let avatarUrlPath = userData?.avatar else {
            return
        }
        
        DispatchQueue.main.async {
            let photo = "https:" + avatarUrlPath
            if let url = URL(string: photo) {
                if let data = try? Data(contentsOf: url){
                    self.titlePhoto.image = UIImage(data: data)
                }
            }
        }
    }
}
