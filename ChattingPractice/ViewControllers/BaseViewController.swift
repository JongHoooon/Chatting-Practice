//
//  BaseViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/26.
//

import UIKit
import Firebase

class BaseViewController: UIViewController {
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    var remoteColor: UIColor = .label
    
    let statusBar: UIView = {
        let view = UIView()
        
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        setStatusBar()
        setView()
        setLayout()
        setAction()
    }
    
    func setStatusBar() {
        let colorHex: String = remoteConfig["splash_background"].stringValue ?? ""
        remoteColor = UIColor(hex: colorHex)
        
        statusBar.backgroundColor = remoteColor
        
        view.addSubview(statusBar)
        
        statusBar.snp.makeConstraints {
            let statusBarHeight = UIApplication
                .shared
                .statusBarFrame
                .size
                .height
            
            $0.right.top.left.equalTo(view)
            $0.height.equalTo(statusBarHeight)
        }
    }
    
    func setView() {}
    
    func setLayout() {}
    
    func setAction() {}
}
