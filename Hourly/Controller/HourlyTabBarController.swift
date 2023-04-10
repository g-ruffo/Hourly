//
//  HourlyTabBarController.swift
//  Hourly
//
//  Created by Grayson Ruffo on 2023-04-10.
//

import UIKit

class HourlyTabBarController: UITabBarController {

    // MARK: - View Life Cycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
//            tabBar.isTranslucent = false
            tabBar.tintColor = #colorLiteral(red: 0.05700000003, green: 0.09799999744, blue: 0.1070000008, alpha: 1)
            
            delegate = self
            
            // Instantiate view controllers
            let summaryNav = self.storyboard?.instantiateViewController(withIdentifier: K.Identifiers.summaryNav) as! UINavigationController
            
            let calendarNav = self.storyboard?.instantiateViewController(withIdentifier: K.Identifiers.calendarNav) as! UINavigationController
            
            let clientsNav = self.storyboard?.instantiateViewController(withIdentifier: K.Identifiers.clientsNav) as! UINavigationController
            
            let settingsNav = self.storyboard?.instantiateViewController(withIdentifier: K.Identifiers.settingsNav) as! UINavigationController
            
            let workdayNav = self.storyboard?.instantiateViewController(withIdentifier: K.Identifiers.workdayNav) as! UINavigationController
            
            
            // Create TabBar items
            summaryNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: "house.fill"))
            
            calendarNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar"))
            
            clientsNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.text.rectangle.fill"), selectedImage: UIImage(systemName: "person.text.rectangle.fill"))
            
            settingsNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
            
            workdayNav.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
            
            
            // Assign viewControllers to tabBarController
            let viewControllers = [summaryNav, calendarNav, workdayNav, clientsNav, settingsNav]
            self.setViewControllers(viewControllers, animated: false)
            
            
            guard let tabBar = self.tabBar as? HourlyTabBar else { return }
            
            tabBar.didTapButton = { [unowned self] in
                self.routeToCreateNewAd()
            }
        }
        
        func routeToCreateNewAd() {
            let createAdNavController = self.storyboard?.instantiateViewController(withIdentifier: K.Identifiers.workdayNav) as! UINavigationController
            createAdNavController.modalPresentationCapturesStatusBarAppearance = true
            self.present(createAdNavController, animated: true, completion: nil)
        }
    }

    // MARK: - UITabBarController Delegate
    extension HourlyTabBarController: UITabBarControllerDelegate {
        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
                return true
            }
            
            // The middle tab bar item index.
            if selectedIndex == 2 {
                return false
            }
            
            return true
        }
}
