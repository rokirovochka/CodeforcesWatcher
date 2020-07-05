//
//  ImageListPresenter.swift
//  LectionUIKitTest
//
//  Created by Никита Максаковский on 10.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import Foundation
import UIKit

protocol PeopleView: class {
    func display(viewModel: [UserSectionViewModel])
    func reloadView()
}

class PeoplePresenter {
    weak private var view: PeopleView?
    
    private let codeforcesService = CodeforcesService()
    private let cacheService = CacheUserService()
    private let cacheRatingChangeService = CacheRatingChangesService()
    
    init(view: PeopleView) {
        self.view = view
    }
    
    func onViewDidLoad() {
        guard let handles = UserDefaults.standard.object(forKey: "handles") as? [String] else {
            return
        }
        presentViewModel(cellsCount: handles.count)
    }
    
    private func presentViewModel(cellsCount: Int) {
        var sections = [UserSectionViewModel]()
        
        guard let handles = UserDefaults.standard.object(forKey: "handles") as? [String] else {
            return
        }
        
        for handle in handles {
            guard let userData = loadUser(handle: handle), let userRC = loadUserRC(handle: handle) else {
                continue
            }
            
            let cell = [UserCellViewModel(userData: userData, ratingChange: userRC)]
            sections.append(UserSectionViewModel(cells: cell))
        }
        view?.display(viewModel: sections)
        view?.reloadView()
    }
    
    func addUserToWatch(handle: String?, update: Bool) {
        guard let handle = handle else {
            return
        }
        guard let tmpHandles = UserDefaults.standard.object(forKey: "handles") as? [String] else {
            return
        }
        var handles = tmpHandles
        
        if !update && handles.contains(handle) {
            return
        }
        
        codeforcesService.loadUserDataFromCloud(handle: handle) {(data) in
            guard let data = data else {
                return
            }
            
            let requestUserData = try? JSONDecoder().decode(RequestUsersProfileViewModel.self, from: data)
            if let userData = requestUserData?.result?.first {
                self.cacheService.saveUserToCache(handle: handle.lowercased(), userData: userData)
                if !update {
                    handles.append(handle.lowercased())
                    UserDefaults.standard.set(handles, forKey: "handles")
                }
                self.presentViewModel(cellsCount: handles.count)
            }
            
        }
        codeforcesService.loadUserRatingChangeFromCloud(handle: handle) {(data) in
            guard let data = data else {
                return
            }
            let requestRCData = try? JSONDecoder().decode(RequestRatingChangeViewModel.self, from: data)
            if let RCData = requestRCData?.result {
                self.cacheRatingChangeService.saveRatingChangesToCache(handle: handle.lowercased(), ratingChanges: RCData)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(15)) {
                    self.presentViewModel(cellsCount: handles.count)
                }
            }
        }
    }
    
    private func loadUser(handle: String) -> UserViewModel? {
        let data = cacheService.tryLoadUserFromCache(handle: handle)
        return data
    }
    
    private func loadUserRC(handle: String) -> [RatingChangeViewModel]? {
        let data = cacheRatingChangeService.tryLoadRatingChangesFromCache(handle: handle)
        return data
    }
}
