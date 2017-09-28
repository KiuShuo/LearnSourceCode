### Learn_MJRefresh


#### WebView 
注意：WebView虽然可以滑动，但并不是继承自UIScrollView，而是继承自UIView。


#### 几个扩展

|Class／文件|作用|
|---|---|
|`UIView(MJExtension)`| 方便设置和获取view的坐标、大小、`origin`等属性值 |
|`UIScrollView(MJExtension)`| 方便设置和获取`UIScrollView`的相关的`contentOffset、contentSize、contentInset`等属性值 |
|`NSBundle(MJRefresh)`| `MJRefresh`需要的资源文件，包含刷新时需要的箭头和本地化提示语 |
|`UIScrollView(MJRefresh)`文件| 文件包含了多个扩展，主要作用是：<br> 1. `UIScrollView(MJRefresh)` 给`UIScrollView`添加`mj_header``mj_footer`属性、添加`mj_reloadDataBlock`属性；<br> 2. `UITableView(MJRefresh)、UICollectionView(MJRefresh)`通过`runtime`实现方法交换，在`reloadData`方法执行完之后，执行`blok`获取当前tableView的cell数或者collectionView的item数量。|


#### 关于刷新时间

上次刷新时间记录在`NSUserDefaults`中，并且默认情况都使用同一个`key(MJRefreshHeaderLastUpdatedTimeKey)`，这样的话默认只会存储最后刷新的那个界面的时间，所以在任何时候取出来的时间并不真正代表每一个界面的最后一次刷新时间，因此，使用默认的`key`来存储是没有意义的。

#### 继承关系
refreshHeader的继承关系从上到下依次为：  
[`MJRefreshComponent`](#Learn_MJRefreshComponent)  
[`MJRefreshHeader`](#Learn_ MJRefreshHeader)  
[`MJRefreshStateHeader`](#Learn_MJRefreshStateHeader)  
[`MJRefreshNormalHeader`](#Learn_MJRefreshNormalHeader) [`MJRefreshGifHeader`](#)



#### <a id="Learn_MJRefreshComponent"></a>`MJRefreshComponent`刷新控件基类

继承自`UIView`，是`MJFooterView、MJHeaderView`的基类。

定义刷新控件的状态：  

```
typedef NS_ENUM(NSInteger, MJRefreshState) {
    /** 普通闲置状态 */
    MJRefreshStateIdle = 1,
    /** 松开就可以进行刷新的状态 */
    MJRefreshStatePulling,
    /** 正在刷新中的状态 */
    MJRefreshStateRefreshing,
    /** 即将刷新的状态 */
    MJRefreshStateWillRefresh,
    /** 所有数据加载完毕，没有更多的数据了 */
    MJRefreshStateNoMoreData
};
```

定义几个block:  

```
/** 进入刷新状态的回调 */
typedef void (^MJRefreshComponentRefreshingBlock)();
/** 开始刷新后的回调(进入刷新状态后的回调) */
typedef void (^MJRefreshComponentbeginRefreshingCompletionBlock)();
/** 结束刷新后的回调 */
typedef void (^MJRefreshComponentEndRefreshingCompletionBlock)();
```

刷新状态的变换：  

```
#pragma mark - 刷新回调
/** 正在刷新的回调 */??? 与 begingRefreshingCompletionBlock相比，用在哪里？
@property (copy, nonatomic) MJRefreshComponentRefreshingBlock refreshingBlock;

/** 设置回调对象和回调方法 */
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action;
/** 回调对象 */
@property (weak, nonatomic) id refreshingTarget;
/** 回调方法 */
@property (assign, nonatomic) SEL refreshingAction;

/** 触发开始刷新回调（交给子类去调用） 
在主线程中依次通知执行下面的代码：
1. refreshingBlock() 正在刷新blcok;
2. 通知refreshingTarget执行refreshingAction;
3. 通知begingRefreshingCompletionBlock() 进入刷新状态block();
*/
- (void)executeRefreshingCallback;

#pragma mark - 刷新状态控制
/** 进入刷新状态 */
- (void)beginRefreshing;
- (void)beginRefreshingWithCompletionBlock:(void (^)())completionBlock;
/** 开始刷新后的回调(进入刷新状态后的回调) */
@property (copy, nonatomic) MJRefreshComponentbeginRefreshingCompletionBlock beginRefreshingCompletionBlock;

/** 结束刷新状态 */
- (void)endRefreshing;
- (void)endRefreshingWithCompletionBlock:(void (^)())completionBlock;
/** 结束刷新的回调 */
@property (copy, nonatomic) MJRefreshComponentEndRefreshingCompletionBlock endRefreshingCompletionBlock;

/** 是否正在刷新 
正在刷新的两种状态：MJRefreshStateRefreshing MJRefreshStateWillRefresh
 */
- (BOOL)isRefreshing;
/** 刷新状态 一般交给子类内部实现 */
@property (assign, nonatomic) MJRefreshState state;
```


子类中长需访问的属性、实现的方法

```
#pragma mark - 交给子类去访问  

// 这两个属性都是readonly只读的，是在刷新控件将要移动到其父视图上时获取的这两个属性的值。

/** 记录scrollView刚开始的inset */
@property (assign, nonatomic, readonly) UIEdgeInsets scrollViewOriginalInset;

/** 父控件 */
@property (weak, nonatomic, readonly) UIScrollView *scrollView;

#pragma mark - 交给子类们去实现

/** 初始化 初始化时调用，用来给一些属性设置默认值 */
- (void)prepare NS_REQUIRES_SUPER;

/** 摆放子控件frame  -(void)layoutSubviews执行时调用； 
当刷新控件的状态发生改变的时候，通过[self setNeedsLayout]来通知刷新控件执行
-(void)layoutSubviews方法，从而是刷新控件的视图能够在
*/
- (void)placeSubviews NS_REQUIRES_SUPER;

// 在刷新控件将要移动到父视图上时，添加三个观察者，用来监控并通知下面几个变化：

/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

```

#### <a id="Learn_ MJRefreshHeader"></a>`MJRefreshHeader`调整刷新状态，实现刷新悬停
主要用来监控`scrollView`的`contenOffset`偏移量来调整刷新状态，实现刷新悬停

通过KVO实时观察`scrollView`的`contentOffset`的变化 来决定状态的改变：  
1. 当`scrollView`被拖拽 原始状态`state = MJRefreshStateIdle`时，当向下拖拽的距离超过`refreshHeaderView`的高度的时候，状态`state`改变为`MJRefreshStatePulling`松开就会刷新；  
2. 当`scrollView`被拖拽 原始状态`state = MJRefreshStatePulling`时，当往上拖拽使得`scrollView`向下的偏移量不大于`refreshHeaderView`的高度的时候，状态又恢复到原始`state = MJRefreshStateIdle`；  
3. 当`scrollView`没有被拖拽 原始状态`state = MJRefreshStatePulling`时，执行`- (void)beginRefreshing`开始刷新，改变状态为`state = MJRefreshStateRefreshing`;
4. 当`state = MJRefreshStateRefreshing`正在刷新过程中，会对比当前的向下偏移量与`refreshHeaderView`的高度值，取两者中较小的一个作为当前`scrollView`的`insertTop`值从而实现刷新悬停以及可向上移动的显示效果。

#### <a id="Learn_MJRefreshStateHeader"></a>`MJRefreshStateHeader`创建、显示、更新`stateLabel、timeLabel`
  
1. 在`- (void)prepare`方法中设置`stateLabel`在不同状态下要显示的文字提示，存储在`titles`字典中；
2. 在`-(void)placeSubviews`方法中布局`stateLabel`和`timeLabel`；    
3. 在`- (void)setState:(MJRefreshState)state`状态发生改变的时候更改`stateLabel`和`timeLabel`上显示的内容。


#### <a id="Learn_MJRefreshNormalHeader"></a>`MJRefreshNormalHeader`创建、显示和更新arrowView、loadingView(UIActivityIndicatoeView)

1. 在`- (void)prepare`方法中设置`activityIndicatorView`的默认样式；  
2. 在`-(void)placeSubviews`方法中创建`arrowView`和`loadingView`； 
3. 在`- (void)setState:(MJRefreshState)state`状态发生改变的时候更改`arrowView`和`loadingView`的现实状况。

#### <a id="Learn_MJRefreshGifHeader"></a>'MJRefreshGifHeader'

1. 在`- (void)prepare`方法中设置`gitView`与`textLabel`之间的默认间距；  
2. 在`-(void)placeSubviews`方法中创建`gitView`并调整好其在`headerView`上的位置；  
3. 同时向外界提供了设置不同状态要显示的图片数组，用于显示动画；  
4. 在`- (void)setState:(MJRefreshState)state`状态发生改变的时候来设置`gitView`在不同状态的的`animationImages`，并控制动画的开始与结束。

#### 小tip

* `OC`关键词`NS_REQUIRES_SUPER`用在父类的方法名称声明后面，表示字类在重写改方法的时候必须调用相应的`[super xxx]`，否则会报警告。
* `UIImageView`可以通过设置`animationImages`来显示动画效果，其中`animationDuration`用来设置一次动画循环的时间。





