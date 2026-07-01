# PY Loop Engineering

把 AI 开发从「连续提示」变成「可运行、可验证、可复用的工程循环」。

这是一个 Codex Skill。它不是一段临场提示词，而是一套可以落到项目里的 loop engineering harness：每一轮都有输入、边界、状态、验证、停止条件和报告。

## 它解决什么问题

AI agent 很擅长把一个局部任务做漂亮，但很容易忘记整个项目为什么存在。

常见失败不是代码完全不能跑，而是：

- 单个函数通过测试，但真实运行路径根本没有调用它。
- 一个个任务都显示 done，产品目标却没有前进。
- agent 自己写、自己验，最后把半成品当完成。
- 长任务跨会话后丢失状态，下一轮从零开始。
- 自动化越跑越多，却没有预算、停止条件和人工审批边界。

`loop-engineering` 的核心判断很朴素：**一个 loop 只有在能证明自己推进了真实目标时，才算完成。**

## 设计理念

### 1. Project Purpose Anchor

每个项目先写清楚「为什么存在」，不是写它做什么。

例如：

```text
自动交易 Polymarket，捕捉 ≤50ms 的市场机会；本地处理每慢一毫秒都是真钱。
```

每个 loop 开始前，都要重新面对这个目的：当前任务是在推进这个目标，还是只是在制造一个局部正确的零件？

### 2. Chain Gate，而不是 Unit Test

单元测试只能证明函数本身能工作，不能证明系统真的用到了它。

这个 skill 强制使用 end-to-end / chain gate：必须证明新输出出现在下游会读取的位置。只能指向测试文件，不算完成；那叫 orphan task。

### 3. State Outside Chat

agent 会忘，仓库不会。

所以每个项目都会生成：

```text
.ai/loops/LOOP_PROFILE.md
.ai/loops/state.json
.ai/loops/reports/
```

状态、失败、下一步、报告都留在文件里，而不是留在聊天窗口里。

### 4. Budget And Stop Conditions

loop 不是「让 agent 一直试」。

每轮必须提前声明：

- 最大迭代次数
- 最大改动文件数
- 验证命令
- live/browser/action 上限
- 写权限边界
- 什么时候停止并报告

跑不通不是问题。真正的问题是假装跑通。

### 5. Step-Back Alignment

局部 loop 都通过，也可能整体偏航。

这个 skill 要求在阶段边界或若干轮之后停下来检查：已完成的 loop 是否真的连到了生产路径，是否真的让项目更接近它的存在理由。

## 实现方法

仓库结构：

```text
loop-engineering/
  SKILL.md
  agents/openai.yaml
  references/
    loop-patterns.md
    project-loop-profile-template.md
  scripts/
    bootstrap_loop_engineering.ps1
scripts/
  check.ps1
AGENTS.md
```

核心实现很少：

- `SKILL.md` 定义 agent 行为、loop 资格、预算、停止条件和报告格式。
- `references/project-loop-profile-template.md` 定义项目级 loop profile。
- `references/loop-patterns.md` 定义常见 loop 类型。
- `scripts/bootstrap_loop_engineering.ps1` 给任意项目生成 `.ai/loops` harness。
- `scripts/check.ps1` 是最小完成 gate，验证 skill 格式和 bootstrap 输出。

这个设计刻意不做复杂平台。PowerShell、Markdown、JSON 就够了。真正重要的是 gate 和状态，不是框架。

## 安装到 Codex

### Windows

克隆仓库：

```powershell
git clone https://github.com/PigeonAI-Yang/loop-engineering.git J:\PigeonYang\py-loop-engineering
```

把 skill 挂到 Codex skills 目录：

```powershell
New-Item -ItemType Junction `
  -Path "$HOME\.codex\skills\loop-engineering" `
  -Target "J:\PigeonYang\py-loop-engineering\loop-engineering"
```

验证：

```powershell
cd J:\PigeonYang\py-loop-engineering
powershell -ExecutionPolicy Bypass -File scripts\check.ps1
```

### macOS / Linux

```bash
git clone https://github.com/PigeonAI-Yang/loop-engineering.git ~/py-loop-engineering
ln -s ~/py-loop-engineering/loop-engineering ~/.codex/skills/loop-engineering
```

验证：

```bash
cd ~/py-loop-engineering
powershell -ExecutionPolicy Bypass -File scripts/check.ps1
```

如果没有 PowerShell，可以直接阅读 `scripts/check.ps1` 对应逻辑；这个项目本身主要面向 Codex Desktop / Windows 工作流。

## 使用方式

在 Codex 里直接说：

```text
使用 loop-engineering，给当前项目建立可验证的开发循环。
```

或者在已有 harness 的项目里说：

```text
使用 loop-engineering，运行下一个 bounded loop。
```

首次 bootstrap 会生成：

```text
.ai/loops/LOOP_PROFILE.md
.ai/loops/state.json
.ai/loops/reports/
```

如果 `Project Purpose` 还是占位符，第一轮只能补目的锚点，不能直接写功能。

## 适合什么项目

适合：

- 有测试、构建、lint 或其他客观 gate 的项目。
- 有重复任务、任务 ledger、issue、CI failure、release closure 的项目。
- 需要跨会话保留状态和报告的 agent 工作流。

不适合：

- 目标不清楚的探索。
- 完全靠审美或主观判断验收的任务。
- 没有自动验证，也不打算先补 gate 的项目。
- 想让 agent 无限制自动改、自动发、自动部署的场景。

## 作者

PigeonAI-Yang

