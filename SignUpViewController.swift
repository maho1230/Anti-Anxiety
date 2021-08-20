//
//  SignUpViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/08.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD

class SignUpViewController: UIViewController,UITextFieldDelegate {
//
//    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
//    @IBOutlet var userNameTextField: UITextField!
    // @IBOutlet var passwordTextField: UITextField!
    // @IBOutlet var confirmTextField: UITextField!
    
    @IBAction func didTapGoogle(sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://qiita.com/masuhara/private/42bea0635e88529303fe")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   userIdTextField.delegate = self
        emailTextField.delegate = self
      //  userNameTextField.delegate = self
        // passwordTextField.delegate = self
        // confirmTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func signUp(){
        
        var error : NSError? = nil
        NCMBUser.requestAuthenticationMail(emailTextField.text, error: &error)
        if (error != nil) {
            print(error ?? "")
            KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。再度実行してください。")
        }
        print("メール認証完了")
        KRProgressHUD.showSuccess(withMessage: "入力したメールアドレス宛にログインの登録メールを送信しました。メールに記載されたURLよりパスワードを設定後、再度アプリにログインしてください。")
        self.dismiss(animated: true, completion: nil)
        print("dismiss完了")
        
        

        
        /*
         let user = NCMBUser()
         
         if (userIdTextField.text?.count)! <= 4 {
         print("文字数が足りません")
         let alert = UIAlertController(title: "エラー", message: "文字数が足りません", preferredStyle: .alert)
         let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (UIAlertAction) in
         print("「はい」が選択されました！")
         })
         let noAction = UIAlertAction(title: "いいえ", style: .default, handler: { (UIAlertAction) in
         print("「いいえ」が選択されました！")
         })
         alert.addAction(yesAction)
         alert.addAction(noAction)
         
         present(alert, animated: true, completion: nil)
         return
         }
         user.userName = userIdTextField.text!
         user.mailAddress = emailTextField.text!
         
         if passwordTextField.text == confirmTextField.text{
         user.password = passwordTextField.text!
         } else {
         print("パスワードと確認入力のパスワードが一致しません")
         let alert = UIAlertController(title: "エラー", message: "パスワードと確認入力が一致しません", preferredStyle: .alert)
         let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (UIAlertAction) in
         print("「はい」が選択されました！")
         })
         let noAction = UIAlertAction(title: "いいえ", style: .default, handler: { (UIAlertAction) in
         print("「いいえ」が選択されました！")
         })
         alert.addAction(yesAction)
         alert.addAction(noAction)
         
         present(alert, animated: true, completion: nil)
         }
         
         user.signUpInBackground { (error) in
         if error != nil{
         //エラーがあった場合
         print(error)
         let alert = UIAlertController(title: "エラー", message: "エラーが起きました", preferredStyle: .alert)
         let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (UIAlertAction) in
         print("「はい」が選択されました！")
         })
         let noAction = UIAlertAction(title: "いいえ", style: .default, handler: { (UIAlertAction) in
         print("「いいえ」が選択されました！")
         })
         alert.addAction(yesAction)
         alert.addAction(noAction)
         
         self.present(alert, animated: true, completion: nil)
         } else {
         //登録成功
         let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
         let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
         UIApplication.shared.keyWindow?.rootViewController = rootViewController
         
         //ログイン状態の保持
         let ud = UserDefaults.standard
         ud.set(true, forKey: "isLogin")
         ud.synchronize()
         }
         }
         */
    }
    

    

    
}
