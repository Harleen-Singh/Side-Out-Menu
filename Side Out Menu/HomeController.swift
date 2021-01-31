//
//  ViewController.swift
//  Side Out Menu
//
//  Created by Harleen Singh on 23/01/21.
//

import UIKit

class HomeController: UITableViewController {
    
    
    let menuController = MenuController()
    
    fileprivate let menuWidth: CGFloat = 300
    fileprivate var isMenuOpened = false
    fileprivate let velocityOpenThreshold: CGFloat = 500
    
    let darkCoverView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .red
        setupNavigationItems()
       
        setupPanGesture()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupMenuController()
        setupDarkCoverView()
        //
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: view)
        
        if gesture.state == .changed {
            
            
            var x = translation.x
            
            if isMenuOpened {
                x += menuWidth
            }
            
            x = min(x, menuWidth)
            x = max(0, x)
            
            let transform = CGAffineTransform(translationX: x, y: 0)
            performAnimation(transform: transform)
            darkCoverView.alpha = x / menuWidth
        }
        else if gesture.state == .ended {
            
            handleEnded(gesture: gesture)
        }
        
    }
    
    
    @objc func handleOpen() {
        isMenuOpened = true
        performAnimation(transform: CGAffineTransform(translationX: self.menuWidth, y: 0))
        
    }
    
    @objc func handleHide() {
       isMenuOpened = false
        performAnimation(transform: .identity)

    }
    
    //MARK: - Fileprivate
    
    fileprivate func setupDarkCoverView() {
        darkCoverView.alpha = 0  // this alpha is different than the alpha bellow
        darkCoverView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        darkCoverView.isUserInteractionEnabled = false
        
        let mainWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        mainWindow?.addSubview(darkCoverView)
        darkCoverView.frame = mainWindow?.frame ?? .zero
        
    }
    
    fileprivate func setupPanGesture() {
        // Pan Gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
    }
    
    fileprivate func handleEnded(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: view)
        
        let velocity = gesture.velocity(in: view)
        
        if isMenuOpened {
            
            if abs(translation.x) < menuWidth / 2 {
                handleOpen()
                
            }
            else {
                handleHide()
            }
            
            
        } else {
            
            if velocity.x > velocityOpenThreshold {
                handleOpen()
                return
            }
            
            if translation.x < menuWidth / 2 {
                handleHide()
            }
            else {
                handleOpen()
            }
            
        }
        
        
       
        
    }
    
    fileprivate func performAnimation(transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.menuController.view.transform = transform
            self.navigationController?.view.transform = transform
            self.darkCoverView.transform = transform
            
            
            self.darkCoverView.alpha = transform == .identity ? 0 : 1
            
            
        }, completion: nil)
    }
    
    fileprivate func setupMenuController() {
        // initial position
        menuController.view.frame = CGRect(x: 0, y: 0, width: -menuWidth, height: self.view.frame.height)
        
        let mainWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        mainWindow?.addSubview(menuController.view)
        addChild(menuController)
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Home"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(handleOpen))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(handleHide))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        
        cell.textLabel?.text = "Row \(indexPath.row)"
        
        return cell
    }

}

