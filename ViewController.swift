//
//  ViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/07.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//


import UIKit
import NCMB
import Kingfisher
import KRProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimelineTableViewCellDelegate {
    
    var selectedPost: NCMBObject?
    
    var posts = [NCMBObject]()

    var followings = [NCMBUser]()
    
    var blockUserIdArray = [String]()
    
    @IBOutlet var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        timelineTableView.tableFooterView = UIView()
        
        //引っ張って更新
        setRefreshControl()
        
        loadTimeline()
        
//        loadBlockedUsers()
        
        view.backgroundColor = UIColor.init(red: 200/255, green: 255/255, blue: 186/255, alpha: 30/100)

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //⚠️いじった
        //if 
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
        //内容
        cell.delegate = self
        cell.tag = indexPath.row

        let user = posts[indexPath.row].object(forKey: "user") as! NCMBUser
        cell.userNameLabel.text = user.object(forKey: "displayName") as! String
        
        //　ユーザーの画像
       let userImageUrl =
           "https://mbaas.api.nifcloud.com/2013-09-01/applications/8SyEVZsgOk882YFh/publicFiles/" + user.objectId
        
        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"))
        
        
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
                            cell.userImageView.image = image
                           }
                    }}
//print("ポストの集まり")
//print(posts)
        /* 感じたこと
         cell.commentTextViewのcommentTextView→カスタムセルのlabelの名前
         posts[indexPath.row].textのtext→Post.swiftの項目にあるtext
        */
        
        //posts[indexPath.row].object(forKey: "user") as! NCMBUser
        cell.countryLabel.text  =  posts[indexPath.row].object(forKey: "Country") as! String
        cell.diseaseNameLabel.text = posts[indexPath.row].object(forKey: "DiseaseName") as! String
        cell.hospitalLabel.text = posts[indexPath.row].object(forKey: "Hospital") as! String
        cell.medicineLabel.text = posts[indexPath.row].object(forKey: "Medicine") as! String
        cell.symptomLabel.text = posts[indexPath.row].object(forKey: "Symptom") as! String
        cell.commentTextView.text = posts[indexPath.row].object(forKey: "text") as! String

        
        
        //投稿時間
        cell.timestampLabel.text = posts[indexPath.row].object(forKey: "createDate") as! String
       // let createDateString: String?
       // createDateString = stringFromDate(date: posts[indexPath.row].object(forKey: "createDate") as! Date, format: "WMD")
       // print(posts[indexPath.row].object(forKey: "createDate") as! String)
        //cell.timestampLabel.text = createDateString
        //　投稿画像出てこない問題発生中⚠️ urlはある
      //  let imageUrl = posts[indexPath.row].imageUrl as! String
        let imageUrl = posts[indexPath.row].object(forKey: "imageUrl") as! String
        cell.photoImageView.kf.setImage(with: URL(string: imageUrl))

        print("わあああああああ")
        print(imageUrl)

        // Likeによってハートの表示を変える
//        if posts[indexPath.row].object(forKey: "likeUser") as! Bool == true {
//            cell.likeButton.setImage(UIImage(named: "icons8-stitched-heart-48"), for: .normal)
//        } else {
//            cell.likeButton.setImage(UIImage(named: "icons8-heart-50"), for: .normal)
//            }

        // Likeの数
//        cell.likeCountLabel.text = "\(posts[indexPath.row].object(forKey: "likeUser"))件"

        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        //cell.timestampLabel.text = posts[indexPath.row].createDate.string()

        return cell
    }
    
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        guard let currentUser = NCMBUser.current() else {
            //ログインに戻る
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
            return
        }
     
        
        if posts[tableViewCell.tag].object(forKey: "likeUser") as! Bool  == false || posts[tableViewCell.tag].object(forKey: "likeUser") as! Bool  == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(currentUser.objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                    } else {
                        self.loadTimeline()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            KRProgressHUD.showError( withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                        } else {
                            self.loadTimeline()
                        }
                    })
                }
            })
        }
        
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//            if setTimeArray[indexPath.row].user.objectId != NCMBUser.current()?.objectId {
//                let reportButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "報告") { (action, index) -> Void in
//                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                    let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
//                        // PKHUD用にする
//                        HUD.show(.labeledSuccess(title: "この投稿を報告しました。ご協力ありがとうございました。", subtitle: nil))
//                        //新たにクラス作る
//                        let object = NCMBObject(className: "Report")
//                        object?.setObject(self.setTimeArray[indexPath.row].objectId, forKey: "reportId")
//                        object?.setObject(NCMBUser.current(), forKey: "user")
//                        object?.saveInBackground({ (error) in
//                            if error != nil {
//                                HUD.show(.labeledError(title: "エラーです", subtitle: nil))
//                            } else {
//                                HUD.flash(.progress, delay: 2)
//                                tableView.deselectRow(at: indexPath, animated: true)
//                            }
//                        })
//                    }
//                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
//                        alertController.dismiss(animated: true, completion: nil)
//                    }
//                    alertController.addAction(reportAction)
//                    alertController.addAction(cancelAction)
//                    self.present(alertController, animated: true, completion: nil)
//                    tableView.isEditing = false
//
//    折りたたむ




    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        // アラートコントローラーについての説明
       let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
       // キャンセルの説明
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        print("ドーン")
        print((posts[tableViewCell.tag].object(forKey: "user")as! NCMBUser).objectId)
        print("なにい")
        print(NCMBUser.current()?.objectId)
        
        // 自分の投稿だったら
        if (posts[tableViewCell.tag].object(forKey: "user")as! NCMBUser).objectId ==  NCMBUser.current().objectId
        {
           
            
        // ⚠️削除アクションの説明、上にある！
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
            KRProgressHUD.show()
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                } else {
                    // 取得した投稿オブジェクトを削除
                    post?.deleteInBackground({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                        } else {
                            // 再読込
                            self.loadTimeline()
                            KRProgressHUD.dismiss()
                        }
                    })
                }
            })
        }
            
        
            
        // ⚠️アラートコントローラーに削除アクション、キャンセルアクションをつけるよ
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
           
        // 他人の投稿だったら
        } else {
        // 報告アクションの説明
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
                           KRProgressHUD.showSuccess(withMessage: "この投稿を報告しました。ご協力ありがとうございました。")
                           // 報告クラス
                           let object = NCMBObject(className: "Report")
                           //　情報セット
                           object?.setObject(self.posts[tableViewCell.tag].objectId, forKey: "reportId")
                           object?.setObject(NCMBUser.current(), forKey: "user")
                           object?.saveInBackground({ (error) in
                               if error != nil{
                                   KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                               } else {
//                                   KRProgressHUD.showSuccess()
                                print("完了！")
                                   
                               }
                           })
                       }
            
            let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
                KRProgressHUD.showSuccess(withMessage: "この投稿をブロックしました。")
                     let object = NCMBObject(className: "Block") //新たにクラス作る
                     object?.setObject(self.posts[tableViewCell.tag].objectId, forKey: "blockUserID")
                     object?.setObject(NCMBUser.current(), forKey: "user")
                     object?.saveInBackground({ (error) in
                       if error != nil {
                         KRProgressHUD.showError()
                       } else {
                        KRProgressHUD.showSuccess()
                         self.getBlockUser()
                        self.loadTimeline()
                       }
                     })
                   }
         
    // アラートコントローラーに報告アクション、キャンセルアクションをつけるよ
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        alertController.addAction(blockAction)
        }
       
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]

        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    //② この関数はviewWillAppearと、ブロックが選択される部分(※最後のtableviewのコードに記載あり)の二箇所で読み込む
    func getBlockUser() {

            let query = NCMBQuery(className: "Block")

            //includeKeyでBlockの子クラスである会員情報を持ってきている
            query?.includeKey("user")
            query?.whereKey("user", equalTo: NCMBUser.current())
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    //エラーの処理
                    KRProgressHUD.showError()
                } else {
                    //ブロックされたユーザーのIDが含まれる + removeall()は初期化していて、データの重複を防いでいる
                    self.blockUserIdArray.removeAll()
                    for blockObject in result as! [NCMBObject] {
                        //この部分で①の配列にブロックユーザー情報が格納
                        self.blockUserIdArray.append(blockObject.object(forKey: "blockUserID") as! String)
//                        //この部分で①の配列にブロックユーザー情報が格納
//                        self.blockUserIdArray.append(blockObject.object(forKey: "blockUserID") as! NCMBObject)

                    }

                }
            })
            loadTimeline()
        }

    
    func loadTimeline() {
        
        guard let currentUser = NCMBUser.current() else {
            //ログインに戻る
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
            return
        }
        
        // Postで絞り込み！
        let query = NCMBQuery(className: "Post")
        print(blockUserIdArray)
        if blockUserIdArray.count != 0 {
            query?.whereKey("objectId", notContainedIn: blockUserIdArray)
        }
        
        //Userの情報も取ってくる、ここで絞る！
        query?.includeKey("user")

        // 投稿時間で降順！
        query?.order(byDescending: "createDate")
        
        // フォローしてる人を含める
//        query?.whereKey("user", containedIn: followings)
        
        // ブロックしてる人を弾く
        //query?.whereKey("user", notContainedIn: blockUserIdArray)

        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError( withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [NCMBObject]()
                print(result)
                self.posts = result as! [NCMBObject]
//
//                for postObject in result as! [NCMBObject] {
//                    // ユーザー情報をUserクラスにセット
//                    let user = postObject.object(forKey: "user") as! NCMBUser
//
//                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
//                    if user.object(forKey: "active") as? Bool != false {
//                        // 投稿したユーザーの情報をUserモデルにまとめる
//                        let userModel = User(objectId: user.objectId, userName: user.userName)
//                        userModel.displayName = user.object(forKey: "displayName") as? String
//
//                        // 投稿の情報を取得
//                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
//                        let text = postObject.object(forKey: "text") as! String
//
//                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
//                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
//
//                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
//                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
//                        if likeUsers?.contains(currentUser.objectId) == true {
//                            post.isLiked = true
//                        } else {
//                            post.isLiked = false
//                        }
//
//                        // いいねの件数
//                        if let likes = likeUsers {
//                            post.likeCount = likes.count
//                        }
//
//                        // 配列に加える
//                        self.posts.append(post)
//                    }
//                }
                
                print("ロードします")

                // 投稿のデータが揃ったらTableViewをリロード
                self.timelineTableView.reloadData()
            }
        })
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }

    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        //　グルグル
        refreshControl.beginRefreshing()
        //　更新〜〜
        loadTimeline()
        //self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }

    func loadFollowingUsers() {
           // フォロー中の人だけ持ってくる
           let query = NCMBQuery(className: "Follow")
         //  query?.includeKey("user")
           query?.includeKey("following")
        
           query?.whereKey("user", equalTo: NCMBUser.current())
           query?.findObjectsInBackground({ (result, error) in
               if error != nil {
                   KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
               } else {
                   self.followings = [NCMBUser]()
                   for following in result as! [NCMBObject] {
                       self.followings.append(following.object(forKey: "following") as! NCMBUser)
                   }
                   self.followings.append(NCMBUser.current())
                   
//                   self.loadBlockedUsers()
               }
           })
       }
    

//    func loadBlockedUsers() {
//              // フォロー中の人だけ持ってくる
//              let query = NCMBQuery(className: "Block")
////              query?.includeKey("user")
//              query?.includeKey("blockedUser")
//              query?.whereKey("user", equalTo: NCMBUser.current())
//              query?.findObjectsInBackground({ (result, error) in
//                  if error != nil {
//                      KRProgressHUD.showError(withMessage: error!.localizedDescription)
//                  } else {
//                      self.blockUserIdArray = [String]()
//                      for blockedUser in result as! [NCMBObject] {
//                        print(blockedUser)
//                        let blockedUser = blockedUser.object(forKey: "user") as! NCMBUser
//                          self.blockUserIdArray.append(blockedUser)
//                      }
//
//
//                      self.loadTimeline()
//                  }
//              })
//          }
    
    func stringFromDate(date: Date, format: String) -> String {
           let formatter: DateFormatter = DateFormatter()
           formatter.calendar = Calendar(identifier: .gregorian)
           formatter.dateFormat = format
           return formatter.string(from: date)
       }
    

}


    


/*
import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var posts = [Post]()
    var followings = [NCMBUser]()
    
    @IBOutlet var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        //nibname=ファイルと同じ名前にする
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        self.timelineTableView.rowHeight = 270
        
        timelineTableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
        
        //内容
        cell.userNameLabel.text = "サンプル"
        
        return cell
    }
    
    func loadTimeline() {
        let query = NCMBQuery(className: "Post")
        
        // 降順
        query?.order(byDescending: "createDate")
        
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
        // フォロー中の人 + 自分の投稿だけ持ってくる
        query?.whereKey("user", containedIn:followings)
        
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    
                    
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let diseaseNametext = postObject.object(forKey: "diseaseNametext") as! String
                        let countryNametext = postObject.object(forKey: "countryNametext") as! String
                        let hospitalNametext = postObject.object(forKey: "hospitalNametext") as! String
                        let medicineNametext = postObject.object(forKey: "medicineNametext") as! String
                        let symptomNametext = postObject.object(forKey: "symptomNametext") as! String
         
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        //(絶対に入っていないといけないもの)
                        let post = Post(objectId: postObject.objectId, user: userModel, symptomNametext: symptomNametext, createDate: postObject.createDate)
                        
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(NCMBUser.current().objectId) == true {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
                        }
                        
                        // いいねの件数
                        if let likes = likeUsers {
                            post.likeCount = likes.count
                        }
                        
                        // 配列に加える
                        self.posts.append(post)
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.timelineTableView.reloadData()
            }
        })
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    func loadFollowingUsers() {
         // フォロー中の人だけ持ってくる
         let query = NCMBQuery(className: "Follow")
         query?.includeKey("user")
         query?.includeKey("following")
         query?.whereKey("user", equalTo: NCMBUser.current())
         query?.findObjectsInBackground({ (result, error) in
             if error != nil {
                 SVProgressHUD.showError(withStatus: error!.localizedDescription)
             } else {
                 self.followings = [NCMBUser]()
                 for following in result as! [NCMBObject] {
                     self.followings.append(following.object(forKey: "following") as! NCMBUser)
                 }
                 self.followings.append(NCMBUser.current())
                 
                 self.loadTimeline()
             }
         })
     }
    
}
*/

//https://mbaas.api.cloud.nifty.com/2013-09-01/applications/5yX6s1kyIokIxZ54/publicFiles/MjAyMDEwMjExMTA0MDk1MzEwRkE1NzJGODYtOEU3MC00ODI0LTk1OUItQjgwMzA3QjM5RkE4

//こっち
//https://mbaas.api.nifcloud.com/2013-09-01/applications/5yX6s1kyIokIxZ54/publicFiles/MjAyMDEwMjExMTA0MDk1MzEwRkE1NzJGODYtOEU3MC00ODI0LTk1OUItQjgwMzA3QjM5RkE4
