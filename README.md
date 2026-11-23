# 生命进化 · Life Evolution

一款参考抖音小游戏《生命进化录》思路制作的 iOS 放置点击进化游戏。纯 Objective-C + UIKit，用 [Theos](https://theos.dev) 交叉编译成 **未签名 ipa**，需自行用 TrollStore / AltStore / 开发者证书签名后安装。

> 仅用于个人学习与自用，不含任何联网、内购、广告或统计 SDK。

## 玩法概要

- **48 个进化形态**：细菌 → 藻类 → 海绵 → 水母 → 小鱼 → … → 太一 → 归零者 → 终焉之外
- **产线购买**：每条产线独立成长，支持 1 / 10 / 100 / 最大 四种购买批量，20 档里程碑自动翻倍
- **点击连击**：连击倍率、暴击、飘字、粒子、涟漪、冲击波、整机 120Hz 震动反馈
- **飞升（Ascension）**：重置进度换取 DNA，永久提升产出与难度缩放
- **基因组强化**：8 条永久强化（离线收益、基因强化、点击、孢子亲和、自动触手、飞升红利、起始遗泽、孢子之频）
- **12 种变异**：任意 3 选 1，含稀有度与叠层上限（掠食、高效、猎手、节奏掌控、群体共鸣、孢子狂喜、连锁暴击、孢子雨、节奏大师、进化余温、暴击回响）
- **图鉴**：48 条形态设定文本，每解锁一个形态永久 +2% 产出
- **转生遗物**：6 件遗物 + 8 项成就，遗物点来自飞升与成就奖励
- **守关者试炼**：每 6 级一个守关者，40 秒内点击击破才能继续进化
- **时代事件**：陨石、寒武爆发、超新星、熵坍缩，影响产出与成本
- **配乐与背景**：10 首程序化生成的 8 分钟配乐、8 张 4K 时代全景，随形态交叉淡化切换

## 目录结构

```
.
├── main.m
├── AppDelegate.h / AppDelegate.m
├── GameViewController.h / GameViewController.m   # 全部游戏逻辑与 UI
├── Resources/
│   ├── Info.plist
│   ├── AppIcon60x60@2x.png / @3x.png
│   └── art_*.m4a / art_*.jpg                     # 配乐与时代背景（不入库）
├── Makefile
└── control
```

## 构建

依赖：Theos + iOS SDK 16.5 + iPhoneOS 工具链。

```bash
export THEOS=/path/to/theos
make
make package FINALPACKAGE=1 PACKAGE_FORMAT=ipa
```

产物在 `packages/com.demo.lifeevolution_<version>.ipa`，可执行文件为 arm64，最低系统 iOS 14.0。

## 版本

| 版本 | 内容 |
| --- | --- |
| 6.3.1 | 轻量包（AAC 160k 配乐 + 2048 JPEG 背景，约 97MB），玩法与 6.3 完全一致 |
| 6.3 | 图鉴、转生遗物、成就、守关者试炼、时代事件；1.1GB 高清包 |
| 6.2 | 10 首配乐 + 8 张 4K 全景；移除所有加速类基因与变异 |

## 安装

ipa 未签名。使用 TrollStore 直接安装，或用 AltStore / Sideloadly 以自己的 Apple ID 重签。
