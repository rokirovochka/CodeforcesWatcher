//
//  ProfileViewController.swift
//  newsGuess
//
//  Created by Никита Максаковский on 10.12.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import UIKit
import Foundation


class PeopleViewController: UIViewController, PeopleView {
    
    private var shareData: UserViewModel?
    private var sections = [UserSectionViewModel]()
    private var presenter: PeoplePresenter!
    private let refresh = UIRefreshControl()
    
    @IBOutlet weak var handleToAdd: UITextField!
    @IBOutlet weak var addHandleButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        
        presenter = PeoplePresenter(view: self)
        
        presenter.onViewDidLoad()
        
        tableView.refreshControl = refresh
        
        refresh.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        guard let handles = UserDefaults.standard.object(forKey: "handles") as? [String] else {
            tableView.refreshControl?.endRefreshing()
            return
        }
        for handle in handles {
            presenter.addUserToWatch(handle: handle, update: true)
        }
        tableView.refreshControl?.endRefreshing()
    }
    
    private func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        handleToAdd.delegate = self
        
        tableView.backgroundColor = .white
        navigationController?.navigationBar.topItem?.title = "Люди"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.systemBlue
        navigationController?.navigationBar.tintColor = .white
    }
    
    internal func display(viewModel: [UserSectionViewModel]) {
        sections = viewModel
    }
    
    internal func reloadView() {
        tableView.reloadData()
    }
    
    @IBAction func onAddButtonTapped(_ sender: Any) {
        presenter.addUserToWatch(handle: handleToAdd.text, update: false)
        handleToAdd.text = Constants.emptyString
    }
}

extension PeopleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.cellHeight)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        setBackgroundMessage(tableView: tableView)
        return sections.count
    }
    
    func setBackgroundMessage(tableView: UITableView) {
        if sections.isEmpty {
            tableView.setEmptyMessage("У вас еще нет пользователей для отслеживания.\n Добавьте первого, кнопкой '+' вверху экрана")
        } else {
            tableView.restore()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UserTableCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = sections[indexPath.section].cells[indexPath.row]
        if let tableCell = cell as? UserTableCell {
            tableCell.configure(data: data)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Удалить") {
            _, indexPath in
            
            let handle = self.sections[indexPath.section].cells[indexPath.row].userData.handle.lowercased()
            guard var handles = UserDefaults.standard.object(forKey: "handles") as? [String] else {
                return
            }
            if handles.contains(handle){handles.removeAll(where:{ handle == $0 })}
            UserDefaults.standard.set(handles, forKey: "handles")
            self.sections[indexPath.section].cells.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        shareData = sections[indexPath.section].cells[indexPath.row].userData
        performSegue(withIdentifier: "ShowProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let UserVC = segue.destination as? UserViewController {
            UserVC.userData = shareData
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

private class UserTableCell: UITableViewCell {
    
    private let handle: UILabel = UILabel(frame: .zero)
    private let rating: UILabel = UILabel(frame: .zero)
    private let delta: UILabel = UILabel(frame: .zero)
    private let lastUpdate: UILabel = UILabel(frame: .zero)
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        handle.translatesAutoresizingMaskIntoConstraints = false
        rating.translatesAutoresizingMaskIntoConstraints = false
        delta.translatesAutoresizingMaskIntoConstraints = false
        lastUpdate.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(handle)
        contentView.addSubview(rating)
        contentView.addSubview(delta)
        contentView.addSubview(lastUpdate)
        configureConstraints()
    }
    
    func configure(data: UserCellViewModel) {
        handle.text = data.userData.handle
        if let userRating = data.userData.rating {
            rating.text = "\(userRating)"
        }
        setColor(rank: data.userData.rank)
        setFonts()
        
        guard let lastChange = data.ratingChange.last else {
            return
        }
        let lastRC = lastChange.newRating - lastChange.oldRating
        if lastRC < 0 {
            delta.textColor = UIColor.red
            delta.text = "▼ " + String(abs(lastRC))
        } else {
            delta.textColor = UIColor.green
            delta.text = "▲ " + String(abs(lastRC))
        }
        let dateInUnix = lastChange.ratingUpdateTimeSeconds
        let dateFromUnix = Date(timeIntervalSince1970: dateInUnix)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM. dd, YYYY"
        lastUpdate.text = "Last rating update: " + dateFormatter.string(from: dateFromUnix).lowercased()
        lastUpdate.font = lastUpdate.font.withSize(Constants.dateFontSize)
        lastUpdate.textColor = UIColor.gray
    }
    
    private func setFonts() {
        handle.font = handle.font.withSize(Constants.handleFontSize)
        delta.font = delta.font.withSize(Constants.handleFontSize)
        lastUpdate.font = lastUpdate.font.withSize(Constants.handleFontSize)
        rating.font = rating.font.withSize(Constants.handleFontSize)
        
    }
    
    private func setColor(rank: String?) {
        var color: UIColor = .gray
        guard let rankStr = rank else {
            return
        }
        let tmpRank = Rank(rawValue: rankStr)
        switch tmpRank {
        case .expert:
            color = .blue
        case .newbie:
            color = .gray
        case .pupil:
            color = .green
        case .specialist:
            color = .cyan
        case .candidateMaster:
            color = .purple
        case .master:
            color = .systemYellow
        case .internationalMaster:
            color = .orange
        case .grandmaster:
            color = .red
        case .internationalGrandmaster:
            color = .red
        case .legendaryGrandmaster:
            handle.attributedText = getAttributedString(text: handle.text!)
            rating.attributedText = getAttributedString(text: rating.text!)
            return
        default:
            color = .gray
        }
        handle.textColor = color
        rating.textColor = color
    }
    
    private func getAttributedString(text: String) -> NSMutableAttributedString {
        let string = NSMutableAttributedString(string: text, attributes: nil )
        string.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: text.count))
        string.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0,length: 1))
        return string
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            handle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            handle.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            
            rating.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            rating.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            
            lastUpdate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            lastUpdate.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            
            delta.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            delta.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
        ])
    }
}
