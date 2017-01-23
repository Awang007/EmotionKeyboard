//
//  ViewController.swift
//  EmotionKeyboard
//
//  Created by 125154454 on 17/1/8.
//  Copyright © 2017年 125154454. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    ///微博内容发送到服务器
    @IBAction func itemClick(_ sender: Any) {
        
        
        print("str = \(self.customTextView.emotionAttributedText())")
    }
    /** 编辑文本框 */
    @IBOutlet weak var customTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.将键盘控制器添加为当前控制器的子控制器
        addChildViewController(emotionVC)
        
        //2.将键盘控制器的视图设置为UITextView的inputView(系统键盘占用的视图)
        customTextView.inputView = emotionVC.view
        
    }
    //MARK: 懒加载
    /** 键盘控制器
     weak 相当于OC中的 __weak , 特点对象释放之后会将变量设置为nil
     unowned 相当于OC中的 unsafe_unretained, 特点对象释放之后不会将变量设置为nil
     */
    private lazy var emotionVC: EmotionViewViewController = EmotionViewViewController { [unowned self](emotion) in
        
        //TOOO
       self.customTextView.insertEmotion(emotion: emotion)
        
    }
    
    deinit {
        print("主控制器被释放!")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

