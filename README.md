# PingDynamicSynthesizer
Auto synthesize setter getter methods for category

![](https://img.shields.io/badge/language-objc-orange.svg)

自动为你的Category中的property合成属性(setter gettter)
实现思路可参考本文:[老生常谈category增加属性的几种操作](https://www.junghsu.top)

## 功能
自动为你在category中写的property完成真正的属性合成。

支持属性修饰类型:
- [x]  strong + nonatomic
- [x]  copy + nonatomic
- [x]  weak + nonatomic
- [x]  strong + atomic
- [x]  copy + atomic
- [x]  weak + atomic

注意点: 
* category中请严格按照 ++@property (nonatomic, copy) type *name++ 规格书写。
* 目前只支持对象类型属性合成，且不支持assign关键字的修饰，对于基本数据类型可用 NSNumber 类型代替使用。

## 支持
- [x] iOS6+

## 更新
* 0.1.0 
完成除assign以外的所有的修饰词的对象类型的属性合成

## 使用方式
1. 按照规格在category.h文件中书写property

```
@property (nonatomic, copy) NSString *name;

```
2. category中遵守 DynamicPropertyDataSource 协议,并实现协议中的方法
```
@interface Person (Extra)<DynamicPropertyDataSource>

@implementation Person (Extra)

+ (NSArray *)dynamicProperty{
    return @[@"name"]; // 返回需要合成属性的key数组
}
@end
```
## 联系我

> 可以将发现的问题或有好的建议告诉我，邮箱: 1021057927@qq.com

> 可以直接在此提 Issues 与 pull

> 技术交流QQ群群员招募中 ，群IDbase64:**NjA0NjA5Mjg4**

## License

PingDynamicSynthesizer is available under the MIT license. See the LICENSE file for more info.
