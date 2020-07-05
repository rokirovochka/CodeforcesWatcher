//
//  ApiService.swift
//  newsGuess
//
//  Created by Никита Максаковский on 10.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import Foundation

class CodeforcesService {
    private let urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    
    func loadContestsFromCloud(completion: @escaping (Data?) -> ()) {
        guard let contestsUrlPath = UserDefaults.standard.string(forKey: "contestsUrl") else {
            print("Contests url path error in load contests")
            return
        }
        guard let url = URL(string: contestsUrlPath) else {
            print("Url error in load contests")
            return
        }
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    func loadUserDataFromCloud(handle: String?, completion: @escaping (Data?) -> ()) {
        guard let handle = handle else {
            return 
        }
        guard let userDataUrlPath = UserDefaults.standard.string(forKey: "userDataUrl") else {
            print("User data url path error in load user")
            return
        }
        guard let url = URL(string: userDataUrlPath + handle.replacingOccurrences(of: " ", with: "")) else {
            print("Url error in load user")
            return
        }
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    func loadUserRatingChangeFromCloud(handle: String?, completion: @escaping (Data?) -> ()) {
        guard let handle = handle else {
            return
        }
        guard let ratingChangeUrlPath = UserDefaults.standard.string(forKey: "ratingChange") else {
            print("Rating change url path error in load user")
            return
        }
        guard let url = URL(string: ratingChangeUrlPath + handle.replacingOccurrences(of: " ", with: "")) else {
            print("Url error in load rating change")
            return
        }
        let task = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
}

class CacheUserService {
    private func setupUserCache() -> URL {
        let fileManager = FileManager.default
        var cachesDir = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        cachesDir.appendPathComponent("UsersCache")
        if !fileManager.fileExists(atPath: cachesDir.path) {
            try! fileManager.createDirectory(at: cachesDir, withIntermediateDirectories: true, attributes: nil)
        }
        return cachesDir
    }
    
    private func generateUserName(handle: String) -> String {
        return handle.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    func saveUserToCache(handle: String, userData: UserViewModel) {
        let fileManager = FileManager.default
        var cachesDir = setupUserCache()
        cachesDir.appendPathComponent(generateUserName(handle: handle))
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(userData) else {
            print("Could not encode user data")
            return
        }
        fileManager.createFile(atPath: cachesDir.path, contents: data, attributes: nil)
    }
    
    func tryLoadUserFromCache(handle: String) -> UserViewModel? {
        let fileManager = FileManager.default
        var cachesDir = setupUserCache()
        cachesDir.appendPathComponent(generateUserName(handle: handle))
        if let data = fileManager.contents(atPath: cachesDir.path) {
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(UserViewModel.self, from: data)
                return user
            } catch {
                return nil
            }
        }
        return nil
    }
}

class CacheContestsService {
    private func setupContestsCache() -> URL {
        let fileManager = FileManager.default
        var cachesDir = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        cachesDir.appendPathComponent("ContestsCache")
        if !fileManager.fileExists(atPath: cachesDir.path) {
            try! fileManager.createDirectory(at: cachesDir, withIntermediateDirectories: true, attributes: nil)
        }
        return cachesDir
    }
    
    private func generateContestsName() -> String {
        return Constants.contestsName
    }
    
    func saveContestsToCache(contestsData: [ContestViewModel]) {
        let fileManager = FileManager.default
        var cachesDir = setupContestsCache()
        cachesDir.appendPathComponent(generateContestsName())
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(contestsData) else {
            print("Could not encode contests data")
            return
        }
        fileManager.createFile(atPath: cachesDir.path, contents: data, attributes: nil)
    }
    
    func tryLoadContestsFromCache() -> [ContestViewModel]? {
        let fileManager = FileManager.default
        var cachesDir = setupContestsCache()
        cachesDir.appendPathComponent(generateContestsName())
        if let data = fileManager.contents(atPath: cachesDir.path) {
            let decoder = JSONDecoder()
            do {
                let contest = try decoder.decode([ContestViewModel].self, from: data)
                return contest
            } catch {
                return nil
            }
        }
        return nil
    }
}

class CacheRatingChangesService {
    private func setupRatingChangesCache() -> URL {
        let fileManager = FileManager.default
        var cachesDir = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        cachesDir.appendPathComponent("RatingChanges")
        if !fileManager.fileExists(atPath: cachesDir.path) {
            try! fileManager.createDirectory(at: cachesDir, withIntermediateDirectories: true, attributes: nil)
        }
        return cachesDir
    }
    
    private func generateRatingChangeName(handle: String) -> String {
        return "\(handle)RatingChange"
    }
    
    func saveRatingChangesToCache(handle: String, ratingChanges: [RatingChangeViewModel]) {
        let fileManager = FileManager.default
        var cachesDir = setupRatingChangesCache()
        cachesDir.appendPathComponent(generateRatingChangeName(handle: handle))
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(ratingChanges) else {
            print("Could not encode rating changes data")
            return
        }
        fileManager.createFile(atPath: cachesDir.path, contents: data, attributes: nil)
    }
    
    func tryLoadRatingChangesFromCache(handle: String) -> [RatingChangeViewModel]? {
        let fileManager = FileManager.default
        var cachesDir = setupRatingChangesCache()
        cachesDir.appendPathComponent(generateRatingChangeName(handle: handle))
        if let data = fileManager.contents(atPath: cachesDir.path) {
            let decoder = JSONDecoder()
            do {
                let ratingChanges = try decoder.decode([RatingChangeViewModel].self, from: data)
                return ratingChanges
            } catch {
                return nil
            }
        }
        return nil
    }
}
