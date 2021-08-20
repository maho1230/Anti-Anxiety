//
//  SearchViewController.swift
//  Pandemic
//
//  Created by 益田 真歩 on 2020/09/28.
//  Copyright © 2020 Maho Masuda. All rights reserved.
//

import UIKit
import NCMB
import KRProgressHUD

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, TimelineTableViewCellDelegate {
    
    
    var selectedPost: NCMBObject?
    
    var users = [NCMBUser]()
    var posts = [NCMBObject]()
    
    //var followingUserIds = [String]()
    
    var searchBar: UISearchBar!
    
    @IBOutlet var searchUserTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        
        searchUserTableView.dataSource = self
        searchUserTableView.delegate = self
        
        // カスタムセルの登録
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        searchUserTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // 余計な線を消す
        searchUserTableView.tableFooterView = UIView()
        
        //引っ張って更新
        setRefreshControl()
    }
    
    //🦈5.5
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //⚠️いじった
        //if
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
        }
    }
    //🦈5.5
    
    override func viewWillAppear(_ animated: Bool) {
//        loadTimeline(searchText: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                        self.loadTimeline(searchText: self.searchBar.text)
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
                            self.loadTimeline(searchText: self.searchBar.text)
                        }
                    })
                }
            })
        }
        
    }
    
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
                                self.loadTimeline(searchText: self.searchBar.text)
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
             
        // アラートコントローラーに報告アクション、キャンセルアクションをつけるよ
            alertController.addAction(reportAction)
            alertController.addAction(cancelAction)
            }
           
            self.present(alertController, animated: true, completion: nil)
    }
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]

        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
      

    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        //let showUserViewController = segue.destination as! ShowUserViewController
//        // let selectedIndex = searchUserTableView.indexPathForSelectedRow!
//        //showUserViewController.selectedUser = users[selectedIndex.row]
//    }

    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "病名で検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        loadUsers(searchText: nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadTimeline(searchText:self.searchBar.text)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
        print("テーブルビュー呼ばれてる！")
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
        
        searchUserTableView.rowHeight = 500
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toComments", sender: nil)
        //🚄成功
//func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  //          self.performSegue(withIdentifier: "toUser", sender: nil)
        // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
//        let displayName = users[tableViewCell.tag].object(forKey: "displayName") as? String
//        let message = displayName! + "をフォローしますか？"
//        let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
//            self.follow(selectedUser: self.users[tableViewCell.tag])
//        }
//        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        }
//        alert.addAction(okAction)
//        alert.addAction(cancelAction)
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    func follow(selectedUser: NCMBUser) {
//        let object = NCMBObject(className: "Follow")
//        if let currentUser = NCMBUser.current() {
//            object?.setObject(currentUser, forKey: "user")
//            object?.setObject(selectedUser, forKey: "following")
//            object?.saveInBackground({ (error) in
//                if error != nil {
//                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
//                } else {
//                    self.loadUsers(searchText: nil)
//                }
//            })
//        } else {
//            // currentUserが空(nil)だったらログイン画面へ
//            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
//            UIApplication.shared.keyWindow?.rootViewController = rootViewController
//
//            // ログイン状態の保持
//            let ud = UserDefaults.standard
//            ud.set(false, forKey: "isLogin")
//            ud.synchronize()
//        }
//    }
    
    func loadTimeline(searchText: String?) {
        let query = NCMBQuery(className: "Post")
        //Userの情報も取ってくる、ここで絞る！
        query?.includeKey("user")
//        let query2 = NCMBUser.query()
//        let query3 = NCMBUser.query()
//        let query4 = NCMBUser.query()
//        let query5 = NCMBUser.query()
//        let query6 = NCMBUser.query()
//        let query7 = NCMBUser.query()
        // 自分を除外
        //query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
        
        // 退会済みアカウントを除外
//        query?.whereKey("active", notEqualTo: false)
        
        // 検索ワードがある場合
        if let text = searchText {
            print(text)
            query?.whereKey("DiseaseName", equalTo: text)
//            query2?.whereKey("diseaseName", equalTo: text)
//            query3?.whereKey("country", equalTo: text)
//            query4?.whereKey("hospital", equalTo: text)
//            query5?.whereKey("medicine", equalTo: text)
//            query6?.whereKey("symptom", equalTo: text)
//            query7?.whereKey("text", equalTo: text)
        } else {
            print("検索ワードがありません。")
        }
        
        // 新着ユーザー50人だけ拾う
        //query?.limit = 50
        query?.order(byDescending: "createDate")
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: "サーバー内部でエラーが発生しました。時間をおいて再度実行してください。")
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [NCMBObject]()
                print("検索結果",result)
                self.posts = result as! [NCMBObject]
                
                self.searchUserTableView.reloadData()
                
//                self.loadFollowingUserIds()
            }
        })
        
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        searchUserTableView.addSubview(refreshControl)
    }

    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        //　グルグル
        refreshControl.beginRefreshing()
        //　更新〜〜
        loadTimeline(searchText: self.searchBar.text)
        //self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }

}
