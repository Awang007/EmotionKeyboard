//
//  EmotionViewViewController.swift
//  EmotionKeyboard
//
//  Created by 125154454 on 17/1/8.
//  Copyright © 2017年 125154454. All rights reserved.
//

import UIKit

class EmoticonTextAttachment: NSTextAttachment {
    // 保存对应表情的文字
    var chs: String?
 
    class func imageText(emotion: Emotion, font: UIFont) -> NSAttributedString{
        
        // 1.创建附件
        let attachment = EmoticonTextAttachment()
        attachment.chs = emotion.chs
        attachment.image = UIImage(contentsOfFile: emotion.imagePath!)
        // 设置了附件的大小
        let size = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: size, height: size)
        
        // 2. 根据附件创建属性字符串
        return NSAttributedString(attachment: attachment)
        
    }

}
