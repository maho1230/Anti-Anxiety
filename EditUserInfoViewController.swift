//
//  EditUserInfoViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/09.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit
import KRProgressHUD

class EditUserInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UINavigationBarDelegate {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var birthdayTextField:UITextField!
    @IBOutlet var introductionTextView: UITextView!
    
    //UIDatePickerを定義するための変数
    var datePicker: UIDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        userNameTextField.delegate = self
        userIdTextField.delegate = self
        introductionTextView.delegate = self
        
        //誕生日コロコロ
        // ピッカー設定
        // ピッカーのスタイルを決める
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = UIDatePicker.Mode.date
        
        // ピッカーの表示日時
        datePicker.timeZone = NSTimeZone.local
        // ピッカーの表示時刻は現在の時刻
        datePicker.locale = Locale.current
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        //インプットビュー設定(紐づいているUITextfieldへ代入)
        birthdayTextField?.inputView = datePicker
        birthdayTextField?.inputAccessoryView = toolbar
        
        
        let userId = NCMBUser.current()?.userName
        userIdTextField.text = userId
        
        if let user = NCMBUser.current() {
            userNameTextField.text = user.object(forKey: "displayName") as? String
            userIdTextField.text = user.userName
            birthdayTextField.text = user.object(forKey: "birthday") as? String
            introductionTextView.text = user.object(forKey: "introduction") as? String
            let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil {
                    print(error)
                    KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                } else {
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
            }
            
        } else {
            //ログアウト成功
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        userImageView.image = selectedImage
        
        let resizedImage = selectedImage.scale(byFactor: 0.4)!
        
        picker.dismiss(animated: true, completion: nil)
        //このpngData(resizedImageがうまくいかなかった)
        let data = resizedImage.pngData()
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: data) as! NCMBFile
        file.saveInBackground({ (error) in
            if error != nil {
                print(error)
                KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
            } else {
                self.userImageView.image = selectedImage
            }
        }) { (progress) in
            print(progress)
        }
    }
    
    @IBAction func selectImage() {
        let actionController = UIAlertController(title: "プロフィール写真の変更", message: "以下の方法から選択してください", preferredStyle: .actionSheet)
        //🦈
        actionController.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        actionController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        //🦈
        
        let cameraAction = UIAlertAction(title: "写真を撮る", style: .default) { (action) in
            //カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用できません。")
            }
        }
        let albumAction = UIAlertAction(title: "ライブラリから選択", style: .default) { (action) in
            //アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用できません。")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        self.present(actionController, animated: true, completion: nil)
    }
    
    
    func closeEditViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveUserInfo() {
        let user = NCMBUser.current()
        user?.setObject(userNameTextField.text, forKey: "displayName")
        user?.setObject(userIdTextField.text, forKey: "userName")
        user?.setObject(birthdayTextField.text, forKey: "birthday")
        user?.setObject(introductionTextView.text, forKey: "introduction")
        user?.saveInBackground({ (error) in
            if error != nil {
                print(error)
                KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                //KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
                KRProgressHUD.showSuccess()
                self.dismiss(animated: true, completion: nil)
            }
        })
        
    }
    
    // UIDatePickerのDoneを押したら発火
    @objc func done() {
        birthdayTextField?.endEditing(true)
        
        // 日付のフォーマット
        let formatter = DateFormatter()
        
        //"yyyy年MM月dd日"を"yyyy/MM/dd"したりして出力の仕方を好きに変更できるよ
        formatter.dateStyle = .medium
        //formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        //(from: datePicker.date))を指定してあげることで
        //datePickerで指定した日付が表示される
        birthdayTextField?.text = "\(formatter.string(from: datePicker.date))"
    }
    
}

/*
 import UIKit
 import NCMB
 import NYXImagesKit
 
 class EditUserInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
 @IBOutlet var userImageView: UIImageView!
 @IBOutlet var userNameTextField: UITextField!
 @IBOutlet var userIdTextField:UITextField!
 @IBOutlet var introductionTextView: UITextView!
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 
 userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
 userImageView.layer.masksToBounds = true
 
 userNameTextField.delegate = self
 userIdTextField.delegate = self
 introductionTextView.delegate = self
 
 let userId = NCMBUser.current()?.userName
 userIdTextField.text = userId
 
 if let user = NCMBUser.current() {
 userNameTextField.text = user.object(forKey: "displayName") as? String
 userIdTextField.text = user.userName
 introductionTextView.text = user.object(forKey: "introduction") as? String
 
 let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
 file.getDataInBackground { (data, error) in
 if error != nil {
 print(error)
 } else {
 if data != nil {
 let image = UIImage(data: data!)
 self.userImageView.image = image
 }
 }
 }
 } else {
 //NCMBUser.current()がnilだったとき
 //ログアウト成功
 let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
 let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
 UIApplication.shared.keyWindow?.rootViewController = rootViewController
 //ログイン状態の保持
 let ud = UserDefaults.standard
 ud.set(false, forKey: "isLogin")
 ud.synchronize()
 }
 }
 
 
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 textField.resignFirstResponder()
 return true
 }
 
 func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
 textView.resignFirstResponder()
 return true
 }
 
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
 
 let resizedImage = selectedImage.scale(byFactor: 0.4)
 
 picker.dismiss(animated: true, completion: nil)
 
 let data = resizedImage!.pngData()
 let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: data) as! NCMBFile
 file.saveInBackground({ (error) in
 if error != nil {
 print(error)
 } else {
 self.userImageView.image = selectedImage
 }
 }) { (progress) in
 print(progress)
 }
 }
 
 @IBAction func selectImage() {
 let actionController = UIAlertController(title: "画像の選択", message: "選択してください", preferredStyle: .actionSheet)
 let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
 //カメラ起動
 if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
 let picker = UIImagePickerController()
 picker.sourceType = .camera
 picker.delegate = self
 self.present(picker, animated: true, completion: nil)
 } else {
 print("この機種ではカメラが使用できません。")
 }
 }
 let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
 //アルバム起動
 if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
 let picker = UIImagePickerController()
 picker.sourceType = .photoLibrary
 picker.delegate = self
 self.present(picker, animated: true, completion: nil)
 } else {
 print("この機種ではフォトライブラリが使用できません。")
 }
 }
 let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
 actionController.dismiss(animated: true, completion: nil)
 }
 
 actionController.addAction(cameraAction)
 actionController.addAction(albumAction)
 actionController.addAction(cancelAction)
 self.present(actionController, animated: true, completion: nil)
 }
 
 @IBAction func closeEditViewController() {
 self.dismiss(animated: true, completion: nil)
 }
 
 @IBAction func saveUserInfo() {
 let user = NCMBUser.current()
 user?.setObject(userNameTextField.text, forKey: "displayName")
 user?.setObject(userIdTextField.text, forKey: "userName")
 user?.setObject(introductionTextView.text, forKey: "introduction")
 user?.saveInBackground({ (error) in
 if error != nil {
 print(error)
 } else {
 self.dismiss(animated: true, completion: nil)
 }
 })
 }
 }
 
 Multiple commands produce '/Users/maho/Library/Developer/Xcode/DerivedData/Pandemic-ftwsbyhpdnzstlftyftdlmxucppa/Build/Products/Debug-iphonesimulator/Pandemic.app/iTunesArtwork@2x.png':
 1) Target 'Pandemic' (project 'Pandemic') has copy command from '/Users/maho/Desktop/iOS-Develop/Pandemic/Pandemic/Images/AppIconResizer_202010240206_7f723b759c25e326ebf4aee17d5d3056/iTunesArtwork@2x.png' to '/Users/maho/Library/Developer/Xcode/DerivedData/Pandemic-ftwsbyhpdnzstlftyftdlmxucppa/Build/Products/Debug-iphonesimulator/Pandemic.app/iTunesArtwork@2x.png'
 2) Target 'Pandemic' (project 'Pandemic') has copy command from '/Users/maho/Desktop/iOS-Develop/Pandemic/Pandemic/Images/ios/iTunesArtwork@2x.png' to '/Users/maho/Library/Developer/Xcode/DerivedData/Pandemic-ftwsbyhpdnzstlftyftdlmxucppa/Build/Products/Debug-iphonesimulator/Pandemic.app/iTunesArtwork@2x.png'
 
 
 
 */
