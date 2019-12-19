//
//  ImageListPresenter.swift
//  LectionUIKitTest
//
//  Created by Никита Максаковский on 10.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import Foundation
import UIKit

protocol ContestsView: class {
    func display(viewModel: [ContestSectionViewModel])
    func reloadView()
}

class ContestsPresenter {
    weak private var view: ContestsView?
    
    private let codeforcesService = CodeforcesService()
    private let cacheService = CacheContestsService()
    
    
    init(view: ContestsView) {
        self.view = view
    }
    
    func onViewDidLoad() {
        presentViewModel()
    }
    
    private func presentViewModel() {
        var sections = [ContestSectionViewModel]()
        guard let contests = loadContests() else {
            return
        }
        for contest in contests {
            if contest.phase != "BEFORE" {
                continue
            }
            let cell = [ContestCellViewModel(contests: contest)]
            sections.append(ContestSectionViewModel(cells: cell))
        }
        sections.reverse()
        view?.display(viewModel: sections)
        view?.reloadView()
    }
    func update() {
        presentViewModel()
    }
    
    private func loadContests() -> [ContestViewModel]? {
        if let contests = cacheService.tryLoadContestsFromCache() {
            return contests
        }
        
        codeforcesService.loadContestsFromCloud {(data) in
            guard let data = data else {
                return
            }
            let requestData = try? JSONDecoder().decode(RequestContestsViewModel.self, from: data)
            guard let contests = requestData?.result else {
                return
            }
            self.cacheService.saveContestsToCache(contestsData: contests)
            self.presentViewModel()
        }
        return nil
    }
}


