# xmppmini 项目总介
这是一个针对 xmpp 协议进行裁剪,以使 xmpp 协议真正实用化的项目

经过多年的 xmpp 协议相关的开发,我们发觉 xmpp 协议真正的缺陷其实不是功能不足,而是太过臃肿. xmpp 协议想要象 smtp/pop3 这样成为真正的网络应用协议应该要精练化,我们项目中的 mini 就指的是"精练"这一过程.在实际的应用中,我们发现精简后的 xmpp 协议反而能在更多的领域找到自己的位置.

开发到后面我们发觉不应当仅仅局限于 xmpp 协议，实际上随着实际的产品开发会发现在即时通讯开发中 http/udp 这样的其他内容都会需要用上，所以实际上这要超过一个通讯协议的范围，所以我们也不能把这个项目叫做 "xx协议"，因此目前我们正式的名称为 "xmppmini规范" ，这是一个实现即时通讯的互联互通规范。

作为一个开源项目，我们认为应该足够简单，对于普通的独立开发者来说太过复杂的开源等同于不开源，除了直接使用已经做好的模块，实际并无力修改其中的代码以适应自己的需求。所以我们最重要的一个指标就是：所有内容必须能让大多数独立开发者有能力独立手工代码实现，并且是推荐能实现的开发期能保持在一个月之内。就是说，如果发展中使用到了的技术开发人员要超过一个月的时间才能掌握的话，那就应该放弃或者是更换另外一种实现方式。

### 目前的实现：

目前已成功开发出了一个实用化的 pc 版客户端，之所以这是第一个产品，是因为目前市面上实在没有一款真正能用的 pc 版 xmpp 客户端（不像电子邮件，有非常多）。
主要代码就开源在 sdk_pascal 子目录之中。二进制文件的话，目前大陆来说传到 github 上还是有些困难，因为目前用来显示 H5 内容的 cef 相关文件比较大，所以请大家移步到后面的地址下载，大家将可以看到简单的协议下也可以开发出这样精彩的功能，另外相关讨论区中我们也会推荐在其他平台上好用的 xmpp 客户端（奇怪的是有些甚至没有在 xmpp 的官方站点中列出）。

下载地址为：
http://newbt.net/ms/vdisk/show_bbs.php?id=E4968ACA6FDBFB95E80D025C8FAF6162&pid=175
讨论区为：
http://newbt.net/ms/vdisk/list_bbs.php?id=175


--------------------------------------------------------
下面介绍一下我们对常用即时通讯功能的实现方法，大多数并没有使用繁琐的 xmpp 扩展，每个 xmpp 扩展几乎都要对应一个新的协议文本，实现的工作量几乎就相当于 xmpp 基础协议本身。这在实际的开发中，特别是国内常见的客户定制性的项目集成开发来说更不合适，因为本身开发时间就已经很紧促了。对于想在此基础上开发给自家公司用的项目也不合适，应该更简单易懂，而且耦合度应该足够低，以便将不同的模块交由不同的开发人员去完成。基于这些出发点，我们的实现方式如下：

1.大容量集群，几乎每到一家公司去申请即时通讯的开发职位都会问我这个问题，实际上这有个简单的实现方法。具体可看后面的介绍，实现本身非常简单（实际上借鉴了电子邮箱和 DNS 的一些特点）：每个用户分布在不同的机器上，比如 A 机器有 1000 用户，B 机器有另外 1000 用户，两如机器都有各自的域名，其实客户端在开始标准 xmpp 通讯之前访问一个 php 查询页面（当然也可以是 jsp 或者 aspx 等来实现）得到对方所在的实际域名就可以了，后面完全是标准 xmpp 流程，只是连接的域名和端口填写上这个通过动态页面查询到的内容就可以了。php 这样的动态页面几乎每个中国程序员都会写吧，所以这种实现非常简单易得。

2.好友列表，这在标准 xmpp 中又是一大串内容，如果想通过修改 openfire 这样的开源服务器来适应自己的需求，真的很难。我们的实现又是非常简单地用一个 php 页面来实现了。具体可以参考我们上面的 xmppmini 客户端程序，客户端唯一要做的就是检测浏览器控件的地址变化，当发现是 php 页面指定要打开与某个好友的对话链接时，就拦截显示一个对话界面就可以了。而这种地址拦截功能是每个浏览器控件都具有的，包括“最老的” ie6。（我们用的 cef 浏览器控件）

3.禁言好友，拉黑之类的。不用做任何开发，是的！因为好友列表就是一个页面来做的，所以这些功能都做在那个页面中了。

4.图片、短语音或者是大文件发送，甚至视频对话。在 xmpp 中这又是一个大问题，甚至无法实现，公平地说，这对所有即时通讯都是个大问题。我们的解决方式和前面的一样，都交给一个 php ，需要客户端参与交互时预定一个拦截地址就行。其实现在几乎所有的免费电子邮箱都是这样处理超大文件的，因为电子邮件本身的通讯协议根本不适合处理太大的文件，xmpp 协议也是。而对于大文件空间占用的处理，其实只要加个可用期限限制就可以了。

5.从以上实现方式可以看到，大多数功能都可以用 web 加地址拦截的方式来处理。我们也可以看到实际上 xmpp 协议在这里只起到一个通知的作用，这也是我们的一个原则。对于企业应用来说上面的就足够了，不过对于我们来说还要加别的功能，所以如果大家看源码的话还会看到其他内容，不过并不会影响即时通讯本身，所以我们以后再介绍。

--------------------------------------------------------

## 我们精简的方式主要是:
xmpp 协议尽量只负责即时通讯部分,而文件传输,甚至于视频应用这些其实都可以交给传统的 http 或者是其他协议,没必要(其实也不可能)大包大揽.这样精简后的 xmpp 协议也会让各个希望接入的客户端更容易接入.

## 我们的目标产品主要有两个:
客户端和服务器.其中客户端包括一整套各种方便大家使用的 sdk ,至少会包括各大主流开发语言,同时也会发布精练后的 xmpp 协议规范,我们直接称谓这个规范为 xmppmini 规范. 同时也会发布一个供大家方便使用的 xmppmini 规范的服务器,这个服务器同时也会兼容目前市面上的所有 xmpp 客户端.


--------------------------------------------------------
以下是我们的协议/规则一些主要部分的详细说明

## xmppmini 的寻址方式
越用到最后越会发现和电子邮件的 smtp/pop3 协议相似，要开发一个实用的 xmppmini 项目特别是服务器端单靠 xmpp 协议其实是无法完成的，这就是为什么所有的免费电子邮箱服务商都会有一个自己的 web 端一样。而 xmpp 协议最大的问题就在于想将一切大包大览，这肯定是不现实的，在现在即时通讯的暂时屏蔽某用户功能为例子，这在 xmpp 协议中没有，难道为了实现这一功能我要先提交给协议正式通过吗？显然行不通，所以在 xmppmini 项目中我们不可能定那么死，很多功能接口应当只给出一个 http 地址，让各服务商自行提供 web 地址，然后客户端去访问就行了（当然服务商自己的 web 端还可以提供更强大的功能，这里的意思是 xmppmini 只是稍微规范了一下入口的地址而已，服务商也不用非要实现这个规范）。这里要说明的寻址方式和后面的附加消息格式都是如此。

###### 1.一个地址的服务器查找方式  
例如 clq@newbt.net 一个客户端 socket 如何知道去连接什么 ip 和 端口呢？  
传统上比较简单：直接使用 dns 解析出 ip 然后默认规定大家使用 5222 端口就行了，如果是 ssl/tls 安全端口则为 5223。（另外还有一些扩展的寻址方法我们就不讨论了）  

现在很多协议比如电子邮件的 smtp 协议通过在 dns 附加信息来扩展一些功能，例如 dkim 的密钥等等，但这样会产生一些问题。现在的程序开发 api 中对 dns 的支持可以说是非常的弱，无论对客户端还是服务端都是如此，所以我们使用的不是 dns 扩展，而是网络协议中发展得最为成熟的 http 即 web 的方式，而且尽量降低接口的实现难度。举个简单的例子，cdn 加速对于 dns 来说就几乎是不可能实现的（当然实际上是可以的，这里指方便性，取得的难易而言），而 http 方面现在则是有各种各样几近无数的云系统可供选择。

所以我们扩展寻址方式的第一个就很容易理解：在域名默认站点下如果有 xmppmini.txt 的话优先查找它里面注明的地址，不存在这个文件的话再按传统查找 dns 。例如：  
地址 clq@clqsoft.com ，首先访问 http://clqsoft.com/xmppmini.txt  
其内容假设为：  
host=clqsoft.com  

其中的换行遵循网络协议格式，为 CRLF ，不可直接为自己操作系统的换行。  

则表示其实服务器为 clqsoft.com 上的 5222 端口（或 5223 安全端口）。  
那么假如象邮件服务器一样，我的地址是托管在别人的服务器上的怎么办呢？很简单，修改 host 节的地址为托管服务器即可，例如：  
host=newbt.net  

这就表示说，要将信息发送给 clq@clqsoft.com 的话，请连接 newbt.net 的 5222 端口（或 5223 安全端口）。这其实等同于 smtp 中 dns 的 mx 记录。      

传统上到这一步就差不多了，但我们 xmppmini 根据项目实际运行经验还加上了一个重要的功能：动态查询。以一个公司发展为例，公司尚小时只用一台服务器即可满足需要，以上接口就足够了。但当公司壮大后需要增加服务器时，我如果知道应当连接那一台机器呢？传统上的解决其实还是用 dns ，将一个域名解析为多台 ip 所在的机器就可以了，这对客户端来说是非常方便的，无需任何变动。但这对服务器来说要做的改动太多太多的，根据我们的经验，现有的 xmpp 服务器软件几乎没有现成可用的，要完成这一功能不自己修改代码几乎是不可能是。在以往的工作中，有一个方法可以很容易的解决这个问题：将地址再细化，每个用户自己有一个固定的服务器，然后再在客户端软件中给出一个假的统一域名的地址就行了。例如： clq_a@a.clqsoft.com，clq_b@b.clqsoft.com 这两个地址是真实的 xmpp 地址，任何一种 xmpp 服务器软件都支持的，然后在自己的客户中显示为 clq_a@clqsoft.com，clq_b@clqsoft.com 就可以了，但这样只适合做在自己公司的 app 中，面向大众不可能要求其他的客户端都这样改。要解决这个问题其实也很简单，在服务器交互时增加一个查询就可以了，客户端一样不需要做任何改动。所以我们的 xmppmini 寻址就有了以下方式：   
host=http://newbt.net/xmppmini.php?action=get_host  
server_dyn=1  

当我们要将消息发送给 clq_a@clqsoft.com 时，只要访问 http://newbt.net/xmppmini.php?action=get_host  传递一个值为 clq_a@clqsoft.com 的 user_name 参数就可以查询到它所在的服务器了。参数即可以通过 post 方式，也可以通过 get 方式传递。例如用浏览器直接访问 http://newbt.net/xmppmini.php?action=get_host&user_name=clq_a@clqsoft.com   

这一地址返回的内容格式也和 xmppmini.txt 一样，不过这其中的 host 应该是固定的，不能再支持动态再向下级查询了（当然特殊需要的用户可以自行实现再向下查询，但对于 xmppmini 项目来说简单是第一要务，就不支持了）。  

这一扩展一般在服务端实现，但对于不想修改服务器软件的用户来说，直接在客户端实现也是可以的，一样简单。  

其中的换行遵循网络协议格式，为 CRLF ，不可直接为自己操作系统的换行。  

对于示例中的 xmppmini.php 当然可以换成 aspx/jsp 来实现，相信这对于一个程序员来说是非常简单的事情，我们就不赘述了。  

## xmppmini 的附加消息格式


--------  
加入我们! 让我们一起努力吧,让 xmpp 即时通讯也能象 email 一样成为互联网的标配!  
--------  
2020.01.13 第2次更新
