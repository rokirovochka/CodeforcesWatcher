//
//  ContestsViewModel.swift
//  newsGuess
//
//  Created by Никита Максаковский on 16.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import Foundation

struct ContestCellViewModel {
    let contests: ContestViewModel
}

struct ContestSectionViewModel {
    var cells: [ContestCellViewModel]
}

struct RequestContestsViewModel: Decodable {
    let status: String
    let result: [ContestViewModel]
}

struct ContestViewModel: Decodable, Encodable {
    let name: String
    let phase: String
    let startTimeSeconds: Double?
    let id: Int64
}

struct RequestRatingChangeViewModel: Decodable {
    let status: String
    let result: [RatingChangeViewModel]?
}

struct RatingChangeViewModel: Decodable, Encodable {
    let contestId: Int64
    let contestName: String
    let handle: String
    let ratingUpdateTimeSeconds: Double
    let oldRating: Int
    let newRating: Int
}
