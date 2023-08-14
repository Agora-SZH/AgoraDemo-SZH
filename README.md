# AgoraDemo-SZH

*[English](README.md) | 中文*

这个开源示例项目演示了Agora视频SDK的部分API使用示例，以帮助开发者更好地理解和运用Agora视频SDK的API。
## 高阶功能列表
1.H265编码
2.色彩增强
3.暗光增强
4.视频降噪
5.码率节省
6.AI降噪
7.超分辨率

## 环境准备

- XCode 13.0 +
- iOS 真机设备
- 不支持模拟器

## 运行示例程序

这个段落主要讲解了如何编译和运行实例程序。

### 安装依赖库

切换到 **iOS** 目录，运行以下命令使用CocoaPods安装依赖，Agora视频SDK会在安装后自动完成集成。

使用cocoapods

[安装cocoapods](http://t.zoukankan.com/lijiejoy-p-9680485.html)

```
pod install
```

运行后确认 `AgoraDemo-SZH.xcworkspace` 正常生成即可。

### 创建Agora账号并获取AppId

在编译和启动实例程序前，你需要首先获取一个可用的App Id:

1. 在[agora.io](https://dashboard.agora.io/signin/)创建一个开发者账号
2. 前往后台页面，点击左部导航栏的 **项目 > 项目列表** 菜单
3. 复制后台的 **App Id** 并备注，稍后启动应用时会用到它
4. 如果开启了token，需要获取 App 证书并设置给`certificate`

然后你就可以使用 `AgoraDemo-SZH.xcworkspace` 编译并运行项目了。


## 代码许可

The MIT License (MIT)
