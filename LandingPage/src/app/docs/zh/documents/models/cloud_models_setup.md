# 配置云端模型

浮望支持所有兼容 OpenAI 的 HTTPS 服务（chat completions 和 responses）。应用里自带了动态模板（包括 pollinations.ai 的免费模型），可以直接开始对话，或者按需获取预置配置。

## 获取最新模板

1. 打开 **设置 → 模型**。
1. 点击右上角的 **＋**。
1. 在 **云端模型** 里选 **pollinations.ai（免费）** 获取当前匿名的文本模型，会自动配好端点和上下文；或者选 **空白模型配置（Empty Model）** 自己从头配。
1. 想复用以前存的配置？选 **导入模型 → 从文件导入**，加载导出的 `.fdmodel` / `.plist` 文件。

![获取云端模型模板](../../../res/screenshots/imgs/cloud-model-pollinations-fetch.png)

随时打开 **云端模型** 菜单都能刷新 pollinations.ai 列表，或者添加新的空白配置；模型列表是按需动态加载的。

## 连接自定义服务

1. 新建空白配置，或者打开现有的配置。
1. 填完整的推理地址（比如 `https://api.example.com/v1/chat/completions` 或者 `/v1/responses`）。FlowDown 会自动识别并设置 **内容格式**，如果识别不对可以手动切。
1. 设置模型标识。点这个字段可以 **获取模型列表**，会调用列表接口（默认把 `$INFERENCE_ENDPOINT$/../../models` 占位符替换掉；如果服务商路径不一样，记得改一下）。
1. 填推理服务凭证/工作组（会以 Bearer **Authorization** 发送）和需要的 Header。自定义 Header 可以覆盖 Authorization，适配特殊的鉴权方式。
1. 在 **请求体字段** 里追加 JSON；快捷菜单可以插入推理开关（`enable_thinking` / `reasoning` 和预算）、采样参数、输入/输出模态或者 provider 标记。
1. 按接口支持的情况勾选能力（工具、视觉、音频、开发者角色），设置上下文长度和昵称，然后保存。

> 提示：编辑器里的 `⋯` 可以 **验证模型**（连通性）、**复制** 或 **导出模型** 方便版本管理。

![验证模型连通性](../../../res/screenshots/imgs/cloud-model-verify-model.png)

## 最佳实践

- **端点与格式**：推理 URL 和 **内容格式**（chat completions vs responses）要一致，不然会报 HTTP 错误。
- **模型列表**：配好模型列表端点用 **从服务器选择**，省得手动输 ID。
- **pollinations**：免费模型有频率和地区限制，如果用不了，请接入你自己的服务商。
- **请求体字段**：通过 **请求体字段** 加服务商特定的键（推理预算、`top_p` / `top_k`、模态等），保证 JSON 格式是对的。
- **备份**：模型定义会跟着 iCloud 同步和工作区导出。大改之前先执行 **设置 → 数据控制 → 导出工作区**。

## 进阶：自定义/企业配置 {#进阶自定义企业配置}

适用于私有部署或专用网关。请只连接可信端点，错误配置可能导致数据泄露或额外费用。

- **创建方式**：在 **设置 → 模型 → ＋ → 云端模型 → 空白模型配置（Empty Model）**。可直接编辑，或导出 `.fdmodel` 后用外部编辑器修改再导入。
- **关键字段**（未用可留空/空集合）：

  | 键 | 作用 |
  | --- | --- |
  | `endpoint` | 推理接口 `/v1/chat/completions` 或 `/v1/responses`，必须与 `response_format` 一致。 |
  | `response_format` | `chatCompletions` 或 `responses`，与端点匹配。 |
  | `model_identifier` | 发送给服务商的模型名称。 |
  | `model_list_endpoint` | 模型列表接口（默认 `$INFERENCE_ENDPOINT$/../../models`），供“从服务器选择”使用。 |
  | `token` / `headers` | 鉴权信息；自定义 Header 可覆盖默认 `Authorization: Bearer ...`。 |
  | `body_fields` | 追加到请求体的 JSON 字符串，可写推理开关、预算、采样参数等。 |
  | `capabilities` / `context` / `name` / `comment` | 声明能力、上下文长度、展示名与备注，决定 UI 开关与裁剪策略。 |

- **验证与审计**：保存后用 `⋯ → 验证模型` 测试；在 **设置 → 支持 → 日志** 审计调用。闲置时请移除或禁用配置。
