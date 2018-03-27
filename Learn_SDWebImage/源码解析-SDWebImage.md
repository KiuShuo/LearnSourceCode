# SDWebImage

总体逻辑：  
![](/Users/liushuo199/Documents/LearnNote/--kiushuo/image/SDWebImage逻辑.png)
![](/Users/liushuo199/Documents/LearnNote/kiushuo/image/SDWebImage逻辑.png)

 围绕SDWebImage的几个核心问题进行解析

#### 怎么下载图片？
解析`SDWebImageDownloader`和`SDWebImageDownloaderOperation`类：  

`SDWebImageDownloader`作用： 主要用来协调（或者也可以说是一层分装）`SDImageCache`和`SDWebImageDownloader`，来为`UIView+WebCache`等提供接口。

下载过程的`cancel`分两种方式：  
1. 取消整个操作队列；  
2. 取消某一个下载操作。

下载过程中能否暂停？    
可以设置操作队列暂停。

#### 动图是怎么处理的？
	
#### 缓存与清除缓存
解析`SDImageCache`和`SDImageCacheConfig`类：  

* 内存存储可以通过`SDImageCache`中的`maxMemoryCost`和`maxMemoryCountLimit`设置`NSCache`最大的缓存大小和文件数量（默认都为0，不限制）；  
* 磁盘缓存可以通过`SDImageCacheConfig`来设置最大的缓存大小(默认为0，不限制)和缓存天数(默认为7天)；  
	可以看出内存和磁盘的限制是通过不同的途径进行限制，相互之间不受影响。  
	
###### 自动清除缓存的几个时机：  

* 当收到内存警告的时候，会自动清除所有内存缓存；  
* 当程序终止运行的时候，会执行`-deleteOldFiles`操作；  
* 当程序进入后台运行时，会执行`-deleteOldFiles`操作。  
	
	`-deleteOldFiles`函数（操作磁盘中存储的图片文件）：  
	* 首先会删除磁盘中所有过期文件；  
	* 然后会比较剩余文件大小是否超设置的上限，如果超的话会按照图片文件最后编辑的时间，逐一删除时间较长的文件，直至剩余的图片文件大小小于设置上限的一半。
	
#### 取图片的原则  
先去内存中查找，如果找不到再去磁盘中查找，找到后再在内存中存一份。

#### 工作流程

![](/Users/liushuo199/Documents/LearnNote/--kiushuo/image/SDWebImage工作流程.png)
![](/Users/liushuo199/Documents/LearnNote/kiushuo/image/SDWebImage工作流程.png)

### 知识点

#### NSCache
参考资料：  
[iOS之NSCache的简单介绍](http://www.jianshu.com/p/8ad9ff204f73)  
[iOS中NSCache缓存机制](http://www.jianshu.com/p/245c78aa6563)  

与NSMutableDictionary的区别：  

1. NSCache有自动删除功能，可减少系统占用内存；
2. NSCache是线程安全的，不需要加锁；
3. 键对象不会像NSMutableDictionary中那样被复制。（键对象不需要实现NSCopying协议）。  

两个自动清除缓存的上限条件：  

* totalCostLimit：缓存空间的最大总成本，超出上限会自动回收对象。默认值为0，表示没有限制  
* countLimit：能够缓存的对象的最大数量。默认值为0，表示没有限制

#### NSFileManager 文件管理
参考资料：  
[iOS之NSFilemanager文件管理(沙盒)](http://www.jianshu.com/p/a08cf375043a)  
[iOS文件的管理](http://www.jianshu.com/p/2bd3808842fc)  
[iOS判断是否在主线程的正确姿势](http://www.jianshu.com/p/7f68a3d5b07d)  


```
You use it to locate, create, copy, and move files and directories. You also 
use it to get information about a file or directory or change some of its 
attributes. 
可以查找、创建、copy或者移动文件和文件夹；也可以用来获取文件或文件夹的信息，也可以用来改变文
件或文件夹的属性。
```
#### NSDirectoryEnumerator 目录枚举类

```
@interface NSDirectoryEnumerator : NSEnumerator
Description	
An NSDirectoryEnumerator object enumerates the contents of a directory,
returning the pathnames of all files and directories contained within that 
directory. These pathnames are relative to the directory.
You obtain a directory enumerator using NSFileManager’s enumeratorAtPath: 
method. For more details, see Low-Level File Management Programming Topics.
An enumeration is recursive, including the files of all subdirectories, and 
crosses device boundaries. An enumeration does not resolve symbolic links, or 
attempt to traverse symbolic links that point to directories.

```
#### initialize
[iOS - + initialize 与 +load](http://www.jianshu.com/p/9368ce9bb8f9)  
简单来说，`+ (void)initialize`类似于懒加载方法，实在第一次使用一个类的时候（这个第一次类初始化之前，可以用来初始化静态变量）执行，且只会执行一次；  
`+ (void)load`方法通常在`main`函数之前调用。  

#### KVC的高阶用法

找出数组字典中相同key值的字典的value值组成的数组：

``` 
let arr: NSArray = [["a": "1"], ["a": "2"], ["1": "3"], ["b": "1"]]
let aArr: NSMutableArray = NSMutableArray(array: arr.value(forKey: "a") as! NSArray)
// aArr = ["1", "2", "<null>", "<null>"]
// removeObject(identicalTo: deleteValue)与removeObject(_: deleteValue)的区别：前者是删除数组中地址与deleteValue相同的所有元素，后者是删除数组中与deleteValue相等的所有元素
aArr.removeObject(identicalTo: NSNull())
// aArr = ["1", "2"]
```

#### NSOperation

源码中的SDWebImageDowloaderOperation继承自NSOperation，通过自定义的NSOperation来实现图片的下载操作。    

#### NS_REFINED_FOR_SWIFT

作用：当OC和Swift混编的时候，系统会自动将OC的方法名转换为Swift，但是有些时候，我们不想直接使用系统转变过来的函数， 这时候我们就可以在相应的OC方法名称后面加上NS_REFINED_FOR_SWIFT关键字，这时候转换的Swift函数前面就多了两个下划线，这时候我们就可以用原来的方法名或者新起一个，来改进实现，如下：

```
@interface Color : NSObject
 
- (void)getRed:(nullable CGFloat *)red
         green:(nullable CGFloat *)green
          blue:(nullable CGFloat *)blue
         alpha:(nullable CGFloat *)alpha NS_REFINED_FOR_SWIFT;
 
@end
// 改进实现机制，通过元组的方式返回数据
extension Color {
    var RGBA: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        __getRed(red: &r, green: &g, blue: &b, alpha: &a)
        return (red: r, green: g, blue: b, alpha: a)
    }
}

```

