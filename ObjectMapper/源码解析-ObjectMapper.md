# ObjectMapper

### Transform

#### ...`TransformType`：
定义了一个范型协议`TransformType`。

**Get到的点：** 

* **Swift中的协议有两个作用：**

1. 实现多继承；
2. 强制实现者必须遵守的一些约束。（这时候可能会用到`associatedtype`关键字）

* **`associatedtype`**关联类型 关键字：协议中用该关键字来实现范型的功能，即范型协议。  
  范型化的协议将不能再被看做一种类型来看待。  
  [swift的泛型协议为什么不用<T>语法](http://www.jianshu.com/p/ef4a9b56f951)   
  eg:

  ```
 	associatedtype Object
	associatedtype JSON
  ```
 
 范型协议的服从者通过`typealias`关键字明确范型代表的实际类型：  
 eg:
 
 ``` 
  typealias Object = Data
  typealias JSON = String
 ```

#### ...`URLTransform`：
服从`TransformType`协议，实现`URL(Object)  <-> String(JSON)`。  

**Get到的点：**  

* Swift中URL编码与解码问题：  

	```
	// encode: 
	func addingPercentEncoding(withAllowedCharacters allowedCharacters: 	CharacterSet) -> String? 
	// decode: 
	var removingPercentEncoding: String? { get }
	```

	eg: 
	
	```
	let aStr = "{abc}"
	let encodeStr = 	aStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
	/// encodeStr = "%7Babc%7D"
	let decodeStr = encodeStr?.removingPercentEncoding
	/// decodeStr = "{abc}"
	```

#### ...`DataTransform`：
服从`TransformType`协议, 实现 `Data(Object) <-> String(JSON)`。  

**Get到的点：**   

* base64的String与Data之间的相互转换： 

	```
	base64String -> Data: Data(base64Encoded: string)
	Data -> base64String: data.base64EncodedString()
	```
* [iOS开发探索-Base64编码](http://www.jianshu.com/p/b8a5e1c770f9)  

#### ...`DateTransform`, `DateFormatterTransform`, `CustomDateFormatTransform`, `ISO8601DateTransform`：
服从`TransformType`协议，实现`Date(Object) <-> Double(JSON)`。  

**Get到的点：**  

* [ISO 8601](http://baike.baidu.com/link?url=F3JVAHB_WXWlvYJ-zApn31APSb1-QaDSRZoQfA2n-oU_hwSTRy0eP_JfyDnRDlpORpszzGfofQT9qWqOVTRs1OJC-p8ptGuhnJ2Q3mx5aHC)

* `atof`

	```
	// C函数，String转Double
	atof("111") // 111.0
	```

#### ...`NSDecimalNumberTransform`:

服从`TransformType`协议，实现`NSDecimalNumber(Object) <-> String(JSON)`。  

**Get到的点：**

* [‘NSDecimalNumber--十进制数’使用方法](http://www.jianshu.com/p/4703d704c953)

#### ...`EnumTransform<T: RawRepresentable>: TransformType`：

`T(Object) <-> T.RawValue(JSON)`  

#### ... `HexColorTransform: TransformType`:
`UIColor/NSColor(Object) <-> String(JSON)`

#### ...`DictionaryTransform<Key, Value>: TransformType where Key: Hashable, Key: RawRepresentable, Key.RawValue == String, Value: Mappable`:
`[String: Any](JSON) <-> [Key: Value](Object)`  

`Object`为`[Key: Value]`，其中`key`需满足三个条件：
  
 1. 服从`Hashable`，可哈希，这是作为字典的key值的必须满足的基本条件；  
 2. 服从`RawRepresentable`，可以根据关联类型构造；  
 3. 关联类型必须为`String`。  
 
`Value`必须服从`Mappable`协议。

#### ...`TransformOf<ObjectType, JSONType>: TransformType`：
提供了一个通用的转换形式，通过闭包将 `ObjectType <-> JSONType` 转到外部。



### Map

#### ...`Map`用于映射数据
用来存储映射所需要的信息。里面应用到了多个下标重载，根据不同的入参获取Map。  

#### ...`MapError`用来描述映射过程中产生的错误
**Get到的点：**  
`CustomStringConvertible`协议提供的description函数用来更方便的描述一个实例。  
`StaticString`在编译期就能确定的字符串。不能在运行时修改。  

#### ...`Mapper`提供了JSON转Model，与Model转JSON的方法。


#### ...`Mappable`
定义了`BaseMappable`协议
