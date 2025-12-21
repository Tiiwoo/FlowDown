# 模型交换协议

模型交换协议（Model Exchange Protocol）允许您的应用程序安全地从 FlowDown 请求和接收已配置的语言模型。通过使用 `FlowDownModelExchange` 框架，您可以轻松处理安全的握手和数据传输，而无需让用户手动复制粘贴敏感凭证。

![模型交换界面](../../../res/screenshots/imgs/model-exchange-interface.png)

::: info 版本要求
此协议需要用户设备上安装有 **4.1.4** 或更高版本的浮望。
:::

## 安装

目前 `FlowDownModelExchange` 作为 FlowDown 源码的一部分发布，尚未托管在独立的公共仓库中。您需要手动集成。

1.  在 FlowDown 仓库中找到 `Frameworks/FlowDownModelExchange` 目录。
2.  将整个文件夹复制到您的项目工作区中。
3.  在 Xcode 中将其添加为 **本地包 (Local Package)** (File -> Add Package Dependencies -> Add Local...)，或直接将源文件包含在您的构建目标中。

## 使用指南

### 1. 初始化

首先，初始化密钥对。如果您希望在不同会话中保持相同的身份，应该持久化存储该密钥对，或者为每次会话生成新的密钥对。

```swift
import FlowDownModelExchange

// 生成用于加密和签名的新密钥对
let keyPair = ModelExchangeKeyPair()

// 初始化请求构建器
let builder = ModelExchangeRequestBuilder(
    callbackScheme: "my-app-scheme", // 您的 App URL Scheme
    keyPair: keyPair
)
```

### 2. 请求模型

当您需要从 FlowDown 获取模型时，使用构建器创建签名 URL 并打开它。

```swift
func requestModels() {
    do {
        // 创建签名请求 URL
        let request = try builder.makeExchangeURL(
            session: UUID().uuidString,
            appName: "My Awesome App",
            reason: "为了辅助代码编写",
            capabilities: [.audio, .developerRole], // 筛选所需的模型能力
            multipleSelection: false
        )

        // 打开 FlowDown
        UIApplication.shared.open(request.url)
    } catch {
        print("构建请求失败: \(error)")
    }
}
```

### 3. 处理响应

配置您的 App 以处理回调 URL（例如在 `onOpenURL` 或 `AppDelegate` 中）。

```swift
func handleCallback(url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems else { return }

    let params = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })

    // 检查阶段
    if params["stage"] == "completed" {
        handleCompletion(params: params)
    } else if params["stage"] == "cancelled" {
        print("用户取消了操作")
    }
}
```

### 4. 解密数据

收到 `completed` 回调后，通过框架解码并解密 Payload。

```swift
func handleCompletion(params: [String: String]) {
    guard let payloadString = params["payload"],
          let sessionID = params["session"] else { return }

    do {
        // 1. 解码加密的 Payload 包装器
        let encryptedPayload = try ModelExchangeEncryptedPayload.decode(from: payloadString)

        // 2. 使用您的密钥对解密数据
        let decryptedData = try ModelExchangeCrypto.decrypt(
            encryptedPayload,
            with: keyPair
        )

        // 3. 解析模型数据 (通常为 Property List)
        let models = try PropertyListSerialization.propertyList(
            from: decryptedData,
            options: [],
            format: nil
        )

        print("收到模型: \(models)")
    } catch {
        print("解密失败: \(error)")
    }
}
```

## 安全性

框架自动为您处理复杂的安全细节：

- **签名验证**：请求使用您的私钥签名，防止篡改。
- **数据加密**：使用 `ChaChaPoly` (对称加密) 和 `Curve25519` (密钥协商) 对数据进行加密。
- **前向保密**：交换会话使用临时密钥。

## 数据格式

解密后的数据是一个序列化的属性列表 (Plist)，其中包含：

- 模型显示名称
- 端点 URL
- 认证头 (包含敏感凭证)
- 模型能力

请务必以最高安全级别处理此数据。**切勿在生产环境中打印或记录敏感字段**。
