//
//  EditNameViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/10/24.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD

class EditNameViewController: UIViewController {

    @IBOutlet var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func saveUserInfo() {
            let user = NCMBUser.current()
            user?.setObject(userNameTextField.text, forKey: "displayName")
            user?.saveInBackground({ (error) in
                if error != nil {
                    print(error)
                    KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                } else {
                    KRProgressHUD.showSuccess()
                    self.dismiss(animated: true, completion: nil)
                   
                    //ログイン成功
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    //ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(true, forKey: "isLogin")
                    ud.synchronize()
                    
    
                }
            })
    
        }

}
