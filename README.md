# JLLabel
用CoreText实现类似微博那样可以点击的文字，自动识别@，＃，http(s)等特殊字符串
```objc
JLLabel *contentLabel = [[JLLabel alloc] init];
contentLabel.font = kTextFont;
contentLabel.tapCallBack = ^(NSString *string,NSRange range,NSDictionary *info){
            
     NSLog(@"点击的字符串是:%@",string);
     NSLog(@"点击的字符串的范围是:%@",[NSValue valueWithRange:range]);
  
 };
[self.contentView addSubview:contentLabel];
 
```
效果如下：

![效果图](https://github.com/JlongTian/JLLabel/blob/master/images/show.gif)
