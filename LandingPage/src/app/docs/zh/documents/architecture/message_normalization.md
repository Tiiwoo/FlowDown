# ChatClientKit 对话消息规范化（兼容性处理）

本页解释 `ChatClientKit` 在发起请求前如何“清洗”消息，以确保对 OpenAI 风格、Anthropic、Mistral 等多种接口的兼容性。对话消息整理器运行在 `RemoteCompletionsChatClient`、`RemoteResponsesChatClient` 以及 MLX 客户端中。

## 为什么需要对话消息整理器

- **角色交替**：部分 API 严格要求 user/assistant 角色交替出现，且不接受空内容。
- **工具回复**：工具调用（tool call）必须紧跟对应的工具回复（tool response），否则 API 会拒绝继续生成。
- **Strict 模式**：当工具列表中混合出现 `strict` 标记时，部分网关会报错。
- **稳定性**：统一的消息格式让重试机制和流式恢复更加可预测。

## 规则管线（按执行顺序）

1. **合并 System 消息**：将所有 `.system` 消息合并为一条，保留首个 `name` 属性，过滤掉空内容，避免多段系统提示重复注入。
1. **助手前置 User 上下文**：如果助手消息（assistant）缺少前置的用户消息（user），则插入占位符 `.user "."`，以满足“用户→助手”交替的接口要求。
1. **补齐 Tool 响应**：对于每个助手消息中的 `tool_call`，若缺少对应的 `.tool` 回复，则插入 `.tool "."` 并复用同一 `toolCallID`，确保链路完整（助手→工具→助手）。
1. **末尾 User 文本**：若最后一条消息不是用户文本，则追加 `.user "."`，确保模型在工具调用后仍可继续生成，而不会停留在工具调用阶段。
1. **统一 Strict 工具**：只要任意工具声明了 `strict: true`，就将所有工具都改写为 `strict: true`，避免因“部分严格”导致的兼容性错误。

**注**：占位内容使用单个点号 `"."`，既满足最小内容校验，又尽量不干扰模型语义。
