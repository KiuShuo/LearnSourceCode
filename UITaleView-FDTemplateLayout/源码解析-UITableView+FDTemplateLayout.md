# UITableView+FDTemplateLayout  

[学习Demo地址](https://github.com/KiuShuo/UITableView-FDTemplateLayoutCell)

### 解析源码：

##### `UITableView+FDKeyedHeightCache`分类
用于获取`FDKeyedHeightCache`类型的对象；  

`FDKeyedHeightCache`根据key来进行高度缓存管理。  
`FDKeyedHeightCache`主要功能：  

``` 
// 判断指定的key值是否存在高度
- (BOOL)existsHeightForKey:(id<NSCopying>)key;  w
// 存储key对应的高度 
- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key;
// 获取key对应的高度  
- (CGFloat)heightForKey:(id<NSCopying>)key;
// 清除key对应的高度  
- (void)invalidateHeightForKey:(id<NSCopying>)key;
// 清除所有高度
- (void)invalidateAllHeightCache;

```
基本实现原理：将高度与key值存储在字典中。用字典来进行判断有无值、添加值、删除值操作。

##### `UITableView+FDIndexPathHeightCache`分类
用来获取`FDIndexPathHeightCache`类型的对象。  

`FDIndexPathHeightCache`根据indexPath来进行高度缓存管理。  
主要功能：

```
// 设置是否自动
@property (nonatomic, assign) BOOL automaticallyInvalidateEnabled;

// Height cache
// 判断是否存在高度
- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath;
// 存储高度
- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath;
// 获取高度
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;
// 清除指定indexPath对应的高度
- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;
// 清除所有高度
- (void)invalidateAllHeightCache;
```

`UITableView+FDIndexPathHeightCacheInvalidation`拦截所有会导致缓存高度无效的方法，在方法执行之前设置高度数组，保证高度数组中的高度正确。   

##### `UITableView+FDTemplateLayoutCellDebug`分类
用来控制`tableView`是否可以打印信息，属于该第三方内部使用。无需多做考虑。

#####`UITableView+FDTemplateLayoutCell`分类  
前面几个类都是为`FDTemplateLayoutCell`服务的，在该类中真正实现了cell高度的计算，其中最核心是来自于	`UIView (UIConstraintBasedLayoutFittingSize)`的`- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize`方法。




##### get新技能：
1. [纯代码实现AutoLayout](http://www.cocoachina.com/ios/20160616/16732.html)  
keyPoint：  

	手动添加约束的时候，要先禁止 autoresizing 功能，防止 AutoresizingMask 转换成 Constraints，避免造成冲突，需要设置 view 的下面属性为 NO:`view.translatesAutoresizingMaskIntoConstraints = NO;`
2. [动态计算UITableViewCell高度详解](http://www.cocoachina.com/industry/20140604/8668.html)  
	keyPoint:  
	
	* 来自于	`UIView (UIConstraintBasedLayoutFittingSize)`的`- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize`方法。    
	这个方法的作用就是根据加好的约束计算高度。参数`targetSize`可以传两个参数`UILayoutFittingCompressedSize`（紧凑，大小适中的最小值）或者`UILayoutFittingExpandedSize`（宽松）。  
	这个方法是`UIView`的分类中的实例方法，所以需要实例cell去调用，因此我们需要在使用该方法之前获取到cell实例。
	* 需要注意的是，当`cell.contentView`中包含子视图`UITextView`时，获取的`cell`高度并不包含`UITextView`的高度，需要手动加上。
	
 
[`_cmd`](http://www.jianshu.com/p/fdb1bc445266)
[sizeof](http://blog.csdn.net/hmt20130412/article/details/20446787)

### 问与答
##### 0. 关于预估高度问题，请确认预估高度是从iOS几之后有效，有效后tableView主要代理方法的执行顺序的变化？

有了预估高度后，返回高度的方法被延迟执行了，节省了计算cell高度的执行次数，并且现在大都从iOS8之后兼容，所以一定要用起来。

##### 1. 设置预估高度estimatedRowHeight后，是否可以在高度计算的时候不配置cell？
   
经验证，不可行。  
原因：即使是设置了预估高度，延后了tableView:heightForRow的执行顺序，但是由于计算cell高度使用的systemLayoutSizeFittingSize:方法需要实例cell调用，因此需要获取cell，而通过dequeueReusableCellWithIdentifier获取重用的cell的时候，系统都会调用cell的- (void)prepareForReuse; 方法，而这个方法会清空cell上的所有赋值，将cell恢复到初始状态，因而计算出的高度和当前cell并不匹配。  

##### 2. 针对问题1提到的解释，问：在tableView:heightForRow方法中是否可以使用tableView.cellForRowAtIndexPath(indexPath:)来获取cell？为什么？

经验证，不可行。  
此时获取到的cell为nil。根据该方法的解释：“An object representing a cell of the table, or nil if the cell is not visible or indexPath is out of range.” 即只有当cell已经显现后并且在indexPath正确的前提下才能获取到，而在执行获取高度方法时是和获取cell的方法匹配执行（执行一次cellForRow立即执行一次heightForRow方法），即执行heightForRow的时候cell还在渲染，还没有visible。

##### 3. 针对问题1和2，问：是否可以不通过dequeueReusableCellWithIdentifier方法获取cell，也能获取到cell？  

能。  可以在cellForRow的时候将获取到的cell存起来，然后再在heightForRow的时候取出来直接用。这样的话可以解决问题1中，不配置cell而直接使用systemLayoutSizeFittingSize:计算出准确的高度。

##### 4. 针对问题3的回答，思考：为什么FDTemplateLayout没有存储cell，而是使用dequeueReusableCellWithIdentifier来获取cell？如果实现了cell的直接存储的话岂不是可以节省cell配置代码的执行？

##### 5. 使用Self Sizing Cells直接返回高度UITableViewAutomaticDimension，是否在所有的iOS8之后的系统之上都没有问题？

首先补充一下该问题，即在cell中使用auto layout布局子视图的前提下，将cell高度获取简化为如下的一行代码： 

```
tableView.estimatedRowHeight = 44.0
// tableView.rowHeight = UITableViewAutomaticDimension // 默认值，所以可以不写
```
是否在iOS8之后的所有系统上都没有问题，包含但不限于 a.显示没问题；b.跳转后tableView不会偏移 等等。

##### 6. 既然高度计算已经如此便捷，是否可以结合项目中以后的PATableViewModel简化代码，做到不在viewController中返回tableView的高度？
