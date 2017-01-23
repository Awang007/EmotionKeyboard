//
//  UITextView+category.swift
//  EmotionKeyboard
//
//  Created by 125154454 on 17/1/22.
//  Copyright © 2017年 125154454. All rights reserved.
//

import UIKit

extension UITextView{

    func insertEmotion(emotion: Emotion){
    
        //0.处理删除按钮
        if emotion.isRemoveButton{
        
            deleteBackward()
        }
    
        //1.判断是否为emoji表情
        if emotion.emojiStr != nil {
            
            replace(selectedTextRange!, withText: emotion.emojiStr!)
        }
        
        //2.判断当前是否是表情图片
        if emotion.png != nil {
            
            //a.创建附件,根据附件创建属性字符串
            let imageText = EmoticonTextAttachment.imageText(emotion: emotion, font: font!)
            
            //c.拿到当前所有内容
            let strM = NSMutableAttributedString(attributedString: attributedText)
            
            //d.插入表情到当前的光标所在位置
            let range = selectedRange
            strM.replaceCharacters(in: range, with: imageText)
            //设置属性字符串的默认尺寸
            strM.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(range.location, 1))
            //e.将替换后的字符串赋值给UITextView
            attributedText = strM
            
            //h.恢复光标位置
            selectedRange = NSMakeRange(range.location + 1, 0)
        }
    }

    func emotionAttributedText() -> String {
    
        var strM = String()
        attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: NSAttributedString.EnumerationOptions.init(rawValue: 0)) { (obj, range, _) in
            
            if obj["NSAttachment"] != nil{//NSTextAttachment
                
                let attachment = obj["NSAttachment"] as! EmoticonTextAttachment
                
                strM += attachment.chs!
            }else {
                //拼接文字
                strM += (text as NSString).substring(with: range)
            }
        }
        
        return strM
    }

}
