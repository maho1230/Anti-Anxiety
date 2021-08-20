//
//  CommentViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/27.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD
import Kingfisher

class CommentViewController: UIViewController, UITableViewDataSource {
    
    var postId: String!

    var comments = [Comment]()

    @IBOutlet var commentTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        commentTableView.dataSource = self

        commentTableView.tableFooterView = UIView()
        
        commentTableView.estimatedRowHeight = 80
        
        commentTableView.rowHeight = UITableView.automaticDimension

        loadComments()
       }

       override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return comments.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
           let userImageView = cell.viewWithTag(1) as! UIImageView
           let userNameLabel = cell.viewWithTag(2) as! UILabel
           let commentLabel = cell.viewWithTag(3) as! UILabel
           // let createDateLabel = cell.viewWithTag(4) as! UILabel

        
        commentTableView.rowHeight = 116
           // ユーザー画像を丸く
           userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
           userImageView.layer.masksToBounds = true

           let user = comments[indexPath.row].user
        
//           let userImagePath = "https://mb.api.cloud.nifty.com/2013-09-01/applications/5yX6s1kyIokIxZ54/publicFiles/" + user.objectId
//           userImageView.kf.setImage(with: URL(string: userImagePath))
        
        let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
                   file.getDataInBackground { (data, error) in
                       if error != nil {
                           let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
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
                           if data != nil {
                               let image = UIImage(data: data!)
                            userImageView.image = image
                           }
                    }}
           userNameLabel.text = user.displayName
           commentLabel.text = comments[indexPath.row].text

           return cell
       }

       func loadComments() {
           comments = [Comment]()
           let query = NCMBQuery(className: "Comment")
           query?.whereKey("postId", equalTo: postId)
           query?.includeKey("user")
           query?.findObjectsInBackground({ (result, error) in
               if error != nil {
                KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
               } else {
                   for commentObject in result as! [NCMBObject] {
                       // コメントをしたユーザーの情報を取得
                       let user = commentObject.object(forKey: "user") as! NCMBUser
                       let userModel = User(objectId: user.objectId, userName: user.userName)
                       userModel.displayName = user.object(forKey: "displayName") as? String

                       // コメントの文字を取得
                       let text = commentObject.object(forKey: "text") as! String

                       // Commentクラスに格納
                       let comment = Comment(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                       self.comments.append(comment)

                       // テーブルをリロード
                       self.commentTableView.reloadData()
                   }

               }
           })
       }

       @IBAction func addComment() {
           let alert = UIAlertController(title: "コメント", message: "コメントを入力して下さい", preferredStyle: .alert)
        //🦈
        alert.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        //🦈
           let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
               alert.dismiss(animated: true, completion: nil)
           }
           let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
               alert.dismiss(animated: true, completion: nil)
               KRProgressHUD.show()
               let object = NCMBObject(className: "Comment")
               object?.setObject(self.postId, forKey: "postId")
               object?.setObject(NCMBUser.current(), forKey: "user")
               object?.setObject(alert.textFields?.first?.text, forKey: "text")
               object?.saveInBackground({ (error) in
                   if error != nil {
                    KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                   } else {
                       KRProgressHUD.dismiss()
                       self.loadComments()
                    print("コメント成功！")
                   }
               })
           }

           alert.addAction(cancelAction)
           alert.addAction(okAction)
           alert.addTextField { (textField) in
               textField.placeholder = "ここにコメントを入力"
           }
           self.present(alert, animated: true, completion: nil)
       }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


