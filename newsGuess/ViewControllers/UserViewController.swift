//
//  UserViewController.swift
//  newsGuess
//
//  Created by Никита Максаковский on 11.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import UIKit

/*
 добавить еще пару вещей : графики
 сортировка ячеек по значениям
 notifications
 */
class UserViewController: UIViewController {

    @IBOutlet weak var titlePhoto: UIImageView!
    @IBOutlet weak var maxrating: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var deleteUser: UIBarButtonItem!
    var userData: UserViewModel?
    
    override func viewWillAppear(_ animated: Bool) {
           configureView()
       }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        configure()
    }
    
    func commonInit() {
        titlePhoto.layer.cornerRadius = 50
        titlePhoto.clipsToBounds = true
    }
    
    func configureView() {
        navigationController?.navigationBar.topItem?.title = userData?.handle
    }
    
    func configure() {
        maxrating.text = "Макс. рейтинг: "
        rating.text = "Текущий рейтинг: "
        name.text = "Имя: "
        rank.text = "Ранг: "
        if let tmpMaxRating = userData?.maxRating {
            maxrating.text! += String(tmpMaxRating)
        } else {
            maxrating.text! += "Нет"
        }
        if let tmpRating = userData?.rating {
            rating.text! += String(tmpRating)
        } else {
            rating.text! += "Нет"
        }
        if let tmpRank = userData?.rank {
            rank.text! += String(tmpRank)
        } else {
            rank.text! += "Нет"
        }
        if let tmpFirstName = userData?.firstName {
            name.text! += tmpFirstName + " "
        }
        if let tmpLastName = userData?.lastName {
            name.text! += tmpLastName
        } else {
            if userData?.firstName == nil {
                name.text! += "Нет"
            }
        }
        
        let photo = "https:" + userData!.avatar
        if let url = URL(string: photo) {
            if let data = try? Data(contentsOf: url){
                titlePhoto.image = UIImage(data: data)
            }
        }
    }
}
