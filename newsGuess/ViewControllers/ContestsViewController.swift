//
//  ContestsViewController.swift
//  newsGuess
//
//  Created by Никита Максаковский on 16.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications

class ContestsViewController: UIViewController, ContestsView {
    
    private var sections = [ContestSectionViewModel]()
    private var presenter: ContestsPresenter!
    private let refresh = UIRefreshControl()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        presenter = ContestsPresenter(view: self)
        presenter.onViewDidLoad()
        localNotifications()
        
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    @objc func handleRefreshControl() {
        presenter.update()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func configureView() {
        tableView.backgroundColor = .white
        navigationController?.navigationBar.topItem?.title = "Контесты"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.systemBlue
        navigationController?.navigationBar.tintColor = .white
    }
    internal func reloadView() {
        tableView.reloadData()
    }
    internal func display(viewModel: [ContestSectionViewModel]) {
        sections = viewModel
    }
    private func localNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        guard let contest = sections.first?.cells.first?.contests else {
            return
        }
        guard let dateInUnix = contest.startTimeSeconds else {
            return
        }
        let contestDate = Date(timeIntervalSince1970: dateInUnix)
        
        let content = UNMutableNotificationContent()
        content.title = "Hey, Round is coming"
        content.body = contest.name
        
        let date = Date().addingTimeInterval(Date().distance(to: contestDate) - Constants.notificationDelay)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            guard let error = error else {
                return
            }
            print(error)
        }
    }
}


extension ContestsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.cellHeight)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return ContestTableCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = sections[indexPath.section].cells[indexPath.row]
        if let tableCell = cell as? ContestTableCell {
            tableCell.configure(data: data)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}

private class ContestTableCell: UITableViewCell {
    
    private let name: UILabel = UILabel(frame: .zero)
    private let date: UILabel = UILabel(frame: .zero)
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        name.translatesAutoresizingMaskIntoConstraints = false
        date.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(name)
        contentView.addSubview(date)
        configureConstraints()
    }
    
    func configure(data: ContestCellViewModel) {
        name.text = data.contests.name
        name.font = name.font.withSize(Constants.contestFontSize)
        
        guard let dateInUnix = data.contests.startTimeSeconds else {
            return
        }
        let dateFromUnix = Date(timeIntervalSince1970: dateInUnix)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, MMM. dd, EEEE"
        date.text = dateFormatter.string(from: dateFromUnix).lowercased()
        date.font = date.font.withSize(Constants.dateFontSize)
        date.textColor = UIColor.gray
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            name.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            
            date.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            date.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
        ])
    }
}
