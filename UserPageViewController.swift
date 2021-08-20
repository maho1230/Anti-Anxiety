//
//  UserPageViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/09.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import KRProgressHUD

class UserPageViewController: UIViewController, UICollectionViewDataSource {
    
    var posts = [Post]()
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var photoCollectionView: UICollectionView!
    
    
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    
    @IBOutlet var profileButton: UIButton!
    
    @IBOutlet var birthdayLabel: UILabel!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.dataSource = self
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        let layout = UICollectionViewFlowLayout()
        
        
        // 例えば端末サイズの半分の width と height にして 2 列にする場合
        let width: CGFloat = UIScreen.main.bounds.width / 3
        let height = width
        layout.itemSize = CGSize(width: width, height: height)
        photoCollectionView.collectionViewLayout = layout
        photoCollectionView.backgroundColor = .white
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadPosts()
        
        loadFollowingInfo()
        
        //let user = NCMBUser.current()
        
        if let user = NCMBUser.current() {
            userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
            userIntroductionTextView.text = user.object(forKey: "introduction") as? String
            birthdayLabel.text = user.object(forKey: "birthday") as? String
            self.navigationItem.title = user.userName
                   
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("数！！")
        print(posts.count)
      return posts.count
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath)
        let photoImageView = cell.viewWithTag(5) as! UIImageView
        let photoImagePath = posts[indexPath.row].imageUrl
       
        
        // photoImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 100)
        
        photoImageView.kf.setImage(with: URL(string: photoImagePath))
        //cell.backgroundColor = UIColor.lightGray
        
        
        return cell
    }
    
    @IBAction func showMenu() {
        let alertController = UIAlertController(title: "メニュー", message: "メニューを選択してください", preferredStyle: .actionSheet)
        //🦈
        alertController.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        //🦈
        let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground ({ (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
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
            })
        }
        
        let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
            
            let alert = UIAlertController(title: "会員登録の解除", message: "本当に退会しますか？退会した場合、再度このアカウントをご利用頂くことができません。", preferredStyle: .alert)
            //🦈
            alert.popoverPresentationController?.sourceView = self.view
            
            let screenSize = UIScreen.main.bounds
            // ここで表示位置を調整
            // xは画面中央、yは画面下部になる様に指定
            alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
            //🦈
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                // ユーザーのアクティブ状態をfalseに
                if let user = NCMBUser.current() {
                 user.setObject(false, forKey: "active")
                 user.saveInBackground({ (error) in
                    if error != nil {
                        KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
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
            })
        } else {
                // userがnilだった場合ログイン画面に移動
                let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                
                // ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(false, forKey: "isLogin")
                ud.synchronize()
            }
            
        })
            
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(signOutAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
        
        
        func loadPosts() {
            let query = NCMBQuery(className: "Post")
            query?.includeKey("user")
            query?.order(byDescending: "createDate")
            query?.whereKey("user", equalTo: NCMBUser.current())
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    KRProgressHUD.showError( withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                } else {
                    self.posts = [Post]()
                    
                    for postObject in result as! [NCMBObject] {
                        // ユーザー情報をUserクラスにセット
                        let user = postObject.object(forKey: "user") as! NCMBUser
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let text = postObject.object(forKey: "text") as! String
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
                        
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUser = postObject.object(forKey: "likeUser") as? [String]
                        if likeUser?.contains(NCMBUser.current().objectId) == true {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
                        }
                        // 配列に加える
                        self.posts.append(post)
                        
                    }
                    
                    // post数を表示
                    self.postCountLabel.text = String(self.posts.count)
                    //原因ここやで〜！
                    self.photoCollectionView.reloadData()
                    
                }
            })
            
        }
        
        
        func loadFollowingInfo() {
            // フォロー中
            let followingQuery = NCMBQuery(className: "Follow")
            followingQuery?.includeKey("user")
            followingQuery?.whereKey("user", equalTo: NCMBUser.current())
            followingQuery?.countObjectsInBackground({ (count, error) in
                if error != nil {
                    KRProgressHUD.showError( withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                } else {
                    // 非同期通信後のUIの更新はメインスレッドで
                    DispatchQueue.main.async {
                        self.followingCountLabel.text = String(count)
                    }
                }
            })
            
            // フォロワー
            let followerQuery = NCMBQuery(className: "Follow")
            followerQuery?.includeKey("following")
            followerQuery?.whereKey("following", equalTo: NCMBUser.current())
            followerQuery?.countObjectsInBackground({ (count, error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
                } else {
                    DispatchQueue.main.async {
                        // 非同期通信後のUIの更新はメインスレッドで
                        self.followerCountLabel.text = String(count)
                    }
                }
            })
        }
        
    }
    



/*
 import UIKit
 import NCMB
 import Kingfisher
 import SVProgressHUD
 
 
 var posts = [Post]()
 var followings = [NCMBUser]()
 
 class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimelineTableViewCellDelegate {
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 <#code#>
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 <#code#>
 }
 
 
 @IBOutlet var userImageView: UIImageView!
 
 @IBOutlet var userDisplayNameLabel: UILabel!
 
 @IBOutlet var userIntroductionTextView: UITextView!
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 
 loadPosts()
 
 
 loadFollowingInfo()
 
 
 
 
 
 userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
 userImageView.layer.masksToBounds = true
 }
 
 override func viewWillAppear(_ animated: Bool) {
 
 
 if let user = NCMBUser.current(){
 userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
 userIntroductionTextView.text = user.object(forKey: "introduction") as? String
 self.navigationItem.title = user.userName
 
 let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: nil) as! NCMBFile
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
 
 
 
 @IBAction func showMenu() {
 let alertController = UIAlertController(title: "メニュー", message: "メニューを選択してください", preferredStyle: .actionSheet)
 let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
 NCMBUser.logOutInBackground { (error) in
 if error != nil {
 print(error)
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
 }
 
 let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
 let user = NCMBUser.current()
 user?.deleteInBackground({ (error) in
 if error != nil {
 print(error)
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
 })
 }
 
 let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
 alertController.dismiss(animated: true, completion: nil)
 }
 
 alertController.addAction(signOutAction)
 alertController.addAction(deleteAction)
 alertController.addAction(cancelAction)
 
 self.present(alertController, animated: true, completion: nil)
 
 
 func loadPosts() {
 let query = NCMBQuery(className: "Post")
 query?.includeKey("user")
 query?.whereKey("user", equalTo: NCMBUser.current())
 query?.findObjectsInBackground({ (result, error) in
 if error != nil {
 SVProgressHUD.showError(withStatus: error!.localizedDescription)
 } else {
 self.posts = [Post]()
 
 
 for postObject in result as! [NCMBObject] {
 // ユーザー情報をUserクラスにセット
 let user = postObject.object(forKey: "user") as! NCMBUser
 let userModel = User(objectId: user.objectId, userName: user.userName)
 userModel.displayName = user.object(forKey: "displayName") as? String
 
 // 投稿の情報を取得
 let imageUrl = postObject.object(forKey: "imageUrl") as! String
 let text = postObject.object(forKey: "text") as! String
 
 // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
 let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
 
 // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
 let likeUser = postObject.object(forKey: "likeUser") as? [String]
 if likeUser?.contains(NCMBUser.current().objectId) == true {
 post.isLiked = true
 } else {
 post.isLiked = false
 }
 // 配列に加える
 self.posts.append(post)
 
 }
 self.photoCollectionView.reloadData()
 
 
 // post数を表示
 self.postCountLabel.text = String(self.posts.count)
 
 
 }
 })
 
 }
 
 
 
 func loadFollowingInfo() {
 
 // フォロー中
 let followingQuery = NCMBQuery(className: "Follow")
 followingQuery?.includeKey("user")
 followingQuery?.whereKey("user", equalTo: NCMBUser.current())
 followingQuery?.countObjectsInBackground({ (count, error) in
 if error != nil {
 SVProgressHUD.showError(withStatus: error!.localizedDescription)
 } else {
 // 非同期通信後のUIの更新はメインスレッドで
 DispatchQueue.main.async {
 self.followingCountLabel.text = String(count)
 
 
 }
 }
 })
 
 
 // フォロワー
 let followerQuery = NCMBQuery(className: "Follow")
 followerQuery?.includeKey("following")
 followerQuery?.whereKey("following", equalTo: NCMBUser.current())
 followerQuery?.countObjectsInBackground({ (count, error) in
 if error != nil {
 SVProgressHUD.showError(withStatus: error!.localizedDescription)
 } else {
 DispatchQueue.main.async {
 // 非同期通信後のUIの更新はメインスレッドで
 self.followerCountLabel.text = String(count)
 
 
 }
 }
 })
 }
 
 }
 
 /*
 import UIKit
 import NCMB
 import Kingfisher
 import SVProgressHUD
 //宣言の三つのdelegate,セル上に押されたものをセルではなく別のクラスに任せる
 class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimelineTableViewCellDelegate {
 
 var selectedPost: Post?
 var posts = [Post]()
 var followings = [NCMBUser]()
 
 @IBOutlet var timelineTableView: UITableView!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 timelineTableView.dataSource = self
 timelineTableView.delegate = self
 //nibを使ってxibを取得
 let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
 timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
 //不要な線削除
 timelineTableView.tableFooterView = UIView()
 // 引っ張って更新
 setRefreshControl()
 // フォロー中のユーザーを取得する。その後にフォロー中のユーザーの投稿のみ読み込み
 loadFollowingUsers()
 }
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 if segue.identifier == "toComments" {
 let commentViewController = segue.destination as! CommentViewController
 commentViewController.postId = selectedPost?.objectId
 }
 }
 
 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return posts.count//配列の数
 }
 
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
 cell.delegate = self
 cell.tag = indexPath.row
 let user = posts[indexPath.row].user
 cell.userNameLabel.text = user.displayName//ユーザー名前表示
 let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/8SyEVZsgOk882YFh/publicFiles/" + user.objectId
 //    cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder"))
 cell.userImageView.kf.setImage(with: URL(string: userImageUrl))
 cell.commentTextView.text = posts[indexPath.row].text
 let imageUrl = posts[indexPath.row].imageUrl
 print(imageUrl + "キキキ")
 cell.photoImageView.kf.setImage(with: URL(string: imageUrl))
 
 // Likeによってハートの表示を変えるok
 if posts[indexPath.row].isLiked == true {
 cell.likeButton.setImage(UIImage(named: "heart-outline"), for: .normal)
 } else {
 cell.likeButton.setImage(UIImage(named: "heart"), for: .normal)
 }
 
 // Likeの数
 cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
 print(cell.likeCountLabel.text)
 // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
 //cell.timestampLabel.text = posts[indexPath.row].createDate.string()
 return cell
 }
 
 func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {//delegateにより必要(どのセルが押されたか、どのボタンか)
 //NCMBUser.current()をnilにさせないため
 guard let currentUser = NCMBUser.current() else {
 //ログインに戻る
 let storyboard = UIStoryboard(name: "Signin", bundle: Bundle.main)
 let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")//SignIn.storyboardのnavigationに設定しているstoryboard ID
 UIApplication.shared.keyWindow?.rootViewController = rootViewController
 //ログイン状態の保持
 let ud = UserDefaults.standard
 ud.set(false, forKey: "isLogin") //scenedelegateの20のisloginをfalse
 ud.synchronize()
 return
 }
 if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
 let query = NCMBQuery(className: "Post")
 query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
 post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")//自分というオブジェクトを一つだけ追加
 post?.saveEventually({ (error) in
 if error != nil {
 SVProgressHUD.showError(withStatus:  error!.localizedDescription)
 } else {
 self.loadTimeline()
 }
 })
 })
 } else {
 let query = NCMBQuery(className: "Post")
 query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
 if error != nil {
 SVProgressHUD.showError(withStatus:  error!.localizedDescription)
 } else {
 post?.removeObjects(in: [currentUser.objectId!], forKey: "likeUser")
 post?.saveEventually({ (error) in
 if error != nil {
 SVProgressHUD.showError(withStatus:  error!.localizedDescription)
 } else {
 self.loadTimeline()
 }
 })
 }
 })
 }
 }
 func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {//delegateにより必要
 let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
 let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
 SVProgressHUD.show()
 let query = NCMBQuery(className: "Post")
 query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
 if error != nil {
 SVProgressHUD.showError(withStatus:  error!.localizedDescription)
 } else {
 // 取得した投稿オブジェクトを削除
 post?.deleteInBackground({ (error) in
 if error != nil {
 SVProgressHUD.showError(withStatus:  error!.localizedDescription)
 } else {
 // 再読込
 self.loadTimeline()
 SVProgressHUD.dismiss()
 }
 })
 }
 })
 }
 let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
 SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
 }
 let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
 alertController.dismiss(animated: true, completion: nil)
 }
 if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
 // 自分の投稿なので、削除ボタンを出す
 alertController.addAction(deleteAction)
 } else {
 // 他人の投稿なので、報告ボタンを出す
 alertController.addAction(reportAction)
 }
 alertController.addAction(cancelAction)
 self.present(alertController, animated: true, completion: nil)
 }
 func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {//delegateにより必要
 // 選ばれた投稿を一時的に格納
 selectedPost = posts[tableViewCell.tag]
 // 遷移させる(このとき、prepareForSegue関数で値を渡す)
 self.performSegue(withIdentifier: "toComments", sender: nil)
 }
 func loadTimeline() {
 guard let currentUser = NCMBUser.current() else {
 //ログインに戻る
 let storyboard = UIStoryboard(name: "Signin", bundle: Bundle.main)
 let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")//Signin.storyboardのnavigationに設定しているstoryboard ID
 UIApplication.shared.keyWindow?.rootViewController = rootViewController
 //ログイン状態の保持
 let ud = UserDefaults.standard
 ud.set(false, forKey: "isLogin") //scenedelegateの20のisloginをfalse
 ud.synchronize()
 return
 }
 //データを取ってくる時query
 let query = NCMBQuery(className: "Post")
 // 降順
 query?.order(byDescending: "createDate")
 // 投稿したユーザーの情報も同時取得
 query?.includeKey("user")
 // フォロー中の人 + 自分の投稿だけ持ってくる
 query?.whereKey("user", containedIn: followings)
 // オブジェクトの取得
 query?.findObjectsInBackground({ (result, error) in
 if error != nil {//データが取れたらresultに格納
 SVProgressHUD.showError(withStatus:  error!.localizedDescription)
 } else {
 // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
 //resultに入った値をposts配列へ
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
 print(imageUrl + "あはは")
 //            print(currentUser)
 //            print(postObject)
 let text = postObject.object(forKey: "text") as! String
 // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
 let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
 //print(post)
 // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
 let likeUsers = postObject.object(forKey: "likeUser") as? [String]
 if likeUsers?.contains(currentUser.objectId) == true {
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
 func setRefreshControl() {//引っ張って更新ok
 let refreshControl = UIRefreshControl()
 refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
 timelineTableView.addSubview(refreshControl)
 }
 //
 @objc func reloadTimeline(refreshControl: UIRefreshControl) {
 refreshControl.beginRefreshing()
 //self.loadFollowingUsers()
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
 SVProgressHUD.showError(withStatus:  error!.localizedDescription)
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
 
 /*
 import UIKit
 import NCMB
 import Kingfisher
 import SVProgressHUD
 
 
 var posts = [Post]()
 var followings = [NCMBUser]()
 @IBOutlet var userImageView: UIImageView!
 
 @IBOutlet var userDisplayNameLabel: UILabel!
 
 @IBOutlet var userIntroductionTextView: UITextView!
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 
 loadPosts()
 
 loadFollowingInfo()
 
 
 
 
 userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
 userImageView.layer.masksToBounds = true
 }
 
 override func viewWillAppear(_ animated: Bool) {
 
 
 if let user = NCMBUser.current(){
 userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
 userIntroductionTextView.text = user.object(forKey: "introduction") as? String
 self.navigationItem.title = user.userName
 
 let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: nil) as! NCMBFile
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
 
 
 
 @IBAction func showMenu() {
 let alertController = UIAlertController(title: "メニュー", message: "メニューを選択してください", preferredStyle: .actionSheet)
 let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
 NCMBUser.logOutInBackground { (error) in
 if error != nil {
 print(error)
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
 }
 
 let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
 let user = NCMBUser.current()
 user?.deleteInBackground({ (error) in
 if error != nil {
 print(error)
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
 })
 }
 
 let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
 alertController.dismiss(animated: true, completion: nil)
 }
 
 alertController.addAction(signOutAction)
 alertController.addAction(deleteAction)
 alertController.addAction(cancelAction)
 
 self.present(alertController, animated: true, completion: nil)
 
 
 func loadPosts() {
 let query = NCMBQuery(className: "Post")
 query?.includeKey("user")
 query?.whereKey("user", equalTo: NCMBUser.current())
 query?.findObjectsInBackground({ (result, error) in
 if error != nil {
 SVProgressHUD.showError(withStatus: error!.localizedDescription)
 } else {
 self.posts = [Post]()
 
 for postObject in result as! [NCMBObject] {
 // ユーザー情報をUserクラスにセット
 let user = postObject.object(forKey: "user") as! NCMBUser
 let userModel = User(objectId: user.objectId, userName: user.userName)
 userModel.displayName = user.object(forKey: "displayName") as? String
 
 // 投稿の情報を取得
 let imageUrl = postObject.object(forKey: "imageUrl") as! String
 let text = postObject.object(forKey: "text") as! String
 
 // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
 let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
 
 // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
 let likeUser = postObject.object(forKey: "likeUser") as? [String]
 if likeUser?.contains(NCMBUser.current().objectId) == true {
 post.isLiked = true
 } else {
 post.isLiked = false
 }
 // 配列に加える
 self.posts.append(post)
 }
 self.photoCollectionView.reloadData()
 
 // post数を表示
 self.postCountLabel.text = String(self.posts.count)
 
 }
 })
 
 }
 
 
 
 func loadFollowingInfo() {
 
 // フォロー中
 let followingQuery = NCMBQuery(className: "Follow")
 followingQuery?.includeKey("user")
 followingQuery?.whereKey("user", equalTo: NCMBUser.current())
 followingQuery?.countObjectsInBackground({ (count, error) in
 if error != nil {
 SVProgressHUD.showError(withStatus: error!.localizedDescription)
 } else {
 // 非同期通信後のUIの更新はメインスレッドで
 DispatchQueue.main.async {
 self.followingCountLabel.text = String(count)
 
 }
 }
 })
 
 
 // フォロワー
 let followerQuery = NCMBQuery(className: "Follow")
 followerQuery?.includeKey("following")
 followerQuery?.whereKey("following", equalTo: NCMBUser.current())
 followerQuery?.countObjectsInBackground({ (count, error) in
 if error != nil {
 SVProgressHUD.showError(withStatus: error!.localizedDescription)
 } else {
 DispatchQueue.main.async {
 // 非同期通信後のUIの更新はメインスレッドで
 self.followerCountLabel.text = String(count)
 
 }
 }
 })
 }
 
 }
 */*/*/
