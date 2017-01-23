//
//  EmotionViewViewController.swift
//  EmotionKeyboard
//
//  Created by 125154454 on 17/1/8.
//  Copyright © 2017年 125154454. All rights reserved.
//

import UIKit

//可重用cellID
let emotionCellID = "emotionCellID"

class EmotionViewViewController: UIViewController {
    
    ///用于传递选中的表情模型
    var emotionDidSelected: (_ emotion: Emotion) -> ()
    
    ///初始化控制器同时设置闭包
    init(callBack: @escaping (_ emotion: Emotion) -> ()){
        
        self.emotionDidSelected = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.red
        //设置界面
        setupUI()
    }
    
    /** 设置界面 */
    private func setupUI() {
        
        //1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolTar)
        
        //2.布局子控制器
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolTar.translatesAutoresizingMaskIntoConstraints = false
        
        //创建一个约束数组
        var cons = [NSLayoutConstraint()]
        let dict = ["collectionView":collectionView,"toolTar":toolTar] as [String : Any]
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [NSLayoutFormatOptions(rawValue: 0)], metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolTar]-0-|", options: [NSLayoutFormatOptions(rawValue: 0)], metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-[toolTar]-0-|", options: [NSLayoutFormatOptions(rawValue: 0)], metrics: nil, views: dict)
        
        view.addConstraints(cons)
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: 懒加载
    /** 表情包表格 */
    private lazy var collectionView: UICollectionView = {
        
        let collectionV = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmotionFlowLayout())
        
        //注册cell
        collectionV.register(EmotionCell.self, forCellWithReuseIdentifier: emotionCellID)
        //设置数据源
        collectionV.dataSource = self
        collectionV.delegate = self
        
        return collectionV
    }()
    
    /** 底部视图Tabbar */
    private lazy var toolTar: UIToolbar = {
        
        let bar = UIToolbar()
        bar.tintColor = UIColor.darkGray
        var items = [UIBarButtonItem()]
        var index = 0
        for title in ["最近","默认","emoji","浪小花"]{
            
            //遍历
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(toolTarClick(item:)))
            item.tag = index
            items.append(item)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
            index = index + 1
            
        }
        items.removeLast()
        bar.items = items
        return bar
    }()
    
    /** tabar触发方法 */
    lazy var packages: [EmotionPackage] = EmotionPackage.packageList
    
    /** tabar触发方法 */
    @objc private func toolTarClick(item: UIBarButtonItem) {
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: item.tag), at: UICollectionViewScrollPosition.left, animated: true)
        
    }
    
    //MARK: -
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//MARK: -
extension EmotionViewViewController: UICollectionViewDataSource , UICollectionViewDelegate{
    //MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //设置cell个数
        return packages[section].emotions?.count ?? 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //1.取出cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emotionCellID, for: indexPath) as! EmotionCell
        
        //取出cell模型
        let package = packages[indexPath.section]
        let emotion = package.emotions![indexPath.item]
        //2.设置cell
        cell.emotion = emotion
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.red : UIColor.green
        //3.返回cell
        
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //1.获取被选中对应的表情包的对应表情
        let emotion = packages[indexPath.section].emotions![indexPath.item]
        emotion.usedTimes = emotion.usedTimes + 1
        //给"最近"表情包添加表情
        packages[0].appendCurrentEmotions(emotion: emotion)
        
        //2.执行回调当前点击表情
        emotionDidSelected(emotion)
    }
}

//MARK: -
class EmotionFlowLayout: UICollectionViewFlowLayout{
    
    override func prepare() {
        super.prepare()
        
        //1.设置item宽度
        let itemWidth = (collectionView?.bounds.width)! / 7
        itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        //2.设置item的间距
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        //3.设置滚动方向
        scrollDirection = UICollectionViewScrollDirection.horizontal
        
        //4.设置部分属性
        collectionView?.isPagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
        let margin = ((collectionView?.bounds.height)! - 3 * itemWidth) * 0.5
        
        //5.使item居中
        collectionView?.contentInset = UIEdgeInsetsMake(margin, 0, margin, 0)
        
    }
}

//MARK: -
class EmotionCell: UICollectionViewCell {
    
    ///外接表情模型
    var emotion: Emotion?{
        didSet{
            
            //1.判断是否为图片表情
            if emotion?.chs != nil{
                
                iconButton.setImage(UIImage(contentsOfFile: (emotion!.imagePath)!), for: .normal)
            } else {//防止cell重用
                
                iconButton.setImage(nil, for: UIControlState.normal)
            }
            
            //2.设置emoji表情
            iconButton.setTitle(emotion?.emojiStr ?? "", for: UIControlState.normal)
            
            //3.判断是否为删除按钮
            if emotion!.isRemoveButton {
                
                iconButton.setImage(UIImage(named: "compose_emotion_delete"), for: UIControlState.normal)
                iconButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), for: UIControlState.highlighted)
            }else {//防止cell重用
                iconButton.setImage(UIImage(named: ""), for: UIControlState.highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //初始化Cell界面
        addSubview(iconButton)
        iconButton.frame = contentView.bounds.insetBy(dx: 2, dy: 2)
        
    }
    
    //MARK: 懒加载
    private lazy var iconButton: UIButton = {
        
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        btn.backgroundColor = UIColor.white
        btn.isUserInteractionEnabled = false
        
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





