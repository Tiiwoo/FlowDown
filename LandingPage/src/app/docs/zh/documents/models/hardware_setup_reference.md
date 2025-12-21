# 本地部署实践

摘要：本指南汇总在本地/家庭环境运行自托管语言模型的关键硬件配置，聚焦隐私保护、环境复现与实际可用性。

## 引言

随着硬件性能的提升，单张 NVIDIA RTX 3090 (24GB VRAM) 已足以运行高质量的开源模型。对于注重隐私且希望在本地运行模型的用户，这是一种高性价比的解决方案。

本指南旨在提供隐私场景下的自托管配置参考，而非替代商业大模型。示例方案基于约 48GB 总显存（双 RTX 3090 24G），运行三款模型，以覆盖 DeepSeek R1 级别的文本推理、FlowDown（浮望）的工具调用、长上下文处理及视觉识别能力。

如需了解 FlowDown（浮望）的设计与实现，请参阅 [FlowDown 官网](https://flowdown.ai/)

## 需求目标

针对本地部署场景，主要目标包括：

- **优秀的文本处理能力**：支持高质量的对话与逻辑推理。
- **长上下文处理能力**：能够处理繁杂的互联网信息与长文档。
- **基础视觉识别能力**：支持图片内容的读取与分析。
- **基础代码生成能力**：能够辅助编写简单的代码片段。
- **核心功能覆盖**：支持 FlowDown 的对话标题生成、图片识别与工具调用。
- **低延迟响应**：依赖 GPU 加速以确保流畅的交互体验。

## 模型分级

根据参数量与硬件需求，可将模型分为四个等级。家庭环境通常适合运行 70B 以下且经过量化的模型。**加粗部分表示在家庭硬件上具备较高实用价值。**

- 入门/实验级：<7B（如 Llama-1B）
- **简单任务级：7B - 30B（如 Qwen 2.5 7B）**
- **基础任务级：30B - 80B（如 Gemma-3-27B、QWQ-32B、Llama-3-70B）**
- 高级任务级：80B+（如 Command-A 110B、DeepSeek-V3、DeepSeek-R1 671B）

## 参考配置

示例主机配置（用于验证文中数据）：

```text
操作系统：Windows Server 2025 Datacenter (64-bit)
CPU：Intel Core i9-13900K
GPU：2 × NVIDIA GeForce RTX 3090（24GB）
内存：128 GB
存储：1 TB NVMe SSD
```

## 资源占用分析

### 参数量

参数量通常直接反映模型性能。在同代模型中，参数量越大，性能通常越强。

### 上下文窗口

上下文窗口决定了模型处理长文本的能力，是影响用户体验的关键因素。

**在资源有限的情况下，并非参数量越大越好，合适的上下文长度往往更为重要。**

例如，70B 模型虽然推理能力更强，但在显存受限时上下文窗口较小，难以处理长文档或网络搜索结果。相比之下，30B 模型在保留足够上下文窗口的情况下，既能提取关键信息，也能提供良好的基础对话能力。

在 48GB 显存环境下，加载 Int4 量化的 70B 模型后，剩余显存将难以支撑长上下文处理。

### 模型量化

模型量化通过降低参数精度来大幅减少显存占用。针对量化优化的模型性能损失通常较小（约 20% 以内），而未优化的模型可能会出现输出乱码等问题。

**通常建议使用 Int4 量化以平衡性能与资源占用。** 它使用 4 比特整数表示原本的 8 或 16 比特数据。

**本指南均以 Int4 作为最小量化标准。**

### K/V 缓存

K/V 缓存（Key-Value Cache）用于加速 Transformer 模型的推理过程。

**注意：K/V 缓存会占用显著的显存空间，需预留足够余量。**

### 预处理 (Prefill)

预处理阶段的速度直接影响首字延迟。在处理长上下文（如网页搜索结果）时，若预处理速度过慢，会导致明显的等待时间。

**使用支持 CUDA 的设备可显著提升预处理速度。**

在规划家用推理服务器时，应重点关注预处理吞吐量；针对该环节优化的设备可带来数十倍的速度提升。

### 资源参考表

下表展示了不同参数量模型在不同上下文长度下的资源需求估算（参考工具：<https://smcleod.net/vram-estimator/>）：

| 参数量  | 上下文尺寸  | 量化方式 | 模型占用(GB) | K/V缓存(GB) | 总显存占用(GB) |
| ------- | ----------- | -------- | ------------ | ----------- | -------------- |
| **7B**  | 16K tokens  | Q4_0     | 4.4          | 1.0         | 5.5            |
|         | 64K tokens  | Q4_0     |              | 4.1         | 8.6            |
|         | 128K tokens | Q4_0     |              | 8.3         | 12.7           |
| **14B** | 16K tokens  | Q4_0     | 8.4          | 1.5         | 9.8            |
|         | 64K tokens  | Q4_0     |              | 5.9         | 14.2           |
|         | 128K tokens | Q4_0     |              | 11.7        | 20.1           |
| **32B** | 16K tokens  | Q4_0     | 18.5         | 2.2         | 20.7           |
|         | 64K tokens  | Q4_0     |              | 8.9         | 27.3           |
|         | 128K tokens | Q4_0     |              | 17.7        | 36.2           |
| **70B** | 16K tokens  | Q4_0     | 39.8         | 3.3         | 43.1           |
|         | 64K tokens  | Q4_0     |              | 13.1        | 超出显存       |
|         | 128K tokens | Q4_0     |              | 26.2        | 超出显存       |

## 模型选择策略

基础模型的选择直接决定日常使用体验。在家庭硬件部署场景下，需在模型性能与资源消耗之间寻找平衡点。对于显存受限的家用设备，高性能模型的选择范围相对有限。

此外，单一模型难以兼顾所有场景，建议按任务需求拆分为主模型、辅助模型与视觉模型搭配使用。

### 前置条件

#### 硬件限制 - 显存分配

根据前文数据：若需部署第二个模型，即使对 70B 模型采用最紧凑的 Q4_0 量化（约 43.1GB 显存），在双 RTX 3090（总显存 48GB）环境下，剩余显存不足 5GB。这通常无法满足加载另一个可用级别模型（至少需 5.5GB）的需求，从而限制了多任务并行能力。

#### 软件兼容性

LM Studio 是家用硬件上较为易用的选择，基于 llama.cpp 构建，支持 CUDA 与 ROCm 加速。用户可根据目标模型特性进行进一步的性能调优。

### 推荐搭配示例

在双 RTX 3090（总显存 48GB）环境下，推荐使用 `gemma-3-27b-int4-qat` 作为主模型，并启用视觉与工具调用功能（模板见文末）。

**示例运行参数：**

- 上下文长度 (Context Length)：100K
- GPU 装载 (Offload)：全部
- CPU 线程池 (Thread Pool)：最大值或 16
- 批处理大小 (Batch Size)：16K
- 随机种子 (Seed)：-1 (随机)
- Flash Attention：启用
  - K 量化：Q4_0
  - V 量化：Q4_0

## 功能演示

### 网络搜索

### 视觉识别

### 文档处理

### 工具调用

## 结语

本地部署方案能够在保障隐私的前提下，减少对云端服务的依赖。建议根据硬件预算灵活调整上下文长度与量化方案；随着模型技术的快速迭代，定期评估并更新配置将有助于保持最佳体验。

---

## 附录：自定义 Jinja 模版

<details>
<summary>展开查看自定义 Jinja 模版</summary>

```jinja
{{ bos_token }}
{%- if messages[0]['role'] == 'system' -%}
    {%- if messages[0]['content'] is string -%}
        {%- set first_user_prefix = messages[0]['content'] + '\n\n' -%}
    {%- else -%}
        {%- set first_user_prefix = messages[0]['content'][0]['text'] + '\n\n' -%}
    {%- endif -%}
    {%- set loop_messages = messages[1:] -%}
{%- else -%}
    {%- set first_user_prefix = "" -%}
    {%- set loop_messages = messages -%}
{%- endif -%}
{%- if not tools is defined %}
    {%- set tools = none %}
{%- endif %}
{%- for message in loop_messages -%}
    {%- if (message['role'] == 'assistant') -%}
        {%- set role = "model" -%}
    {%- elif (message['role'] == 'tool') -%}
        {%- set role = "user" -%}
    {%- else -%}
        {%- set role = message['role'] -%}
    {%- endif -%}
    {{ '<start_of_turn>' + role + '\n' -}}
    {%- if loop.first -%}
        {{ first_user_prefix }}
        {%- if tools is not none -%}
            {{- "You have access to the following tools to help respond to the user. To call tools, please respond with a python list of the calls. DO NOT USE MARKDOWN SYNTAX.\n" }}
            {{- 'Respond in the format [func_name1(params_name1=params_value1, params_name2=params_value2...), func_name2(params)] \n' }}
            {{- "Do not use variables.\n\n" }}
            {%- for t in tools -%}
                {{- t | tojson(indent=4) }}
                {{- "\n\n" }}
            {%- endfor -%}
        {%- endif -%}
    {%- endif -%}

    {%- if 'tool_calls' in message -%}
        {{- '[' -}}
        {%- for tool_call in message.tool_calls -%}
            {%- if tool_call.function is defined -%}
                {%- set tool_call = tool_call.function -%}
            {%- endif -%}
            {{- tool_call.name + '(' -}}
            {%- for param in tool_call.arguments -%}
                {{- param + '=' -}}
                {{- "%sr" | format(tool_call.arguments[param]) -}}
                {%- if not loop.last -%}, {% endif -%}
            {%- endfor -%}
            {{- ')' -}}
            {%- if not loop.last -%},{%- endif -%}
        {%- endfor -%}
        {{- ']' -}}
    {%- endif -%}

    {%- if (message['role'] == 'tool') -%}
        {{ '<tool_response>\n' -}}
    {%- endif -%}
    {%- if message['content'] is string -%}
        {{ message['content'] | trim }}
    {%- elif message['content'] is iterable -%}
        {%- for item in message['content'] -%}
            {%- if item['type'] == 'image' -%}
                {{ '<start_of_image>' }}
            {%- elif item['type'] == 'text' -%}
                {{ item['text'] | trim }}
            {%- endif -%}
        {%- endfor -%}
    {%- else -%}
        {{ raise_exception("Invalid content type") }}
    {%- endif -%}
    {%- if (message['role'] == 'tool') -%}
        {{ '</tool_response>' -}}
    {%- endif -%}
    {{ '<end_of_turn>\n' }}
{%- endfor -%}
{%- if add_generation_prompt -%}
    {{'<start_of_turn>model\n'}}
{%- endif -%}
```

</details>

