### Learn_Alamofire


#### HTTPMethod
[HTTP请求方法：GET、HEAD、POST、PUT、DELETE、CONNECT、OPTIONS、TRACE](https://itbilu.com/other/relate/EkwKysXIl.html)  


#### HTTP headers
[HTTP消息头（HTTP headers）－HTTP请求头与HTTP响应头](https://itbilu.com/other/relate/E1T0q4EIe.html)  

HTTP协议将传输的信息分为两个部分：HTTP信息头、HTTP信息体。  
通过HTTP信息头可以使客户端请求服务器资源或服务器响应客户端资源时能够传递更多的信息。  
HTTP信息头的格式为`key: value`，名称不区分大小写。  
通过HTTP消息头，可以使服务器或客户端了解对方所使用的协议版本、内容类型、编码方式等。  

#### HTTP Cookie
[Http Cookie机制及Cookie的实现原理](https://itbilu.com/other/relate/4J4n8fIPe.html)  
[HTTP协议中Cookie与Session的区别](https://itbilu.com/other/relate/Ny2IWC3N-.html)

Cookie是进行网站用户身份识别，实现服务端Session回话持久化的一种方式。  

HTTP是一种无状态的协议，客户端与服务器建立连接并传输数据，数据传输完成后，连接就会关闭。再次交互数据需要建立新的连接，因此，服务器无法从连接上跟踪会话，也无法知道用户上一次做了什么。这严重阻碍了基于Web应用程序的交互，也影响用户的交互体验。如：在网络有时候需要用户登录才进一步操作，用户输入用户名密码登录后，浏览了几个页面，由于HTTP的无状态性，服务器并不知道用户有没有登录。

Cookie是解决HTTP无状态性的有效手段，服务器可以设置或读取Cookie中所包含的信息。当用户登录后，服务器会发送包含登录凭据的Cookie到用户浏览器客户端，而浏览器对该Cookie进行某种形式的存储（内存或硬盘）。用户再次访问该网站时，浏览器会发送该Cookie（Cookie未到期时）到服务器，服务器对该凭据进行验证，合法时使用户不必输入用户名和密码就可以直接登录。

本质上讲，Cookie是一段文本信息。客户端请求服务器时，如果服务器需要记录用户状态，就在响应用户请求时发送一段Cookie信息。客户端浏览器保存该Cookie信息，当用户再次访问该网站时，浏览器会把Cookie做为请求信息的一部分提交给服务器。服务器检查Cookie内容，以此来判断用户状态，服务器还会对Cookie信息进行维护，必要时会对Cookie内容进行修改。

Cookie定义了一些HTTP请求头和HTTP响应头，通过这些HTTP头信息使服务器可以与客户进行状态交互。  

