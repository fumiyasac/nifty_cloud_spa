//
//  AddController.swift
//  nifty_cloud_spa
//
//  Created by 酒井文也 on 2016/02/01.
//  Copyright © 2016年 just1factory. All rights reserved.
//

import UIKit

class AddController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //編集フラグ
    var editFlag: Bool = false
    
    //編集対象メモのobjectId
    var targetMemoObjectId: String = ""
    
    //編集対象メモのfilename
    var targetFileName: String = ""
    
    //ViewController.swiftから渡されたデータ
    var targetData: AnyObject!
    
    //画面配置要素
    @IBOutlet var titleField: UITextField!
    @IBOutlet var moneyField: UITextField!
    @IBOutlet var commnetField: UITextField!
    @IBOutlet var displayImage: UIImageView!
    
    @IBOutlet var deleteButton: UIBarButtonItem!
    
    //更新・追加・削除用のメンバ変数
    var targetTitle: String = ""
    var targetMoney: String = ""
    var targetCommnet: String = ""
    var targetDisplayImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITextFieldのプレースホルダーを設定
        self.titleField.placeholder = "(例）ラーメン二郎"
        self.moneyField.placeholder = "(例）900"
        self.commnetField.placeholder = "(例）激しく食べ過ぎました...反省"
        
        //金額の部分は数字のキーボードにする
        self.moneyField.keyboardType = UIKeyboardType.NumberPad
        
        //UITextFieldのデリゲートの設定
        self.titleField.delegate = self
        self.moneyField.delegate = self
        self.commnetField.delegate = self
        
        //追加・編集での入力状態の制御
        if self.editFlag == true {

            //更新対象のobjectIdを入力
            self.targetMemoObjectId = self.targetData!.objectForKey("objectId") as! String
            
            //UITextFieldに値を入れた状態にしておく
            self.titleField.text = self.targetData!.objectForKey("title") as? String
            self.moneyField.text = self.targetData!.objectForKey("money") as? String
            self.commnetField.text = self.targetData!.objectForKey("comment") as? String
            
            //登録されている画像イメージをセットする
            self.targetFileName = (self.targetData!.objectForKey("filename") as? String)!
            let fileData = NCMBFile.fileWithName(self.targetFileName, data: nil) as! NCMBFile
            
            fileData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if error != nil {
                    print("写真の取得失敗: \(error)")
                } else {
                    self.displayImage.image = UIImage(data: imageData!)
                }
            }
            
        } else {
            self.deleteButton.enabled = false
        }
        
    }

    //大もとのViewをタップした時のアクション
    @IBAction func hideKeyboardAction(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //前の画面に戻るアクション
    @IBAction func backListAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //追加・変更をするアクション
    @IBAction func addDataAction(sender: UIBarButtonItem) {
        
        //バリデーションを通す前の準備
        self.targetTitle = self.titleField.text!
        self.targetMoney = self.moneyField.text!
        self.targetCommnet = self.commnetField.text!
        
        self.targetDisplayImage = self.displayImage.image
        
        //Error:UIAlertControllerでエラーメッセージ表示
        if (self.targetTitle.isEmpty || self.targetMoney.isEmpty || self.targetCommnet.isEmpty || self.targetDisplayImage == nil) {
            
            //エラーのアラートを表示してOKを押すと戻る
            let errorAlert = UIAlertController(
                title: "エラー",
                message: "入力必須の項目に不備があります。",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler: nil
                )
            )
            presentViewController(errorAlert, animated: true, completion: nil)
            
        //OK:データを1件NCMBにセーブする
        } else {
            
            //保存対象の画像ファイルを作成する
            let imageData: NSData = UIImagePNGRepresentation(self.targetDisplayImage!)!
            let targetFile = NCMBFile.fileWithData(imageData) as! NCMBFile
            
            //NCMBへデータを登録・編集をする
            if self.editFlag == true {
                
                //既存データを1件更新する
                var saveError: NSError? = nil
                let obj: NCMBObject = NCMBObject(className: "MemoClass")
                obj.objectId = self.targetMemoObjectId
                obj.fetchInBackgroundWithBlock({(error) in
                    
                    if (error == nil) {
                        
                        obj.setObject(self.targetTitle, forKey: "title")
                        obj.setObject(targetFile.name, forKey: "filename")
                        obj.setObject(self.targetMoney, forKey: "money")
                        obj.setObject(self.targetCommnet, forKey: "comment")
                        obj.save(&saveError)
                        
                    } else {
                        print("データ取得処理時にエラーが発生しました: \(error)")
                    }
                })
                
                //ファイルは更新があった際のみバックグラウンドで保存する
                if targetFile.name != self.targetFileName {
                    
                    targetFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                        
                        if error == nil {
                            print("画像データ保存完了: \(targetFile.name)")
                        } else {
                            print("アップロード中にエラーが発生しました: \(error)")
                        }
                        
                        }, progressBlock: { (percentDone: Int32) -> Void in
                            
                            // 進捗状況を取得します。保存完了まで何度も呼ばれます
                            print("進捗状況: \(percentDone)% アップロード済み")
                    })
                }
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
                
            } else {
                
                //新規データを1件登録する
                var saveError: NSError? = nil
                let obj: NCMBObject = NCMBObject(className: "MemoClass")
                obj.setObject(self.targetTitle, forKey: "title")
                obj.setObject(targetFile.name, forKey: "filename")
                obj.setObject(self.targetMoney, forKey: "money")
                obj.setObject(self.targetCommnet, forKey: "comment")
                obj.save(&saveError)
                
                //ファイルはバックグラウンド実行をする
                targetFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                    
                    if error == nil {
                        print("画像データ保存完了: \(targetFile.name)")
                    } else {
                        print("アップロード中にエラーが発生しました: \(error)")
                    }
                    
                    }, progressBlock: { (percentDone: Int32) -> Void in
                        
                        // 進捗状況を取得します。保存完了まで何度も呼ばれます
                        print("進捗状況: \(percentDone)% アップロード済み")
                })
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
            }
            
            //UITextFieldを空にする
            self.titleField.text = ""
            self.moneyField.text = ""
            self.commnetField.text = ""
            
            //登録されたアラートを表示してOKを押すと戻る
            let errorAlert = UIAlertController(
                title: "完了",
                message: "入力データが登録されました。",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler: saveComplete
                )
            )
            presentViewController(errorAlert, animated: true, completion: nil)
        }
        
    }
    
    //登録が完了した際のアクション
    func saveComplete(ac: UIAlertAction) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //カメラで画像を追加するアクション
    @IBAction func displayCameraAction(sender: UIBarButtonItem) {
        
        //UIActionSheetを起動して選択させて、カメラ・フォトライブラリを起動
        let alertActionSheet = UIAlertController(
            title: "「買った物」の写真",
            message: "金額と一緒に買ったものをリマインド",
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        
        //UIActionSheetの戻り値をチェック
        alertActionSheet.addAction(
            UIAlertAction(
                title: "ライブラリから選択",
                style: UIAlertActionStyle.Default,
                handler: handlerActionSheet
            )
        )
        alertActionSheet.addAction(
            UIAlertAction(
                title: "カメラで撮影",
                style: UIAlertActionStyle.Default,
                handler: handlerActionSheet
            )
        )
        alertActionSheet.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: UIAlertActionStyle.Cancel,
                handler: handlerActionSheet
            )
        )
        presentViewController(alertActionSheet, animated: true, completion: nil)
    }
    
    //アクションシートの結果に応じて処理を変更
    func handlerActionSheet(ac: UIAlertAction) -> Void {
        
        switch ac.title! {
            
            case "ライブラリから選択":
                self.selectAndDisplayFromPhotoLibrary()
                break
            case "カメラで撮影":
                self.loadAndDisplayFromCamera()
                break
            case "キャンセル":
                break
            default:
                break
        }
    }

    //ライブラリから写真を選択してimageに書き出す
    func selectAndDisplayFromPhotoLibrary() {
        
        //フォトアルバムを表示
        let ipc = UIImagePickerController()
        ipc.allowsEditing = true
        ipc.delegate = self
        ipc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(ipc, animated: true, completion: nil)
    }
    
    //カメラで撮影してimageに書き出す
    func loadAndDisplayFromCamera() {
        
        //カメラを起動
        let ip = UIImagePickerController()
        ip.allowsEditing = true
        ip.delegate = self
        ip.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(ip, animated: true, completion: nil)
    }
    
    //画像を選択した時のイベント
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        //画像をセットして戻る
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //リサイズして表示する
        let resizedImage = CGRectMake(
            image.size.width / 4.0,
            image.size.height / 4.0,
            image.size.width / 2.0,
            image.size.height / 2.0
        )
        
        let cgImage = CGImageCreateWithImageInRect(image.CGImage, resizedImage)
        self.displayImage.image = UIImage(CGImage: cgImage!)
    }
    
    //削除をするアクション
    @IBAction func deleteDataAction(sender: UIBarButtonItem) {
        
        let obj: NCMBObject = NCMBObject(className: "MemoClass")
        obj.objectId = self.targetMemoObjectId
        obj.fetchInBackgroundWithBlock({(error) in
            
            if (error == nil) {
                
                obj.deleteInBackgroundWithBlock({(error) in
                    
                    if (error == nil) {
                        
                        //削除成功時に画像も一緒に削除する
                        let fileData = NCMBFile.fileWithName(self.targetFileName, data: nil) as! NCMBFile
                        fileData.deleteInBackgroundWithBlock({(error) in
                            print("画像データ削除完了: \(self.targetFileName)")
                        })
                        
                    }
                })
                
            } else {
                print("データ取得処理時にエラーが発生しました: \(error)")
            }
        })

        //UITextFieldを空にする
        self.titleField.text = ""
        self.moneyField.text = ""
        self.commnetField.text = ""
        
        //登録されたアラートを表示してOKを押すと戻る
        let errorAlert = UIAlertController(
            title: "完了",
            message: "このデータは削除されました。",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        errorAlert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: saveComplete
            )
        )
        presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
