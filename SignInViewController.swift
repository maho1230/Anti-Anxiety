//
//  SignInViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/08.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var mailaddressTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailaddressTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signIn(){
        
        if (mailaddressTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0 {
            //メール認証
            //inBackgroud = mailアドレスのtextfieldの文字NCMBのデータ通信で同じかなと確認
            NCMBUser.logInWithMailAddress(inBackground: mailaddressTextField.text, password: passwordTextField.text, block: {(user, error) in
                if (error != nil) {
                    print(error)
                    KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                    let alert = UIAlertController(title: "エラー", message: "ログインに失敗しました。時間をおいて再度実行してください。", preferredStyle: .alert)
                    //🦈
                    alert.popoverPresentationController?.sourceView = self.view
                    
                    let screenSize = UIScreen.main.bounds
                    // ここで表示位置を調整
                    // xは画面中央、yは画面下部になる様に指定
                    alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
                    //🦈
                    let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (UIAlertAction) in
                        print("「はい」が選択されました！")
                    })
                    alert.addAction(yesAction)
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("ログイン成功")
                    
                    if NCMBUser.current().object(forKey: "displayName") == nil {
                        // 画面遷移のコード
                        self.performSegue(withIdentifier: "toEditDisplayName", sender: self)
                        
                    } else {
                        
                        KRProgressHUD.showSuccess()
                        //ログイン成功
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(identifier: "RootTabBarController")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        
                        //ログイン状態の保持
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: "isLogin")
                        ud.synchronize()
                        
                        print(NCMBUser.current())
                    }}}
            )
            
        }
        
    }
    
    
    
    
    
    @IBAction func forgetPassword(){
        //書いておく
        let alert = UIAlertController(title: "パスワードをお忘れですか？", message: "再設定メールを上記のメールアドレスに送りますか", preferredStyle: .alert)
        //🦈
        alert.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        //🦈
        let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (UIAlertAction) in
            print("「はい」が選択されました！")
            var error : NSError? = nil
            let result = NCMBUser.requestPasswordReset(forEmail: self.mailaddressTextField.text, error: &error)
            
            if (error != nil) {
                // 会員登録用のメール要求に失敗した場合の処理
                print("会員登録用メールの要求に失敗しました: \(error)")
                KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                
            }
            // 会員登録用メールの要求に成功した場合の処理
            print("会員登録用メールの要求に成功しました")
            self.dismiss(animated: true, completion: nil)
            print("dismiss完了")
            
        })
        let noAction = UIAlertAction(title: "いいえ", style: .default, handler: { (UIAlertAction) in
            print("「いいえ」が選択されました！")
        })
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    // 今
    @IBAction func skip() {
        // 匿名ログイン
        NCMBAnonymousUtils.logIn { (user, error) in
            if error != nil {
                print ("Log in failed")
                print (error ?? "")
            } else {
                print("Logged in")
                let authData = user!.object(forKey: "authData") as! [String: Any]
                let uuid = (authData["anonymous"] as! [String: String])["id"]
                UserDefaults.standard.set(uuid, forKey: "uuid")
            }
        }
        
        
        //登録成功
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
        UIApplication.shared.keyWindow?.rootViewController = rootViewController
        //ログイン状態の保持
        let ud = UserDefaults.standard
        ud.set(true, forKey: "isLogin")
        ud.synchronize()
    }
    
    
}
