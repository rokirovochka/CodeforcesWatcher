//
//  UserViewModel.swift
//  newsGuess
//
//  Created by Никита Максаковский on 11.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import Foundation

struct UserCellViewModel {
    let userData: UserViewModel
    let ratingChange: [RatingChangeViewModel]
}

struct UserSectionViewModel {
    var cells: [UserCellViewModel]
}

struct RequestUsersProfileViewModel: Decodable {
    let status: String
    var result: [UserViewModel]?
}

struct UserViewModel: Decodable, Encodable {
    let lastName: String?
    let firstName: String?
    let rating: Int?
    let avatar: String
    let handle: String
    let maxRating: Int?
    let rank: String?
}



