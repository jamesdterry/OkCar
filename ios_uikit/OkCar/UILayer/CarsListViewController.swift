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
    private var carsCollectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    private let filterView = FilterView()
    private var currentLocation = CLLocation()
    
    private var flowLayout: UICollectionViewFlowLayout {
        let _flowLayout = UICollectionViewFlowLayout()

        _flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        _flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        _flowLayout.minimumLineSpacing = 0.0
        _flowLayout.minimumInteritemSpacing = 0.0

        return _flowLayout
    }
    
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
        
        carsCollectionView = UICollectionView(frame:CGRect(), collectionViewLayout: flowLayout)
        carsCollectionView.delegate = self
        carsCollectionView.dataSource = self
        carsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            carsCollectionView.backgroundColor = .systemBackground
        } else {
            carsCollectionView.backgroundColor = .systemBackgroundPre13
        }
        self.view.addSubview(carsCollectionView)
        carsCollectionView.autoPinEdge(.top, to: .bottom, of: filterView)
        carsCollectionView.autoPinEdge(toSuperviewMargin: .left, withInset: 0)
        carsCollectionView.autoPinEdge(toSuperviewMargin: .right, withInset: 0)
        carsCollectionView.refreshControl = refreshControl
        
        carsCollectionView.register(CarCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CarCollectionViewCell.self))

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
        
        carsCollectionView.autoPinEdge(.bottom, to: .top, of: noPermissionLabel, withOffset: 0)

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
        self.carsCollectionView.reloadData()
        self.noResultsLabel.isHidden = self.viewModel.cars.count != 0
        self.carsCollectionView.isHidden = self.viewModel.cars.count == 0
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

extension CarsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        
        self.viewModel.access(row: row)
        
        let pos = row % 3
        var cellSize: DetailSize
        
        if (pos == 2) {
            cellSize = .large
        } else {
            cellSize = .small
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CarCollectionViewCell.self), for: indexPath) as! CarCollectionViewCell
        cell.bind(viewModel, row:row, size:cellSize)
        
        return cell
    }
}

extension CarsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        
        let detailViewController = container.makeCarDetailViewController(for: viewModel.cars[row])
        detailViewController.title = "Car Detail"
        self.navigationController?.pushViewController(detailViewController, animated:true)
    }
    
}

extension CarsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = indexPath.row
        
        let pos = row % 3
        
        var width: CGFloat
        var cellSize: DetailSize
        
        if (pos == 2) {
            cellSize = .large
            width = collectionView.frame.size.width
        } else {
            cellSize = .small
            width = collectionView.frame.size.width / 2.0
        }
        
        var height = (width * 2.0) / 3.0
        height += CarDetailView.detailTextHeight(size: cellSize)

        return CGSize(width: width, height: ceil(height))
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
