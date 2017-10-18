### Learn_MJRefresh

#### 基本原理

通过`runtime`在`scrollView`的扩展中添加`mj_header``mj_footer`属性，并在两个属性分别的`setter`方法中将他们添加到`scrollView`上。    

在`mj_header/mj_footer`将要添加到他们的父视图上的时候，为他们`scrollView`类型的父视图中添加几个KVO监控`contentOffset、contnetSize、pan手势`的变化。  

根据`contentOffset`偏移量的变化，确定`mj_header/mj_footer`漏出来的比列，进而更新当前刷新控件的状态。  

根据`contentSize`的变化，实时更新`mj_footer`的位置。  

根据`pan手势`的变化，更新`MJRefreshAutoFooter`类型的`mj_footer`的刷新状态。

根据刷新状态的不同，更新`mj_header/mj_footer`上显示的状态label上的文本信息以及箭头、菊花和动画。

#### 使用时的注意点

下拉刷新控件上展示的上次刷新时间，默认只会存储一份，所以不同界面显示的历史时间是同一份，因此如果需要显示这个时间，需要根据不同的界面设置不同的存储`key`值。  

根据不同的需求选择不同的上拉刷新控件。  
`MJRefreshAutoFooter`和`MJRefreshBackFooter`是显示在两个不同位置的上拉刷新控件。由于前者显示位置的特殊性，决定了他只有普通闲置、正在刷新、没有更多数据三种状态；而后者跟下拉刷新控件类似 还有松开就可以进入刷新状态状态。 所以前者也可以叫做可以自动刷新的上拉刷新控件。

#### WebView 
注意：WebView虽然可以滑动，但并不是继承自UIScrollView，而是继承自UIView。


#### 几个扩展

|Class／文件|作用|
|---|---|
|`UIView(MJExtension)`| 方便设置和获取`view`的坐标、大小、`origin`等属性值 |
|`UIScrollView(MJExtension)`| 方便设置和获取`UIScrollView`的相关的`contentOffset、contentSize、contentInset`等属性值 |
|`NSBundle(MJRefresh)`| `MJRefresh`需要的资源文件，包含刷新时需要的箭头和本地化提示语 |
|`UIScrollView(MJRefresh)`文件| 文件包含了多个扩展，主要作用是：</br> 1. `UIScrollView(MJRefresh)` 给`UIScrollView`添加`mj_header``mj_footer`属性、添加`mj_reloadDataBlock`属性；</br> 2. `UITableView(MJRefresh)、UICollectionView(MJRefresh)`通过`runtime`实现方法交换，在`reloadData`方法执行完之后，执行`blok`获取当前tableView的cell数或者collectionView的item数量。|

#### 解析`UIScrollView+MJRefresh`

<font color='red'>`refreshHeader`或者`refresheFooter`是什么时候被添加到相应的`scrollView`上的？</font>  

1. 在`UIScrollView`的扩展中 通过`runtime`为其添加了`mj_header``mj_footer`属性；  
2. 在`mj_header``mj_footer`的setter方法里面，将`mj_header``mj_footer`插入到了`scrollView`的最底层。  

<font color='red'>MJRefreshFooter中的`@property (assign, nonatomic, getter=isAutomaticallyHidden) BOOL automaticallyHidden;`</font>

当设置为`true`时 通过`tableView/collectionView`自动刷新后反馈到的当前列表的`cell／item`数是否为0来隐藏或者显示`refreshFooter`.

核心代码：  
1. 在`scrollView`的扩展中通过runtime添加`mj_reloadDataBlock`属性；  
2. 在`refreshFooter`将要添加到`superView`上的时候，判断`superView`是否为`tableView／collectionView`，如果是 设置`scrollView`的`mj_reloadDateBlock`属性；  
3. 在`UIScrollView`的扩展中通过`runtime`交换方法 来将`-(void)reloadData`方法交换为自定义的方法；  
4. 在自定义的`reloadData`方法中 先执行系统的`reloadData`再执行`mj_reloadDateBlock(tabeView.cellCount/collection.itemCount)`从而执行步骤2中添加的`block`;






#### 关于刷新时间

上次刷新时间记录在`NSUserDefaults`中，并且默认情况都使用同一个`key(MJRefreshHeaderLastUpdatedTimeKey)`，这样的话默认只会存储最后刷新的那个界面的时间，所以在任何时候取出来的时间并不真正代表每一个界面的最后一次刷新时间，因此，使用默认的`key`来存储是没有意义的。


#### <a id="Learn_MJRefreshComponent"></a>`MJRefreshComponent`刷新控件基类

继承自`UIView`，是`MJFooterView、MJHeaderView`的基类。

<font color='red'>定义刷新控件的状态：</font>  

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

<font color='red'>定义几个block:</font>  

```
/** 进入刷新状态的回调 */
typedef void (^MJRefreshComponentRefreshingBlock)();
/** 开始刷新后的回调(进入刷新状态后的回调) */
typedef void (^MJRefreshComponentbeginRefreshingCompletionBlock)();
/** 结束刷新后的回调 */
typedef void (^MJRefreshComponentEndRefreshingCompletionBlock)();
```

<font color='red'>刷新状态的变换：</font>  

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

// 在刷新控件将要移动到父视图上时，添加三个观察者（使用KVO），用来监控并通知下面几个变化：

/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

```


#### 小tip

* `OC`关键词`NS_REQUIRES_SUPER`用在父类的方法名称声明后面，表示字类在重写改方法的时候必须调用相应的`[super xxx]`，否则会报警告。
* `UIImageView`可以通过设置`animationImages`来显示动画效果，其中`animationDuration`用来设置一次动画循环的时间。





