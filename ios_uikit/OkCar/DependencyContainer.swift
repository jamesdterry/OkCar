//
//  DependencyContainer.swift
//  OkCar
//
//  Created by James Terry on 7/25/20.
//  Copyright © 2020 James Terry. All rights reserved.
//

import UIKit

protocol ViewControllerFactory {
    func switchToTabController()
    func switchToLoginController()
    func makRootViewController() -> UIViewController
    func makeSigninViewController() -> SignInViewController
    func makeCreateAccountViewController() -> CreateAccountViewController
    func makeCarsListViewController() -> CarsListViewController
    func makeCarDetailViewController(for car: CarModel) -> CarDetailViewController
    func makeAddEditCarViewController(for car: CarModel?) -> AddEditCarViewController
}

protocol CarServiceSingleton {
    func getCarService() -> OkCarServiceProtocol
}

protocol LocationSingleton {
    func getLocationService() -> OkCarLocationProtocol
}

protocol FilterSingleton {
    func getCurrentFilter() -> SearchFilters
}

class DependencyContainer {
}

extension DependencyContainer: ViewControllerFactory {
    private func gotoUIViewTransition(_ vc:UIViewController, options:UIView.AnimationOptions)
    {
        let mainWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        
        UIView.transition(with: mainWindow, duration: 0.5, options: options, animations:{ mainWindow.rootViewController = vc }, completion: nil)
    }
    
    func switchToTabController() {
        let tabbarController = UITabBarController()
        
        let carListController = CarsListViewController(container: self)
        let carNavigationController = UINavigationController(rootViewController: carListController)

        let carListTab = UITabBarItem(title: "Cars", image: UIImage(named: "car_tab.png"), selectedImage: UIImage(named: "car_tab.png"))
        carNavigationController.tabBarItem = carListTab
        
        tabbarController.viewControllers = [carNavigationController]

        gotoUIViewTransition(tabbarController, options:UIView.AnimationOptions.transitionFlipFromLeft)
    }
    
    func switchToLoginController() {
        let firstController = SignInViewController(container: self)
        let loginNavigationController = UINavigationController(rootViewController: firstController)

        gotoUIViewTransition(loginNavigationController, options:UIView.AnimationOptions.transitionFlipFromRight)
    }
    
    func makRootViewController() -> UIViewController {
        
        let carService = self.getCarService()
        
        if let _ = carService.currentUser() {
            let tabbarController = UITabBarController()
            
            let carListController = CarsListViewController(container: self)
            let carNavigationController = UINavigationController(rootViewController: carListController)

            let carListTab = UITabBarItem(title: "Cars", image: UIImage(named: "car_tab.png"), selectedImage: UIImage(named: "car_tab.png"))
            carNavigationController.tabBarItem = carListTab
            
            tabbarController.viewControllers = [carNavigationController]
            
            return tabbarController
        } else {
            let firstController = SignInViewController(container: self)
            let navigationController = UINavigationController(rootViewController: firstController)
            return navigationController
        }
        
        
    }
    
    func makeSigninViewController() -> SignInViewController
    {
        return SignInViewController(container: self)
    }
    
    func makeCreateAccountViewController() -> CreateAccountViewController
    {
       return CreateAccountViewController(container: self)
    }
    
    func makeCarsListViewController() -> CarsListViewController {
        return CarsListViewController(container: self)
    }

    func makeCarDetailViewController(for car: CarModel) -> CarDetailViewController {
        return CarDetailViewController(car: car)
    }
        
    func makeAddEditCarViewController(for car: CarModel?) -> AddEditCarViewController {
        return AddEditCarViewController(container: self, car: car)
    }
}

extension DependencyContainer: CarServiceSingleton {
    
    func getCarService() -> OkCarServiceProtocol {
        struct Holder {
            static var carService: OkCarServiceProtocol?
        }

        if let carService = Holder.carService {
            return carService
        }
        
        #if DEBUG
            let serviceToUse = UserDefaults.standard.string(forKey: "okcar-service")?.lowercased()
            
            if serviceToUse == "mock" {
                Holder.carService = OkCarServiceMock()
            } else {
                Holder.carService = OkCarServiceMock()
                //Holder.carService = OkCarServiceRest()
            }
        #else
            Holder.carService = OkCarServiceRest()
        #endif
        
        if let service = Holder.carService {
            service.startService()
            return service
        } else {
            fatalError("Service Not Found")
        }
    }
}

extension DependencyContainer: LocationSingleton {
    func getCurrentFilter() -> SearchFilters {
        struct Holder {
             static var searchFilters = SearchFilters()
        }
        
        return Holder.searchFilters
    }
}
    
extension DependencyContainer: FilterSingleton {
    
    func getLocationService() -> OkCarLocationProtocol {
        struct Holder {
             static var locationService = AppleLocation()
        }
        
        return Holder.locationService
    }
}
