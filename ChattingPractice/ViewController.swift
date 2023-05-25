//
//  ViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/25.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {

    var box: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loading_icon")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    var remoteConfig: RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }


}

// MARK: - Private Method

private extension ViewController {
    
    func configure() {
        setView()
        setLayout()
        setRemote()
    }
    
    func setView() {
        view.addSubview(box)
    }
    
    func setLayout() {
        box.snp.makeConstraints {
            $0.center.equalTo(view)
            $0.height.width.equalTo(80.0)
        }
    }
    
    func setRemote() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig.activate { changed, error in
              // ...
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
          self.displayWelcome()
        }
    }
    
    func displayWelcome() {
        
        let color = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if caps {
            let alert = UIAlertController(
                title: "공지사항",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "확인",
                style: .default,
                handler: { _ in
                exit(0)
            }))
            
            self.present(alert, animated: true)
        }
        
        view.backgroundColor = UIColor(hex: color ?? "")
    }
}

