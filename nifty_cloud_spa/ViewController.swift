//
//  ViewController.swift
//  nifty_cloud_spa
//
//  Created by 酒井文也 on 2016/01/29.
//  Copyright © 2016年 just1factory. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //一覧表示テーブルビュー
    @IBOutlet var memoTableView: UITableView!

    //コメント編集フラグ
    var editFlag: Bool = false
    
    //テーブルビューの要素数
    let sectionCount: Int = 1
    
    //対象MemoのobjectId
    var targetMemoObjectId: String!
    
    //Memoデータを格納する場所
    var memoArray: NSArray = NSArray()
    
    override func viewWillAppear(animated: Bool) {
        self.loadMemoData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルビューのデリゲート
        self.memoTableView.delegate = self
        self.memoTableView.dataSource = self
        
        //Xibのクラスを読み込む宣言を行う
        let nib: UINib = UINib(nibName: "MemoCell", bundle: nil)
        self.memoTableView.registerNib(nib, forCellReuseIdentifier: "MemoCell")
        
        //自動計算の場合は必要
        self.memoTableView.estimatedRowHeight = 380.0
        self.memoTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //テーブルの要素数を設定する ※必須
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //取得データの総数
        if self.memoArray.count > 0 {
            return self.memoArray.count
        } else {
            return 0
        }
    }
    
    //表示するセルの中身を設定する ※必須
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemoCell") as? MemoCell
        
        //各値をセルに入れる
        let targetMemoData: AnyObject = self.memoArray[indexPath.row]
        print(targetMemoData)
        
        cell!.memoTitle.text = targetMemoData.objectForKey("title") as? String
        cell!.memoMoney.text = String(targetMemoData.objectForKey("money")!)
        cell!.memoComment.text = targetMemoData.objectForKey("comment") as? String
        
        cell!.memoImage.image = nil
        
        //画像データの取得
        let filename: String = (targetMemoData.objectForKey("filename") as? String)!
        let fileData = NCMBFile.fileWithName(filename, data: nil) as! NCMBFile
        
        fileData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
            
            if error != nil {
                print("写真の取得失敗: \(error)")
            } else {
                cell!.memoImage.image = UIImage(data: imageData!)
            }
        }
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.accessoryType = UITableViewCellAccessoryType.None
        
        return cell!
    }
    
    //セルをタップした時に呼び出される
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //セグエの実行時に値を渡す
        let targetMemoData: AnyObject = self.memoArray[indexPath.row]
        
        self.editFlag = true
        performSegueWithIdentifier("goAddMemo", sender: targetMemoData)
    }
    
    //テーブルのセクションを設定する ※必須
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionCount
    }
    
    //segueを呼び出したときに呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //コメント表示画面へ行く前に詳細データを渡す
        if segue.identifier == "goAddMemo" {
            
            let addController = segue.destinationViewController as! AddController
            
            //編集の際は編集対象のobjectIdと編集フラグ・編集対象のデータを設定する
            if self.editFlag == true {
                addController.editFlag = self.editFlag
                addController.targetData = sender
            }
        }
    }
    
    //新規追加時のアクション
    @IBAction func addMemoAction(sender: UIBarButtonItem) {
        self.editFlag = false
        performSegueWithIdentifier("goAddMemo", sender: nil)
    }
    
    //データのリロード
    func loadMemoData() {
        
        /**
         * Just FYI
         *
         * Example: 文字列と一致する場合
         * query.whereKey("title", equalTo: "xxx")
         *
         * メソッドのインターフェイスについて:
         * NCMBQuery.hを参照するとNCMBQueryのインスタンスメソッドの引数にとるべき値等が見れます。
         *
         */
        
        let query: NCMBQuery = NCMBQuery(className: "MemoClass")
        query.orderByDescending("createDate")
        query.findObjectsInBackgroundWithBlock({(NSArray objects, NSError error) in
            
            if error == nil {
                
                if objects.count > 0 {
                    
                    self.memoArray = objects
                    
                    //テーブルビューをリロードする
                    self.memoTableView.reloadData()
                }
                
            } else {
                print(error.localizedDescription)
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

