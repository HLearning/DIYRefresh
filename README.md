# DIYRefresh
- 可以个性化定制的下拉刷新框架
- 语言: swift3.0

# 效果展示
DIYRefresh.gif![效果图](https://github.com/huangjinlei/DIYRefresh/blob/master/DIYRefreshDemo/DIYRefresh.gif)
# 集成框架
- clone项目到本地, 打开项目, 将DIYRefresh文件夹拖到你的项目代码中即可

# 使用框架
- DIYRefreshView是一个UIView类, 在使用的过程中, 只需要创建一个DIYRefreshView的对象即可
### 创建DIYRefreshView(框架支持三种创建方式)
方式1和方式2为简单的创建方式, 屏蔽了大多数的参数, 仅保留了关键的参数, 适应于大部分的情况, 当然, 如果你想完全自定义属于自己的刷新风格, 请采用方式3.

- 注意: (target和refreshAction) 与 (finishedCallback) 必须保留其一, 因为你要在里面写刷新事件.并且要在此事件中, 结束刷新

- 方式1: 
```
let diyRefresh = DIYRefreshView.attach(scrollView: UIScrollView, plist: String, target: AnyObject, refreshAction: Selector, color: UIColor)
```
- 方式2
```
let diyRefresh = DIYRefreshView.attach(scrollView: UIScrollView, plist: String, color: UIColor, finishedCallback: (() -> ())?)
```
- 方式3
```
let diyRefresh = DIYRefreshView.attach(scrollView: UIScrollView, plist: String, target: AnyObject?, refreshAction: Selector?, color: UIColor, lineWidth: CGFloat, dropHeight: CGFloat, scale: CGFloat, showStyle: Int, horizontalRandomness: CGFloat, isReverseLoadingAnimation: Bool, finishedCallback: (() -> ())?)
```
- 参数解释
```
///   - scrollView: 将刷新控件添加到的scrollView对象(可以是scrollView的子类)
///   - plist: 刷新图案的坐标集合
///   - target: 调用此刷新控件的控制器
///   - refreshAction: 刷新时的刷新事件
///   - color: 刷新控件的内容颜色
///   - lineWidth: 刷新控件的线条宽度
///   - dropHeight: 刷新控件的偏移高度
///   - scale: 刷新控件内容的缩放比例(1.0为原生值)
///   - showStyle: 刷新控件的风格(0:飞来风格, 1:淡入淡出)
///   - horizontalRandomness: 产生随机数的水平方向上的值, 可以用来改变飞来风格的初始坐标值
///   - isReverseLoadingAnimation: 是否反向加载动画
///   - finishedCallback: 刷新回调方法
```

- 刷新完成后, 结束刷新
```
diyRefresh!.finishingLoading()
```

# 框架未完成的部分
- 接下来将会支持CocoaPods
- 更简单的创作动画的方式, 你告诉我要刷新的动画字母, 我帮你生成Plist文件

# 致谢
- 此框架借鉴于: CBStoreHouseRefreshControl和MJRefresh, 继承了两个框架的优点, 在此, 感谢对开源框架作出贡献的攻城狮们
- 如果你在使用的过程中, 发现问题, 请及时联系我, 我会及时更正
- 如果你感觉框架还不错, 请为我点亮一颗星, THS
