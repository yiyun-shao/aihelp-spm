# AIHelp SDK for Swift Package Manager

将 AIHelp iOS SDK **6.3.0** 的 XCFramework 和资源封装为 Swift Package。此仓库为非官方 SPM 封装，SDK 的接口及功能由 AIHelp 提供。

## 环境要求

- Swift 6.4 或更高版本（以 `Package.swift` 的 tools version 为准）
- iOS 15.0 或更高版本
- 真机：arm64；模拟器：arm64、x86_64

不支持 macOS、Mac Catalyst、tvOS、watchOS 或 visionOS。

## Xcode 接入

在 **File → Add Package Dependencies** 中添加：

```text
https://github.com/yiyun-shao/aihelp-spm.git
```

选择版本规则 **Up to Next Major Version**，最低版本填写 `6.3.0`，将 `AIHelpSDK` 产品添加到 App target。

在宿主 App target 的 **Build Settings → Other Linker Flags** 中添加 `$(inherited) -ObjC`，并确保 Debug、Release 均生效。SDK 是 Objective-C 静态库，此参数用于加载其分类方法，否则可能出现 `unrecognized selector`。此参数由最终 App 设置，包不使用会限制其他 Swift Package 引用的 `unsafeFlags`。

也可以在其他包的 `Package.swift` 中声明：

```swift
dependencies: [
    .package(url: "https://github.com/yiyun-shao/aihelp-spm.git", from: "6.3.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [.product(name: "AIHelpSDK", package: "aihelp-spm")]
    )
]
```

也可以使用 SSH 地址 `git@github.com:yiyun-shao/aihelp-spm.git`，需要在本机配置 GitHub SSH 访问权限。

## 使用

```swift
import AIHelpSupport

// 在应用启动时初始化，使用 AIHelp 后台提供的实际参数。
AIHelpSupportSDK.initialize(withDomainName: "YOUR_DOMAIN", appId: "YOUR_APP_ID")

// 在 SDK 初始化就绪后，使用后台配置的入口 ID 打开客服。
AIHelpSupportSDK.show(withEntranceId: "YOUR_ENTRANCE_ID")
```

封装模块会导出 `AIHelpSupportSDK` 的原有 API。也可以直接 `import AIHelpSupportSDK`，但 App 仍应添加完整的 `AIHelpSDK` 产品，以包含资源和链接配置。

包会自动携带 `AIHelpSupportSDK.bundle`（图片及语言文件）、`PrivacyInfo.xcprivacy`，并链接 WebKit、Photos、PhotosUI、sqlite3。无需手动复制 bundle；请保留上述 `-ObjC` 设置。

使用相机、相册或麦克风等功能时，需在宿主 App 的 `Info.plist` 中填写对应权限用途说明。SDK 凭据、入口配置、初始化事件和其他 API 请参考 [AIHelp 官方文档](https://docs.aihelp.net/)；此包不提供业务配置。

## 本地验证

`swift package dump-package` 可检查清单。SDK 依赖 UIKit，构建和测试应使用 iOS 目标，不能用面向 macOS 的 `swift test`。

```sh
# 检查真机切片的构建（无需签名）
xcodebuild -scheme AIHelpSPM -destination 'generic/platform=iOS' build CODE_SIGNING_ALLOWED=NO

# 查看可用模拟器，然后将下面的 ID 替换为实际设备 ID
xcrun simctl list devices available
xcodebuild -scheme AIHelpSPM -destination 'platform=iOS Simulator,id=SIMULATOR_ID' test CODE_SIGNING_ALLOWED=NO 'OTHER_LDFLAGS=$(inherited) -Xlinker -ObjC'
```

集成测试检查 SDK 版本，并调用 SDK 自身的资源查找及图片加载逻辑，验证静态分类方法、图片和中英文语言文件可用。测试无需 AIHelp 账号或网络请求。

## 更新 SDK 与发布

1. 从 [官方仓库](https://github.com/AI-HELP/sdk-ios-example) 获取同一版本的 XCFramework、资源 bundle 和隐私清单。
2. 替换 `Sources/AIHelpSupportSDK.xcframework` 及 `Sources/AIHelpSupport/Resources` 中的对应文件，保留原有 bundle 内部目录。
3. 核对官方 podspec 的系统框架和系统库依赖，更新 `Package.swift`、本文版本和测试中的版本断言。
4. 执行真机构建与模拟器测试，提交后推送至 `git@github.com:yiyun-shao/aihelp-spm.git`，创建并推送版本 tag（首次建议 `6.3.0`）。同一 SDK 的封装修复可使用后续补丁版本，并在说明中注明实际 SDK 版本。

SDK 二进制与资源直接保存在 Git 仓库中，消费方不需要 CocoaPods 或额外下载脚本。

## 来源与许可

上游项目：[AI-HELP/sdk-ios-example](https://github.com/AI-HELP/sdk-ios-example)。仓库保留上游的 [Apache-2.0 许可证](LICENSE)。SDK 二进制、头文件和资源中的原始版权声明保持不变。
