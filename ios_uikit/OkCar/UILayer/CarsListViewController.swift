//
//  CarsListViewController.swift
//  OkCar
//
//  Created by James Terry on 7/26/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit
import PureLayout
import CoreLocation

class CarsListViewController: UIViewController {
    
    typealias Container = CarServiceSingleton & ViewControllerFactory & FilterSingleton & LocationSingleton
    private let container: Container
    
    private lazy var carService = container.getCarService()
    private lazy var locationService = container.getLocationService()
    private lazy var viewModel = CarsViewModel(service: carService)
    
    private var filters: SearchFilters
    
    private let activityIndicatorView = UIActivityIndicatorView()
    private let noPermissionLabel = UILabel()
    private let noResultsLabel = UILabel()
    private let carsTableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let filterView = FilterView()
    private var currentLocation = CLLocation()
    
    init(container: Container) {
        self.container = container
        self.filters = container.getCurrentFilter()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .systemBackgroundPre13
        }
        
        if title == nil {
            title = "Cars"
        }
        
        if #available(iOS 13.0, *) {
            let leftButtonItem = UIBarButtonItem.init(
                  image: UIImage(systemName: "shield.slash"),
                  style: .plain,
                  target: self,
                  action: #selector(logoutButtonTappped)
            )
            leftButtonItem.accessibilityLabel = NSLocalizedString("Logout", comment: "Logout")
            self.navigationItem.leftBarButtonItem = leftButtonItem
        } else {
            let leftButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(logoutButtonTappped))
            leftButtonItem.accessibilityLabel = NSLocalizedString("Logout", comment: "Logout")
            self.navigationItem.leftBarButtonItem = leftButtonItem
        }
            
        filterView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(filterView)
        filterView.autoPinEdge(toSuperviewMargin: .top, withInset: 0)
        filterView.autoPinEdge(toSuperviewMargin: .left, withInset: 0)
        filterView.autoPinEdge(toSuperviewMargin: .right, withInset: 0)
        filterView.filters = filters
        filterView.delegate = self
        filterView.update()
        
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        carsTableView.rowHeight = UITableView.automaticDimension
        carsTableView.estimatedRowHeight = 100
        carsTableView.separatorStyle = .singleLine
        carsTableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        carsTableView.delegate = self
        carsTableView.dataSource = self
        carsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(carsTableView)
        carsTableView.autoPinEdge(.top, to: .bottom, of: filterView)
        carsTableView.autoPinEdge(toSuperviewMargin: .left, withInset: 0)
        carsTableView.autoPinEdge(toSuperviewMargin: .right, withInset: 0)
        carsTableView.refreshControl = refreshControl
        
        carsTableView.register(CarTableViewCell.self, forCellReuseIdentifier: String(describing: CarTableViewCell.self))

        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultsLabel.text = "No Cars"
        self.view.addSubview(noResultsLabel)
        noResultsLabel.autoCenterInSuperview()
        noResultsLabel.isHidden = true
                
        noPermissionLabel.translatesAutoresizingMaskIntoConstraints = false
        noPermissionLabel.text = "No location permission, showing near Toldeo, OH"
        noPermissionLabel.adjustsFontForContentSizeCategory = true
        noPermissionLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        noPermissionLabel.textAlignment = .center
        self.view.addSubview(noPermissionLabel)
        noPermissionLabel.autoPinEdge(toSuperviewEdge: .left)
        noPermissionLabel.autoPinEdge(toSuperviewEdge: .right)
        noPermissionLabel.autoPinEdge(toSuperviewSafeArea: .bottom)
        noPermissionLabel.isHidden = true
        
        carsTableView.autoPinEdge(.bottom, to: .top, of: noPermissionLabel, withOffset: 0)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        self.view.addSubview(activityIndicatorView)
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .large
        }
        activityIndicatorView.autoCenterInSuperview()
        
        viewModel.delegate = self
    }

    fileprivate func updateTableWithCars() {
        self.carsTableView.reloadData()
        self.noResultsLabel.isHidden = self.viewModel.cars.count != 0
        self.carsTableView.isHidden = self.viewModel.cars.count == 0
    }
    
    fileprivate func reloadCars(fromRefresh: Bool) {
        if (!fromRefresh) {
            activityIndicatorView.startAnimating()
        }
        
        viewModel.fetchCars(filter: filters,
                            llat: self.currentLocation.coordinate.latitude,
                            llong: self.currentLocation.coordinate.longitude)  { (result) in
            // Reload
            if (fromRefresh) {
                self.refreshControl.endRefreshing()
            } else {
                self.activityIndicatorView.stopAnimating()
            }
            self.updateTableWithCars()
            
            if case .failure = result {
                self.showErrorAlert(title: "Network Error", msg: "Error")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationService.delegate = self
        locationService.requestPermission()
        
        if let location = locationService.requestCurrentLocation() {
            self.currentLocation = location
            reloadCars(fromRefresh: false)
        }
                
    }
    
    @objc func logoutButtonTappped() {
        carService.logout()
        
        let signinViewController = container.makeSigninViewController()
        self.navigationController?.setViewControllers([signinViewController], animated: false)
    }
    
    @objc func addButtonTappped() {
        let addEditViewController = container.makeAddEditCarViewController(for: nil)
        addEditViewController.title = "Add Car"
        addEditViewController.editCompletion = {
            self.reloadCars(fromRefresh: false)
        }
        let enclosingNavController = UINavigationController(rootViewController: addEditViewController)
        self.present(enclosingNavController, animated: true)
    }
    
    @objc func handleRefreshControl() {
        DispatchQueue.main.async {
            self.reloadCars(fromRefresh:true)
         }
    }
}

extension CarsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        self.viewModel.access(row: row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CarTableViewCell.self), for: indexPath) as! CarTableViewCell
        cell.bind(viewModel, row:row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cars.count
    }
}


extension CarsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        let detailViewController = container.makeCarDetailViewController(for: viewModel.cars[row])
        detailViewController.title = "Car Detail"
        self.navigationController?.pushViewController(detailViewController, animated:true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}

extension CarsListViewController: FilterViewDelegate {
    func clearFilters() {
        filterView.filters.clear()
        filterView.update()
        reloadCars(fromRefresh: false)
    }
    
    func presentFilter(filterCategory: FilterCategory) {
        let filterSheet = FilterSheetViewController(filterCategory: filterCategory, startFilters: self.filters)
        filterSheet.delegate = self
        self.present(filterSheet, animated: true, completion: nil)
    }

}

extension CarsListViewController: FilterChangeHandler {
    func filterSet(filterCategory: FilterCategory, filter: SearchFilter)
    {
        switch filterCategory {
        case .price:
            self.filters.price = filter
        case .mileage:
            self.filters.mileage = filter
        }

        filterView.filters = self.filters
        filterView.update()
        
        reloadCars(fromRefresh: false)
    }
}

extension CarsListViewController: OkCarLocationDelegate {
    func updatedAuthorization(_ authorization: OkCarLocationAuthorization)
    {
        switch authorization {
        case .unknown, .unavailable:
            noPermissionLabel.isHidden = false
        case .available:
            noPermissionLabel.isHidden = true
        }
    }
    
    func updatedLocation(_ location: CLLocation)
    {
        self.currentLocation = location
        reloadCars(fromRefresh: false)
    }
    
}

extension CarsListViewController: CarViewModelUpdates
{
    func hasMoreData() {
        self.updateTableWithCars()
    }
    
}
