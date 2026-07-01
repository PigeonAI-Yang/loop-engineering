# py-loop-engineering Agent Rules

本项目用于维护 `loop-engineering` Codex Skill。

## Goal

把 loop engineering 做成可复用的 Skill，而不是一段临场提示词。

## Required Workflow

1. 先读 `loop-engineering/SKILL.md`。
2. 修改 skill 行为前，检查 `loop-engineering/references/` 和 `loop-engineering/scripts/`。
3. 新增规则时，优先落到 `SKILL.md` 或 references；重复性动作优先落到 scripts。
4. 修改后必须运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check.ps1
```

## Completion Authority

`scripts/check.ps1` 是本项目的最小完成 gate。

不能只因为文件写完、junction 存在、或者人工读起来合理就说完成。

## Stop Conditions

停止并说明原因：

- skill 触发语义不清。
- 脚本验证失败两次且原因不同。
- 需要改动超过 8 个文件。
- 想用口头说明代替可运行验证。
- 生成的 `.ai/loops/LOOP_PROFILE.md` 无法被 agent 直接使用。
