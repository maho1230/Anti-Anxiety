//
//  PostViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/27.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit
import NYXImagesKit
import NCMB
import UITextView_Placeholder
import KRProgressHUD

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    let placeholderImage = UIImage(named: "photo-placeholder")
    
    var resizedImage: UIImage!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var postButton: UIBarButtonItem!
    
    @IBOutlet var postDiseaseNameTextField: UITextField!
    
    @IBOutlet var postCountryTextField: UITextField!
    
    @IBOutlet var postHospitalTextField: UITextField!
    
    @IBOutlet var postMedicineTextField: UITextField!
    
    @IBOutlet var postSymptomTextField: UITextField!
    
    @IBOutlet var postTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImageView.image = placeholderImage
        
        postButton.isEnabled = false
        postTextView.placeholder = "感じたこと"
        postTextView.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[.originalImage] as! UIImage
        
        resizedImage = selectedImage.scale(byFactor: 0.3)
        
        postImageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)
        
        confirmContent()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @IBAction func selectImage() {
        let alertController = UIAlertController(title: "画像選択", message: "シェアする画像を選択して下さい。", preferredStyle: .actionSheet)
        //🦈
        alertController.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        //🦈
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sharePhoto() {
        KRProgressHUD.show()
        
        // 撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let data = resizedImage.pngData()
        // ここを変更（ファイル名無いので）
        //NCMBのファイル作る
        let file = NCMBFile.file(with: data) as! NCMBFile
        
        file.saveInBackground({ (error) in
            if error != nil {
                KRProgressHUD.dismiss()
                let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                //🦈
                alert.popoverPresentationController?.sourceView = self.view
                
                let screenSize = UIScreen.main.bounds
                // ここで表示位置を調整
                // xは画面中央、yは画面下部になる様に指定
                alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
                //🦈
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // 画像アップロードが成功
                let postObject = NCMBObject(className: "Post")
                
                if self.postTextView.text.count == 0 {
                    print("入力されていません")
                    return
                }
                
                postObject?.setObject(self.postDiseaseNameTextField.text!, forKey: "DiseaseName")
                postObject?.setObject(self.postCountryTextField.text!, forKey: "Country")
                postObject?.setObject(self.postHospitalTextField.text!, forKey: "Hospital")
                postObject?.setObject(self.postMedicineTextField.text!, forKey: "Medicine")
                postObject?.setObject(self.postSymptomTextField.text!, forKey: "Symptom")
                postObject?.setObject(self.postTextView.text!, forKey: "text")
                postObject?.setObject(NCMBUser.current(), forKey: "user")
                
                //                let url = "https://console.mbaas.nifcloud.com/#/applications/5yX6s1kyIokIxZ54"  + file.name
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/8SyEVZsgOk882YFh/publicFiles/"  + file.name
                postObject?.setObject(url, forKey: "imageUrl")
                
                postObject?.saveInBackground({ (error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                    } else {
                        KRProgressHUD.dismiss()
                        self.postImageView.image = nil
                        self.postImageView.image = UIImage(named: "photo-placeholder")
                        self.postTextView.text = nil
                        self.tabBarController?.selectedIndex = 0
                        self.postDiseaseNameTextField.text = nil
                        self.postCountryTextField.text = nil
                        self.postHospitalTextField.text = nil
                        self.postMedicineTextField.text = nil
                        self.postSymptomTextField.text = nil
                    }
                })
            }
        }) { (progress) in
            print(progress)
        }
    }
    
    func confirmContent() {
        if postTextView.text.count > 0 && postImageView.image != placeholderImage {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }
    
    @IBAction func cancel() {
        if postTextView.isFirstResponder == true {
            postTextView.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        //🦈
        alert.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        //🦈
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.postTextView.text = nil
            self.postImageView.image = UIImage(named: "photo-placeholder")
            self.confirmContent()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
