### Learn_MJRefreshHeader

#### 继承关系
refreshHeader的继承关系从上到下依次为：  
`MJRefreshComponent`  
[`MJRefreshHeader`](#Learn_ MJRefreshHeader)  
[`MJRefreshStateHeader`](#Learn_MJRefreshStateHeader)  
[`MJRefreshNormalHeader`](#Learn_MJRefreshNormalHeader) [`MJRefreshGifHeader`](#)

#### <a id="Learn_ MJRefreshHeader"></a>`MJRefreshHeader`调整刷新状态，实现刷新悬停
主要用来监控`scrollView`的`contenOffset`偏移量来调整刷新状态，实现刷新悬停。

通过KVO实时观察`scrollView`的`contentOffset`的变化 来决定状态的改变：  
1. 当`scrollView`被拖拽 原始状态`state = MJRefreshStateIdle`时，当向下拖拽的距离超过`refreshHeaderView`的高度的时候，状态`state`改变为`MJRefreshStatePulling`松开就会刷新；  
2. 当`scrollView`被拖拽 原始状态`state = MJRefreshStatePulling`时，当往上拖拽使得`scrollView`向下的偏移量不大于`refreshHeaderView`的高度的时候，状态又恢复到原始`state = MJRefreshStateIdle`；  
3. 当`scrollView`没有被拖拽 原始状态`state = MJRefreshStatePulling`时，执行`- (void)beginRefreshing`开始刷新，改变状态为`state = MJRefreshStateRefreshing`;
4. 当`state = MJRefreshStateRefreshing`正在刷新过程中，会对比当前的向下偏移量与`refreshHeaderView`的高度值，取两者中较小的一个作为当前`scrollView`的`insertTop`值从而实现刷新悬停以及可向上移动的显示效果。

`ignoredScrollViewContentInsetTop`属性：默认为0，即`MJRefreshHeader`紧贴在`tableView`的上方，可以通过设置该属性来调整其与`tableView`之间的竖直间距。

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
