# SDWebImage

 围绕SDWebImage的几个核心问题进行解析

#### 怎么下载图片？同步 or 异步
解析`SDWebImageDownloader`和`SDWebImageDownloaderOperation`类：  


#### 怎么存储图片？存到哪（内存memory or 磁盘disk）、怎么存（同步 or 异步）  
	内存：使用系统自带的NSCache管理  
	磁盘：
	
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

#### NSURLSession



