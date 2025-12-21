# 基础使用

浮望提供沉浸式对话界面，支持运行本地模型，并可通过 iCloud 同步数据。本页将首次会话步骤与日常用法合并讲解。

## 创建你的第一条对话

1. 打开浮望，点击侧边栏 **新建会话**，底部会出现输入框。
2. 在输入框下方选择模型（本地 MLX、云端模板、Apple Intelligence，或新用户的免费额度）。
3. 根据需要打开输入框上方的 **Tools**（日历/定位/记忆/MCP）与 **Web Browsing**，启用 **记忆** 可将要点写入长期记忆。
4. 输入消息，`Shift + Enter` 换行。可拖入文本/Markdown、PDF、PNG/JPEG/WebP/HEIC、音频（m4a/wav，其他自动转码）作为附件。
5. 按 `Enter`（或点击发送）发送。需要暂停回复时，可用停止按钮或右上角对话菜单。

![会话界面](../../../res/screenshots/imgs/conversation-main-view.png)

## 会话管理

- 左侧列表显示所有会话。点击即可切换，触屏设备可滑动切换，右键/长按可打开快捷菜单。
- 模型会在第一条回复后自动生成标题和图标，可通过快捷菜单的 **重命名**、**更换图标** 调整。
- 使用 **复制** 创建会话分支（Fork），用 **归档** 临时隐藏而不删除。
- 需单独调节工具、联网或系统提示时，打开快捷菜单的 **会话设置**。

![会话快捷菜单](../../../res/screenshots/imgs/conversation-set-new-icon.png)

## 界面与显示

- 回复支持完整 Markdown（表格、代码块、引用）。若偏好列表模式，可在 **设置 → 对话界面** 中切换。
- 在消息菜单里，**原始数据** 可查看完整提示词和附件上下文，也可复制/导出/归档会话。

## 跨设备同步

浮望默认将数据保存在本地，也可选择通过 CloudKit 同步。

- 在各设备的 **设置 → 数据控制 → iCloud 同步** 中开启同步。侧边栏会显示最近一次同步状态与待上传更改。
- 新设备接入或解决冲突后，可执行 **从 iCloud 完全刷新** 保持一致。
- 随时可通过 **设置 → 数据控制 → 导出工作区** 备份；恢复会合并会话、模型与附件。

![同步范围设置](../../../res/screenshots/imgs/configuring-sync-scope.png)

## 下一步

- 使用内置工具：[工具](../capabilities/tools_automation.md)、[网络搜索](../capabilities/web_search.md)。
- 场景示例：参考 [日历工作流](../guides/calendar_workflow.md) 等指南。
- 配置推理与模型：[云端模型设置](../models/cloud_models_setup.md)、[推理配置](../models/inference_configuration.md)。
