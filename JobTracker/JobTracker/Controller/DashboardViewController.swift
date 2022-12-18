//
//  DashboardViewController.swift
//  JobTracker
//
//  Created by Caroline Frey on 11/23/22.
//

import UIKit

class DashboardViewController: UIViewController, SetUsernameDelegate {
    
    let defaults = UserDefaults.standard
    
    // MARK: - UI Properties

    var name: String = ""
    
    private var contentView: DashboardContentView!
    
    private var statusCounts: [String: Int] = ["open": 0, "applied": 0, "interview": 0, "closed": 0]
    
    private var savedJobs = [Job]()
        
    lazy var addNewJobButton: UIBarButtonItem = {
        let config = UIImage.SymbolConfiguration(textStyle: .title3)
        let icon = UIImage(systemName: "plus", withConfiguration: config)
        let button = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(addNewJob))
        button.tintColor = UIColor(named: "Color4")
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .blue
        navigationItem.rightBarButtonItem = addNewJobButton
        
        contentView = DashboardContentView()
        view = contentView
        
        name = defaults.string(forKey: "name") ?? ""
        
        contentView.collectionView.dataSource = self
        contentView.collectionView.delegate = self
        
        contentView.headerView.icon.addTarget(self, action: #selector(presentSettingsView), for: .touchUpInside)
        
        if name != "" {
            contentView.headerView.greeting.text = "Hey, \(name)!"
        } else {
            contentView.headerView.greeting.text = "Hey!"
        }
        
        fetchJobs()
        updateJobStatusCounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchJobs()
        updateJobStatusCounts()
        contentView.collectionView.reloadData()
    }

    // MARK: - Functions
    
    func didUpdateSettings(name: String) {
        if name != "" {
            contentView.headerView.greeting.text = "Hey, \(name)!"
        } else {
            contentView.headerView.greeting.text = "Hey!"
        }
    }
    
    @objc func addNewJob(_ sender: UIBarButtonItem) {
        let addNewJobVC = AddJobViewController()
        navigationController?.pushViewController(addNewJobVC, animated: true)
    }
    
    @objc func presentSettingsView() {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        present(settingsVC, animated: true)
    }
    
    private func updateJobStatusCounts() {
        statusCounts = ["open": 0, "applied": 0, "interview": 0, "closed": 0]
        
        for job in savedJobs {
            statusCounts[job.status ?? "open", default: 0] += 1
        }

        contentView.statusBoxes.openStatusBox.countLabel.text = "\(statusCounts["open"] ?? 0)"
        contentView.statusBoxes.appliedStatusBox.countLabel.text = "\(statusCounts["applied"] ?? 0)"
        contentView.statusBoxes.interviewStatusBox.countLabel.text = "\(statusCounts["interview"] ?? 0)"
        contentView.statusBoxes.closedStatusBox.countLabel.text = "\(statusCounts["closed"] ?? 0)"
    }
    
    private func fetchJobs() {
        DataManager.fetchJobs { [weak self] jobs in
            if let jobs = jobs {
                savedJobs = jobs
                
                DispatchQueue.main.async { [weak self] in
                    self?.contentView.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedJobs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCollectionViewCell.dashboardCollectionViewCellIdentifier, for: indexPath) as! DashboardCollectionViewCell
        cell.configure(company: savedJobs[indexPath.row].company ?? "N/A", location: savedJobs[indexPath.row].location ?? "N/A", status: savedJobs[indexPath.row].status ?? "open")
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension DashboardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = JobDetailsViewController(job: savedJobs[indexPath.row]) //add parameters to pass in job info
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

