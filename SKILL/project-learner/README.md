# Project Learner

一个面向 Codex 的项目学习 Skill。它会从本地代码、配置、测试和项目文档中提取证据，帮助你快速建立代码库的整体认知，并逐步深入到核心模块、调用链路、设计取舍与故障场景。

## 功能特点

- 从实际源码出发，不预设语言、框架或项目结构
- 自动梳理项目架构、入口、核心模块和端到端流程
- 根据当前项目动态生成学习目录
- 支持概览、引导式学习、代码走读、知识检查和学习计划
- 使用真实文件、符号、配置与测试支撑讲解
- 支持围绕一次请求、事件或数据对象追踪完整调用链
- 知识检查一次只问一个问题，并根据回答继续追问
- 默认只在对话中记录进度，不会擅自修改目标项目

## 安装

### 使用 SSH

```powershell
git clone git@github.com:EdmendZ/project-learner.git "$env:USERPROFILE\.codex\skills\project-learner"
```

### 使用 HTTPS

```powershell
git clone https://github.com/EdmendZ/project-learner.git "$env:USERPROFILE\.codex\skills\project-learner"
```

如果目录已经存在，可以在该目录中更新：

```powershell
git -C "$env:USERPROFILE\.codex\skills\project-learner" pull
```

## 使用方法

在 Codex 中明确调用 `$project-learner`，并说明要学习的项目或目录。

### 快速了解项目

```text
使用 $project-learner 帮我快速了解当前项目。
```

### 指定本地项目

```text
使用 $project-learner 学习 E:\Projects\demo-service，
先梳理整体架构和一次请求的完整调用链。
```

### 引导式学习

```text
使用 $project-learner 带我逐步学习这个项目。
每次讲一个主题，讲完后问我一个检查问题。
```

### 代码走读

```text
使用 $project-learner 追踪用户登录请求，
从接口入口一直讲到数据库和外部依赖。
```

### 知识检查

```text
使用 $project-learner 检查我对当前项目的掌握程度，
一次问一个问题，并根据源码评价我的回答。
```

### 生成学习计划

```text
使用 $project-learner 为当前项目生成一份循序渐进的学习计划。
```

## 学习模式

| 模式 | 适用场景 |
|---|---|
| 项目概览 | 快速理解项目作用、结构和端到端流程 |
| 引导式学习 | 按主题逐步学习，并检查理解情况 |
| 代码走读 | 沿具体请求、事件或数据对象追踪源码 |
| 知识检查 | 使用源码支持的问题检验掌握程度 |
| 学习计划 | 生成与当前项目匹配的学习目录和阅读顺序 |

## 工作方式

Project Learner 通常会：

1. 确认需要学习的项目目录。
2. 检查项目说明、依赖清单、源码入口、配置和测试。
3. 建立由 5～10 个项目特定主题组成的学习地图。
4. 先讲整体关系，再深入具体文件和符号。
5. 给出源码阅读任务、验证命令或理解问题。
6. 总结已掌握内容、薄弱点和下一步建议。

如果项目证据不足或不同文件互相矛盾，它会明确说明不确定性，而不是凭空补全结论。

## 学习进度

学习进度默认保留在当前对话中，不会修改目标代码库。

只有在你明确要求持久化时，才会建议将进度保存到目标项目的：

```text
.codex/project-learning.md
```

创建文件前仍会请求你的确认。

## 项目别名

你可以在 `AGENTS.md` 中定义项目名称与真实目录的映射。之后直接使用别名，Project Learner 会按照该映射定位项目。

示例：

```markdown
- “项目1”固定指向 `E:\Projects\project-one`。
- “项目2”固定指向 `E:\Projects\project-two`。
```

## 目录结构

```text
project-learner/
├── agents/
│   └── openai.yaml
├── README.md
└── SKILL.md
```

- `SKILL.md`：Project Learner 的完整执行规则
- `agents/openai.yaml`：Skill 的显示名称、简介和默认提示词
- `README.md`：面向使用者的安装与使用说明

## 注意事项

- Skill 会优先读取项目源码与文档，但不会主动暴露环境变量或凭据文件中的秘密。
- 默认不会为了记录学习进度而修改目标仓库。
- 讲解质量取决于本地项目中可读取的源码、配置、测试和文档。
- 项目规模较大时，建议指定子系统、请求链路或学习目标，以获得更聚焦的结果。
