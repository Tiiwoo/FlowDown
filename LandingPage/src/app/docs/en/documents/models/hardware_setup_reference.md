# Local Deployment Hardware Guide

Summary: this guide distills key hardware setups for running self-hosted language models at home, focusing on privacy, reproducibility, and practical usability.

## Introduction

A single NVIDIA RTX 3090 (24GB VRAM) can already run strong open-source models. For privacy-focused users, this is a cost-effective way to host models locally.

![](../../../res/extra/593b38fa-3d96-418f-b422-267d990b2e4e.png)

Here we aim to offer a reference for privacy scenarios rather than replacing commercial models. The example setup uses ~48GB total VRAM (dual RTX 3090 24G) to run three models, covering DeepSeek R1-class text reasoning, FlowDown tool use, long context, and vision.

For FlowDown’s design details, visit [https://flowdown.ai/](https://flowdown.ai/)

## Goals

For local deployment, the main goals are:

- **Strong text capability** for high-quality dialog and reasoning
- **Long context handling** to process web information and long documents
- **Basic vision** to read and analyze images
- **Basic code generation** for small snippets
- **Core FlowDown features**: title generation, image recognition, tool calls
- **Low-latency responses** with GPU acceleration

## Model Tiers

By parameter count and hardware needs, models fall into four tiers. Home setups usually run ≤70B with quantization. **Bold items are practical on home hardware.**

- Entry/experimental: <7B (e.g., Llama-1B)
- **Simple tasks: 7B–30B (e.g., Qwen 2.5 7B)**
- **Basic tasks: 30B–80B (e.g., Gemma-3-27B, QWQ-32B, Llama-3-70B)**
- Advanced: 80B+ (e.g., Command-A 110B, DeepSeek-V3, DeepSeek-R1 671B)

## Reference Configuration

Example host used to validate the figures in this guide:

```text
OS: Windows Server 2025 Datacenter (64-bit)
CPU: Intel Core i9-13900K
GPU: 2 × NVIDIA GeForce RTX 3090 (24GB)
Memory: 128 GB
Storage: 1 TB NVMe SSD
```

## Resource Analysis

### Parameter Count

Parameter count often tracks model quality within the same generation: more parameters usually mean stronger performance.

### Context Length

Context size governs how much text the model can keep in working memory and often matters more than raw size. With limited VRAM, a 70B model may leave too little context budget to handle long documents or web results. In a 48GB setup, one int4-quantized 70B model leaves little headroom for long context. A 30B model with ample context can stay coherent and useful.

### Quantization

Quantization shrinks VRAM use by lowering precision. Well-optimized quantized models usually keep performance within ~20% of full precision; poorly optimized ones can break and emit gibberish. **Int4 is a practical minimum**—the guide assumes Q4_0.

### K/V Cache

K/V cache speeds up Transformer inference but consumes notable VRAM. Reserve enough headroom.

### Preprocessing

Prefill speed drives first-token latency, especially with long context (e.g., web search results). CUDA-capable devices help a lot, and hardware optimized for prefill can deliver tens-of-times speedups. When building a home inference server, prioritize strong prefill throughput.

### Reference Table

Resource estimates for different model sizes and contexts (tool: <https://smcleod.net/vram-estimator/>):

| Parameters | Context Size | Quantization | Model Size (GB) | K/V Cache (GB) | Total VRAM Usage (GB) |
| ---------- | ------------ | ------------ | --------------- | -------------- | --------------------- |
| **7B**     | 16K tokens   | Q4_0         | 4.4             | 1.0            | 5.5                   |
|            | 64K tokens   | Q4_0         |                 | 4.1            | 8.6                   |
|            | 128K tokens  | Q4_0         |                 | 8.3            | 12.7                  |
| **14B**    | 16K tokens   | Q4_0         | 8.4             | 1.5            | 9.8                   |
|            | 64K tokens   | Q4_0         |                 | 5.9            | 14.2                  |
|            | 128K tokens  | Q4_0         |                 | 11.7           | 20.1                  |
| **32B**    | 16K tokens   | Q4_0         | 18.5            | 2.2            | 20.7                  |
|            | 64K tokens   | Q4_0         |                 | 8.9            | 27.3                  |
|            | 128K tokens  | Q4_0         |                 | 17.7           | 36.2                  |
| **70B**    | 16K tokens   | Q4_0         | 39.8            | 3.3            | 43.1                  |
|            | 64K tokens   | Q4_0         |                 | 13.1           | N/A (OOM)             |
|            | 128K tokens  | Q4_0         |                 | 26.2           | N/A (OOM)             |

## Model Selection Strategy

Base model choice decides daily experience. On home hardware, balance performance with VRAM: one model rarely covers every task, so pair a main model with helpers (e.g., vision/tool models).

### Prerequisites

#### Hardware limits — VRAM allocation

From the table: even the tightest Q4_0 70B model uses ~43.1GB. On dual RTX 3090s (48GB total), less than 5GB remains—insufficient for another usable model (≥5.5GB), limiting parallel workloads.

#### Software compatibility

LM Studio is user-friendly on home rigs, built on llama.cpp with CUDA/ROCm support. Tune settings per checkpoint.

### Recommended Loadout

On dual RTX 3090s (48GB total), a balanced pick is `gemma-3-27b-int4-qat` with vision and tool calling enabled (template below). Example runtime settings:

- Context Length: 100K
- GPU Offload: Full
- CPU Thread Pool: Max or 16
- Batch Size: 16K
- Seed: -1 (random)
- Flash Attention: On
  - K Quantization: Q4_0
  - V Quantization: Q4_0

## Demonstrations

### Web Search

![](../../../res/extra/aba67650-9cab-4133-9d4a-a96f072da9ca.png)

### Vision

![](../../../res/extra/792a3e8a-0eb8-468e-b1b2-8540dac810bd.png)

### Document Processing

![](../../../res/extra/c89e61c3-f939-4a15-8a61-a197a4293e39.png)

### Tool Calling

![](../../../res/extra/09558bee-e8e7-4e7a-b489-2f6b10c22a47.png)

## Conclusion

Local deployment protects privacy and reduces cloud dependence. Adjust context length and quantization to fit your hardware budget, and revisit settings as models evolve.

---

## Custom Jinja Template

<details>
<summary>Click to view custom Jinja template</summary>

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

