//
//  SideMenuVC.swift
//  PreInterviewTask
//
//  Created by Sherbeny on 04/02/2021.
//

import UIKit

class SideMenuVC: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var viewContainerMenu: UIView! {
        didSet {
            viewContainerMenu.roundCorners(corners: [.bottomRight, .topRight], radius: 30.0)
        }
    }
    @IBOutlet weak var viewClose: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
        }
    }
    
    //MARK: - Variable
    var tapGesture = UITapGestureRecognizer()
    
    //MARK: - VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: - Helper Function
    private func setupUI() {
        self.transitioningDelegate = self
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeSideMenu))
        self.viewClose.addGestureRecognizer(self.tapGesture)
        
        let nib = UINib(nibName: SideMenuTCell.identifier, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: SideMenuTCell.identifier)
    }
    
    //MARK: - IBAction
    @objc func closeSideMenu() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SideMenuVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenuDemoDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTCell.identifier, for: indexPath) as? SideMenuTCell else {
            return UITableViewCell()
        }
        cell.lblTitle.text = sideMenuDemoDate[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

//MARK: - SideMenu Present & Dismiss
extension SideMenuVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDurration: 0.3, animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(animationDurration: 0.3, animationType: .dismiss)
    }
}
