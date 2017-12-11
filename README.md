# PingDynamicSynthesizer
Auto synthesize setter getter methods for category

[![Version](https://img.shields.io/cocoapods/v/PingDynamicSynthesizer.svg?style=flat)](http://cocoapods.org/pods/PingDynamicSynthesizer)
[![Pod License](http://img.shields.io/cocoapods/l/PingDynamicSynthesizer.svg?style=flat)](https://opensource.org/licenses/MIT)
![](https://img.shields.io/badge/language-objc-orange.svg)
![iOS 6.0+](https://img.shields.io/badge/iOS-6.0%2B-blue.svg)

自动为你的Category中的property合成属性(setter gettter)
实现思路可参考本文:[老生常谈category增加属性的几种操作](https://www.junghsu.top)

## 功能
自动为你在category中写的property完成真正的属性合成。

支持主流的JSON转MODEL库。

支持属性修饰类型:
- [x]  strong + nonatomic
- [x]  copy + nonatomic
- [x]  weak + nonatomic
- [x]  strong + atomic
- [x]  copy + atomic
- [x]  weak + atomic

注意点: 
* category中请严格按照 @property (nonatomic, copy) type *name 规格书写。
* 目前只支持对象类型属性合成，且不支持assign关键字的修饰，对于基本数据类型可用 NSNumber 类型代替使用。



## 更新
* 0.1.0 

完成除assign以外的所有的修饰词的对象类型的属性合成

* 0.1.1

协议方法改为 @optional ，在不实现协议方法时，自动合成所有没有实现setter或getter的property，包括继承父类的property，如果想要保证自定义返回需要合成的property，请实现协议中的方法返回key的数组。

## 使用方式
1. 按照规格在category.h文件中书写property

```
@property (nonatomic, copy) NSString *name;

```
2. category中遵守 DynamicPropertyDataSource 协议,并实现协议中的方法
```
@interface Person (Extra)<DynamicPropertyDataSource>

@implementation Person (Extra)

// 可不实现，自动合成所有没有实现setter或getter的property，包括继承父类的property
+ (NSArray *)dynamicProperty{
    return @[@"name"]; // 返回需要合成属性的key数组
}
@end
```

## 支持Cocoapods
```
pod 'PingDynamicSynthesizer'
```
* 如果你使用 pod search 命令搜不到，请执行下面的命令更新自己的 cocoapods 官方索引库:

```
pod repo update
```

## 联系我

> 可以将发现的问题或有好的建议告诉我，邮箱: 1021057927@qq.com

> 可以直接在此提 Issues 与 pull

> 技术交流QQ群群员招募中 ，群IDbase64:**NjA0NjA5Mjg4**

## License

PingDynamicSynthesizer is available under the MIT license. See the LICENSE file for more info.
