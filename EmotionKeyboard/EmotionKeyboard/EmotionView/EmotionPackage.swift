//
//  EmotionPackage.swift
//  EmotionKeyboard
//
//  Created by 125154454 on 17/1/8.
//  Copyright © 2017年 125154454. All rights reserved.
//

/*
 结构:
 1. 加载emoticons.plist拿到每组表情的路径
 
 emoticons.plist(字典)  存储了所有组表情的数据
 |----packages(字典数组)
 |-------id(存储了对应组表情对应的文件夹)
 
 2. 根据拿到的路径加载对应组表情的info.plist
 info.plist(字典)
 |----id(当前组表情文件夹的名称)
 |----group_name_cn(组的名称)
 |----emoticons(字典数组, 里面存储了所有表情)
 |----chs(表情对应的文字)
 |----png(表情对应的图片)
 |----code(emoji表情对应的十六进制字符串)
 
 */

import UIKit

class EmotionPackage: NSObject {
    
    ///当前组表情文件的名称
    var id:String?
    ///组名称
    var group_name_cn: String?
    ///当前所有表情对象模型
    var emotions: [Emotion]?
    
    ///创建一个表情包单例 ( 保证表情包只加载一次 )
    static let packageList: [EmotionPackage] = EmotionPackage.loadPackages()
    ///获取所有组的表情数组
    private class func loadPackages() -> [EmotionPackage]{

        //0.创建一个存储数组
        var packages = [EmotionPackage]()
        
        //0.1创建"最近"数组包
        let currentPk = EmotionPackage(id: "")
        currentPk.group_name_cn = "最近"
        currentPk.emotions = [Emotion]()
        currentPk.appendEmtyEmotions()
        //添加到数组中
        packages.append(currentPk)
        
        //1.获取文件路径
        let path = Bundle.main.path(forResource: "emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")
        
        //2.加载plist文件
        let dict = NSDictionary(contentsOfFile: path!)!
        
        //3.获取package
        let dictArray = dict["packages"] as! [[String : AnyObject]]

        for dic in dictArray {//dictArray里面有三个文件夹里的表情包
            
            //4.取出ID,创建对应数组 (获取每个表情包)
            let package = EmotionPackage(id: dic["id"] as! String)
            packages.append(package)
            
            //5.加载每一组所有的表情
            package.loadEmotions()
            
            //6.添加空按钮
            package.appendEmtyEmotions()
        }
        
        return packages
    }
    
    ///加载每一组所有的表情
    func loadEmotions() {
        
        //1.获取info.plist对应的字典
        let emotionDict = NSDictionary(contentsOfFile: infoPath(fileName: "info.plist"))!
        group_name_cn = emotionDict["group_name_cn"] as? String
        
        let dictArray = emotionDict["emoticons"] as! [[String: String]]
        emotions = [Emotion]()
        var index = 0
        for dic in dictArray {//把每一组的表情包遍历出来
            
            if index == 20{
                
                //给最后一个cell添加删除按钮图标
                emotions?.append(Emotion(isRemoveButton: true))
                index = 0
            }
            emotions?.append(Emotion(dict: dic, id: id!))
            index += 1
        }
    }
    
    
    ///追加空白按钮,如果一页不足21个,那么就添加一些空白按钮补齐
    func appendEmtyEmotions() {
        
        let count = emotions!.count % 21
        
        for _ in count..<20 {
            //追加空白按钮
            emotions?.append(Emotion(isRemoveButton: false))
        }
        
        //追加一个删除按钮
        emotions?.append(Emotion(isRemoveButton: true))
        
    }
    
    ///用于给最近添加表情
    func appendCurrentEmotions(emotion: Emotion){
    
        //1.判断是否是删除按钮
        if emotion.isRemoveButton{
        
            return
        }
        
        //2.判断当前点击的表情是否已经添加到最近数组中
        let contains = emotions!.contains(emotion)
        if !contains{
        
            //删除"删除"按钮
            emotions?.removeLast()
            //追加新表情
            emotions?.append(emotion)
        }
        
        //3.对数组进行排序
        var result = emotions?.sorted(by: { (e1, e2) -> Bool in
            return e1.usedTimes > e2.usedTimes
        })
        
        //4.删除多余表情
        if !contains{
        
            result?.removeLast()
            //添加一个删除按钮
            result?.append(Emotion(isRemoveButton: true))
        }
        
        emotions = result
    
        
    }
    
    ///获取指定文件的全路径
    func infoPath(fileName: String) -> String  {
        
        return (EmotionPackage.emotionPath().appendingPathComponent(id!) as NSString).appendingPathComponent(fileName)
    }
    
    ///获取微博表情的主路径
    class func emotionPath() -> NSString  {
        
        return (Bundle.main.bundlePath as NSString).appendingPathComponent("Emoticons.bundle") as NSString
    }
    
    
    init(id: String) {
        
        self.id = id
    }
}

class Emotion: NSObject {
    
    ///表情对应的文字
    var chs: String?
    ///表情对应的图片
    var png: String?{
        
        didSet{
            imagePath = (EmotionPackage.emotionPath().appendingPathComponent(id!) as NSString).appendingPathComponent(png!)
            
        }
    }
    
    ///emoji对应的字符串
    var emojiStr: String?
    ///emoji对应的十六进制
    var code: String?{
        
        didSet{
            
            // 1.从字符串中取出十六进制的数
            // 创建一个扫描器, 扫描器可以从字符串中提取我们想要的数据
            let scanner = Scanner(string: code!)
            
            // 2.将十六进制转换为字符串
            var result:UInt32 = 0
            scanner.scanHexInt32(&result)
            
            // 3.将十六进制转换为emoji字符串
            emojiStr = "\(Character(UnicodeScalar(result)!))"
        }
    }
    
    ///当前表情对应的文件夹
    var id: String?
    
    ///图片全路径
    var imagePath: String?
    
    ///是否为删除按钮的标志
    var isRemoveButton: Bool = false
    
    ///记录当前表情被使用的次数(用于排名参考)
    var usedTimes: Int = 0
    
    //初始化删除按钮构造函数
    init(isRemoveButton: Bool) {
        super.init()
        self.isRemoveButton = isRemoveButton
    }
    
    //字典转模型构造函数
    init(dict: [String: String], id: String) {
        super.init()
        self.id = id
        setValuesForKeys(dict)
    }
    //忽略部分字段
    override func setValue(_ value: Any?, forUndefinedKey key: String) {    }
    
    
}

