#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreHaptics/CoreHaptics.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

// ================= 阶段配置 =================
typedef struct {
    const char *name;
    const char *emoji;
    const char *era;
    CGFloat bgR, bgG, bgB;       // 背景主色
    CGFloat acR, acG, acB;       // 强调色
} Stage;

static const Stage kStages[] = {
    {"原始细胞", "🔴", "生命起源",   0.16,0.04,0.05,  0.95,0.45,0.25},
    {"细菌",     "🦠", "生命起源",   0.18,0.07,0.03,  0.95,0.55,0.25},
    {"藻类",     "🌿", "原始海洋",   0.03,0.13,0.06,  0.45,0.90,0.45},
    {"海绵",     "🧽", "埃迪卡拉纪", 0.03,0.14,0.11,  0.40,0.90,0.65},
    {"水母",     "🪼", "寒武纪",     0.03,0.08,0.18,  0.45,0.70,1.00},
    {"贝类",     "🐚", "奥陶纪",     0.03,0.10,0.16,  0.55,0.80,0.90},
    {"小鱼",     "🐟", "志留纪",     0.02,0.06,0.16,  0.40,0.65,0.95},
    {"热带鱼",   "🐠", "泥盆纪",     0.02,0.12,0.16,  0.35,0.85,0.90},
    {"海龟",     "🐢", "石炭纪",     0.03,0.12,0.12,  0.45,0.85,0.70},
    {"青蛙",     "🐸", "二叠纪",     0.05,0.14,0.05,  0.55,0.90,0.40},
    {"蜥蜴",     "🦎", "三叠纪",     0.10,0.12,0.04,  0.75,0.85,0.35},
    {"恐龙",     "🦖", "侏罗纪",     0.04,0.10,0.04,  0.40,0.80,0.35},
    {"猿猴",     "🦍", "新近纪",     0.12,0.08,0.04,  0.85,0.65,0.40},
    {"人类",     "🧍", "第四纪",     0.06,0.05,0.14,  0.65,0.60,1.00},
    {"文明",     "🏙️", "文明时代",   0.10,0.04,0.16,  0.80,0.50,1.00},
    {"星际文明", "🚀", "星际时代",   0.02,0.02,0.09,  0.55,0.75,1.00},
    {"星系文明", "🌌", "银河时代",   0.04,0.02,0.10,  0.55,0.65,1.00},
    {"星系主宰", "🪐", "星系时代",   0.09,0.04,0.13,  0.80,0.55,1.00},
    {"量子生命", "⚛️", "量子时代",   0.02,0.09,0.13,  0.35,0.95,0.95},
    {"时空之灵", "⏳", "时间时代",   0.10,0.07,0.02,  1.00,0.85,0.45},
    {"维度生命", "🌀", "高维时代",   0.10,0.02,0.11,  0.95,0.45,0.95},
    {"宇宙意识", "🌠", "宇宙时代",   0.03,0.02,0.07,  1.00,0.90,0.60},
    {"观测之眼", "👁️", "观测时代",   0.02,0.05,0.09,  0.60,0.95,0.85},
    {"终极文明", "✴️", "终结时代",   0.06,0.02,0.04,  1.00,0.55,0.55},
    {"概念生命", "🧠", "概念时代",   0.05,0.03,0.12,  0.70,0.60,1.00},
    {"多元宇宙", "🌐", "多元时代",   0.02,0.06,0.12,  0.45,0.85,1.00},
    {"弦之生命", "🎻", "弦论时代",   0.10,0.03,0.08,  1.00,0.50,0.70},
    {"时间尽头", "♾️", "永恒时代",   0.02,0.03,0.10,  0.60,0.80,1.00},
    {"虚无之主", "🕳️", "虚无时代",   0.02,0.02,0.03,  0.85,0.85,0.95},
    {"叙事存在", "📜", "叙事时代",   0.11,0.08,0.03,  1.00,0.82,0.45},
    {"创世者",   "👑", "创世时代",   0.12,0.06,0.02,  1.00,0.72,0.30},
    {"永恒回响", "🌌", "终末之后",   0.05,0.02,0.09,  0.95,0.75,1.00},
    {"星之种",   "🌱", "星种时代",   0.04,0.10,0.06,  0.45,0.95,0.55},
    {"光之海",   "🌟", "光海时代",   0.18,0.16,0.02,  1.00,0.90,0.30},
    {"逆熵者",   "🔥", "逆熵时代",   0.14,0.04,0.03,  1.00,0.55,0.25},
    {"万界织者", "🕸️", "织界时代",   0.06,0.03,0.10,  0.80,0.55,1.00},
    {"虚空歌者", "🎶", "虚空时代",   0.02,0.02,0.06,  0.55,0.45,1.00},
    {"因果之律", "⚖️", "因果时代",   0.03,0.04,0.05,  0.60,0.85,0.95},
    {"织时者",   "🕰️", "织时时代",   0.10,0.07,0.02,  1.00,0.85,0.45},
    {"太一",     "☀️", "太一时代",   0.20,0.14,0.02,  1.00,0.95,0.35},
    {"无限",     "✳️", "无限时代",   0.04,0.03,0.06,  0.75,0.70,1.00},
    {"归零者",   "⚪", "归零时代",   0.05,0.05,0.06,  0.95,0.95,1.00},
    {"梦之彼岸", "🌙", "彼岸时代",   0.03,0.04,0.10,  0.45,0.60,1.00},
    {"语源",     "🗣️", "语源时代",   0.06,0.05,0.03,  0.95,0.80,0.55},
    {"原点",     "⭕", "原点时代",   0.02,0.02,0.02,  0.90,0.90,0.90},
    {"超验",     "🔮", "超验时代",   0.07,0.02,0.09,  0.85,0.45,1.00},
    {"无名",     "🕯️", "无名时代",   0.05,0.04,0.04,  0.95,0.80,0.60},
    {"终焉之外", "🌑", "终焉时代",   0.02,0.02,0.03,  0.70,0.60,0.95},
    {"万象之始", "🫧", "万象时代",   0.05,0.03,0.09,  0.80,0.70,1.00},
    {"天穹执笔", "🖋️", "天穹时代",   0.10,0.06,0.03,  1.00,0.78,0.40},
    {"无弦之琴", "🪕", "无弦时代",   0.04,0.09,0.07,  0.60,0.95,0.70},
    {"星骸之主", "💀", "星骸时代",   0.02,0.02,0.04,  0.90,0.90,1.00},
    {"悖论化身", "♻️", "悖论时代",   0.09,0.03,0.10,  0.75,0.40,1.00},
    {"沉寂之息", "🫥", "沉寂时代",   0.03,0.03,0.05,  0.55,0.58,0.65},
    {"时间沙漏", "🏺", "沙漏时代",   0.12,0.09,0.04,  1.00,0.85,0.45},
    {"终末花火", "🎆", "花火时代",   0.16,0.10,0.06,  1.00,0.60,0.35},
    {"一切之书", "📖", "全书时代",   0.08,0.06,0.02,  0.95,0.82,0.45},
    {"无垠之梦", "💭", "无垠时代",   0.04,0.06,0.12,  0.50,0.72,1.00},
    {"起源回声", "🔔", "回声时代",   0.09,0.07,0.03,  1.00,0.88,0.52},
    {"万有归一", "🪷", "归一时代",   0.14,0.10,0.08,  1.00,0.92,0.75},
};
static const NSInteger kStageCount = sizeof(kStages) / sizeof(kStages[0]);

// 进化到第 i 阶段所需能量（i>=1）
// 进化费用的整体倍率（越大越难进化）
static const double kEvolveMult = 3.0;
static const double kEvolveCost[] = {
    0, 100, 1200, 9000, 60000, 350000, 2.2e6, 1.4e7,
    9e7, 6e8, 4e9, 2.8e10, 2e11, 1.5e12, 1.2e13, 1e14,
    8e14, 6e15, 5e16, 4e17, 3e18, 2.5e19, 2e20, 1.6e21,
    1.3e22, 1e23, 8e23, 6.5e24, 5e25, 4e26, 3.2e27, 2.5e28,
    2e29, 1.6e30, 1.3e31, 1e32, 8e32, 6.4e33, 5e34, 4e35,
    3.2e36, 2.6e37, 2e38, 1.6e39, 1.3e40, 1e41, 8e41, 6.4e42,
    5.1e43, 4e44, 3.2e45, 2.5e46, 2e47, 1.6e48, 1.3e49, 1e50,
    8e50, 6.4e51, 5.1e52, 4e53
};

static const char *kLore[] = {
    "第一批自我复制的分子在热泉边缘学会把能量换成秩序，膜与遗传物质同时出现。",
    "细菌学会用化学梯度呼吸，把硫与铁变成能量，地球第一次有了大氧化。",
    "藻类抓住阳光，把海水染成绿，氧气开始堆积成天空。",
    "海绵滤食海水，多细胞第一次有了分工与骨架。",
    "水母用神经网控制漂浮，这是地球上最早的“身体”。",
    "贝类把矿物筑成外壳，进化第一次学会了防御。",
    "小鱼长出脊椎与侧线，第一次主动追逐而非等待。",
    "热带鱼把色彩写进鳞片，珊瑚礁成为生命的城市。",
    "海龟在两栖与海洋之间往返，把卵带上岸。",
    "青蛙用肺与皮肤双重呼吸，第一次真正离开水。",
    "蜥蜴的鳞片锁住水分，生命开始向内陆深处推进。",
    "恐龙以体型统治大陆，食物链第一次出现巨兽层级。",
    "猿猴的手掌能握持工具，大脑开始为操控世界而扩容。",
    "人类学会火与语言，把经验从个体记忆变成文明。",
    "城市从河谷生长，交换与分工让能量利用效率倍增。",
    "星际文明把第一艘方舟送出母星，生命成为跨行星现象。",
    "星系文明改写恒星结构，用戴森云收集整颗太阳。",
    "星系主宰调度引力，让星团按自己的节奏旋转。",
    "量子生命把意识写进叠加态，在观测之前同时存在于所有可能。",
    "时空之灵以时间为身体，一次呼吸横跨亿万年的地层。",
    "维度生命折叠空间，把距离变成可省略的参数。",
    "宇宙意识苏醒，星系的生灭成为它的一次心跳。",
    "观测之眼让宇宙因被看见而坍缩成确定的历史。",
    "终极文明触碰到物理定律的边界，开始修改常数。",
    "概念生命以定义存活，被理解的瞬间才真正诞生。",
    "多元宇宙向所有分支同时扩张，每一个选择都长成一片天。",
    "弦之生命以振动为骨，把十维的余震弹成旋律。",
    "时间尽头之后没有终点，只有另一层开始。",
    "虚无之主在空无中维持着存在的张力。",
    "叙事存在把自身写成故事，读者与主角同时是它。",
    "创世者不再适应宇宙，而是亲手写下宇宙的第一行。",
    "永恒回响是创世之后残留的那一声，仍在所有时间里传播。",
    "星之种把文明压缩成一枚种子，等待下一片真空发芽。",
    "光之海由无数恒星残骸汇成，生命以光子为食。",
    "逆熵者拒绝热寂，用意志把散乱重新排成秩序。",
    "万界织者把不同宇宙的因果编成同一张网。",
    "虚空歌者用引力波歌唱，黑洞成为它的乐器。",
    "因果之律成为可见的实体，每一个结果都拖着一条发光的链。",
    "织时者把过去与未来捻成线，历史成为可编织的材料。",
    "太一是所有分支收束成的那一个点，也是一切重新分岔的地方。",
    "无限不再有边界，扩张本身成为唯一的坐标。",
    "归零者把一切参数还原为初始值，宇宙成为一张干净的白纸。",
    "梦之彼岸是意识与物质交界的那层薄膜。",
    "语源是所有名字诞生之前的那个词，说出它便重写现实。",
    "原点既是开始也是结束，时间在此处失去方向。",
    "超验越过一切可描述之物，只留下无法转述的余温。",
    "无名者不被任何定义捕获，因此无法被消灭。",
    "终焉之外仍有微光，生命在所有结局之后继续。",
    "万象从同一个起点分裂出所有可能，每一个都在第一声心跳里成形。",
    "天穹执笔，把星轨写成文字；宇宙第一次拥有了作者。",
    "无弦之琴不需要振动，歌声直接由共振的可能性产生。",
    "星骸之主收集熄灭的恒星，把它们残余的温度重新点燃。",
    "悖论化身同时存在于两个答案里，因果在它身上绕成一个结。",
    "沉寂之息不发出任何声音，却让所有声音都有了边界。",
    "时间沙漏把每一粒沙都当作一次完整的轮回，反复倾泻。",
    "终末花火燃尽最后一段历史，把结局炸成一场庆典。",
    "一切之书没有页码，翻阅即是发生，合上即是遗忘。",
    "无垠之梦没有醒来的一刻，因为它本身就是清醒的定义。",
    "起源回声沿时间逆向传播，第一个细胞听到了自己的未来。",
    "万有归一：所有形态、所有时代、所有结局，在同一瞬彼此承认。",
};

typedef struct { const char *icon; const char *name; const char *desc; NSInteger cost; } Relic;
static const Relic kRelics[] = {
    {"🌊", "潮汐之心", "全产出 +15%／级", 1},
    {"🦴", "掠食之爪", "点击收益 +20%／级", 1},
    {"👑", "孢子王冠", "孢子增益强度 +30%／级", 2},
    {"🔑", "升维密钥", "飞升获得 DNA +10%／级", 2},
    {"🪨", "起源遗骸", "飞升后每条产线额外 +5 级／级", 3},
    {"🌫", "静默之幕", "时代事件时长 ×0.78／级（最低 0.35）", 2},
};
static const NSInteger kRelicCount = sizeof(kRelics) / sizeof(kRelics[0]);

static NSString *StageName(NSInteger i)  { return [NSString stringWithUTF8String:kStages[i].name]; }
static NSString *StageEmoji(NSInteger i) { return [NSString stringWithUTF8String:kStages[i].emoji]; }
static NSString *StageEra(NSInteger i)   { return [NSString stringWithUTF8String:kStages[i].era]; }
static UIColor *StageBG(NSInteger i) {
    return [UIColor colorWithRed:kStages[i].bgR green:kStages[i].bgG blue:kStages[i].bgB alpha:1];
}
static UIColor *StageAccent(NSInteger i) {
    return [UIColor colorWithRed:kStages[i].acR green:kStages[i].acG blue:kStages[i].acB alpha:1];
}

// ================= 数值体系 =================
static double BaseProd(NSInteger i)  { return 0.08 * pow(5.0, (double)i); }
static double BaseCost(NSInteger i)  { return 18.0 * pow(5.0, (double)i); }
// 单条产线每买一级的价格增长率（越大越难堆数量）
static const double kCostGrowth = 1.18;

// 里程碑门槛：每跨一级该产线产出 ×2，共 20 级（最高 66000 个）
static const NSInteger kMileStones[] = {
    10, 25, 50, 100, 150, 250, 400, 600, 900, 1400,
    2000, 3000, 4500, 7000, 10000, 15000, 22000, 32000, 46000, 66000
};
static const NSInteger kMileCount = sizeof(kMileStones) / sizeof(kMileStones[0]);

static NSInteger MilestoneTier(NSInteger count) {
    NSInteger t = 0;
    for (NSInteger i = 0; i < kMileCount; i++) {
        if (count >= kMileStones[i]) t++;
        else break;
    }
    return t;
}
static double MilestoneMult(NSInteger count) { return pow(2.0, (double)MilestoneTier(count)); }
static NSInteger NextMilestone(NSInteger count) {
    for (NSInteger i = 0; i < kMileCount; i++) {
        if (count < kMileStones[i]) return kMileStones[i];
    }
    return 0;
}
static NSInteger PrevMilestone(NSInteger count) {
    NSInteger p = 0;
    for (NSInteger i = 0; i < kMileCount; i++) {
        if (count >= kMileStones[i]) p = kMileStones[i];
    }
    return p;
}
static double BulkCost(NSInteger i, NSInteger owned, NSInteger k) {
    double c0 = BaseCost(i) * pow(kCostGrowth, (double)owned);
    return c0 * (pow(kCostGrowth, (double)k) - 1.0) / (kCostGrowth - 1.0);
}

// ================= 变异路线 =================
typedef struct {
    const char *icon;
    const char *name;
    const char *desc;
} Mutation;

enum { MutTap = 0, MutProd, MutCrit, MutComboHold, MutCombo, MutSpore, MutCritUp,
       MutSporeRain, MutComboRate, MutEvoWarm, MutCritChain, MutKinds };
static const Mutation kMuts[] = {
    {"👆", "掠食强化", "点击收益 +30%"},
    {"💧", "高效代谢", "自动产出 +20%"},
    {"🎯", "猎手直觉", "点击 15% 概率暴击 3 倍"},
    {"⏳", "节奏掌控", "连击保持时间 +1 秒"},
    {"🌀", "群体共鸣", "连击上限 +1"},
    {"✨", "孢子狂喜", "孢子增益强度 +80%"},
    {"🎇", "连锁暴击", "暴击概率 +10%"},
    {"🌧", "孢子雨",   "点击时 6% 概率额外获得一份孢子收益"},
    {"🎼", "节奏大师", "连击每层加成由 +0.1 提升到 +0.14"},
    {"♨️", "进化余温", "进化后 15 秒内产出 ×1.4"},
    {"🔗", "暴击回响", "暴击时 25% 概率追加一次等额点击收益"},
};

// 基因组强化条目
typedef struct { const char *icon; const char *name; const char *desc; } GeneDef;
static const GeneDef kGenes[] = {
    {"⏳", "离线收益",   "离开时返还产出（每级 +10%，最高 100%，上限每级 +1 小时）"},
    {"🧬", "基因强化",   "全产出 +50%／级"},
    {"👆", "点击强化",   "点击收益 +30%／级"},
    {"✨", "孢子亲和",   "孢子增益强度 +40%／级"},
    {"🤖", "自动触手",   "每秒自动点击 1 次／级（不计连击）"},
    {"🕊", "飞升红利",   "飞升获得的 DNA +20%／级"},
    {"🌱", "起始遗泽",   "飞升后每条产线自带等级（每 2 级 +1，最高 60）"},
    {"🌠", "孢子之频",   "孢子出现间隔 -10%／级"},
    {"⚔️", "试炼锋芒",   "对守关者伤害 +35%／级（点破试炼更轻松）"},
};
static const NSInteger kGeneCount = sizeof(kGenes) / sizeof(kGenes[0]);


// 单条基因等级上限，避免 DNA 无限灌入导致数值爆炸
static const NSInteger kGeneMaxLevel = 999999;   // 强化不再有等级上限

// 与阶段主题色高对比的飘字颜色（备用，当前配色改为按来源固定）
static UIColor *ContrastColorForStage(NSInteger i) __attribute__((unused));
static UIColor *ContrastColorForStage(NSInteger i) {
    UIColor *accent = StageAccent(i);
    CGFloat h = 0.2, s = 0.8, b = 1, a = 1;
    [accent getHue:&h saturation:&s brightness:&b alpha:&a];
    CGFloat nh = fmod(h + 0.5, 1.0);
    return [UIColor colorWithHue:nh saturation:0.72 brightness:1.0 alpha:1.0];
}
static UIFont *FancyFont(CGFloat size) __attribute__((unused));
static UIFont *FancyFont(CGFloat size) {
    UIFont *f = [UIFont fontWithName:@"AvenirNext-BoldItalic" size:size];
    if (!f) f = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:size];
    if (!f) f = [UIFont boldSystemFontOfSize:size];
    return f;
}

static NSString *FmtNum(double v) {
    if (v < 0) v = 0;
    if (v < 1000) {
        double rounded = round(v);
        if (fabs(v - rounded) < 0.05) {
            return [NSString stringWithFormat:@"%lld", (long long)rounded];
        }
        NSString *s = (v < 10) ? [NSString stringWithFormat:@"%.2f", v]
                               : [NSString stringWithFormat:@"%.1f", v];
        while (s.length > 2 && [s hasSuffix:@"0"] && [s rangeOfString:@"."].location != NSNotFound) {
            s = [s substringToIndex:s.length - 1];
        }
        if ([s hasSuffix:@"."]) s = [s stringByAppendingString:@"0"];
        if ([s doubleValue] == 0 && v > 0) s = [NSString stringWithFormat:@"%.3f", v];
        return s;
    }
    const char *suffix[] = {"K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No",
                            "Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod"};
    double unit = 1e3;
    int idx = 0;
    while (idx < 19 && v >= unit * 1000) { unit *= 1000; idx++; }
    if (idx == 19 && v >= unit * 1000) return [NSString stringWithFormat:@"%.2e", v];
    double s = v / unit;
    NSString *num;
    if (s < 10)       num = [NSString stringWithFormat:@"%.2f", s];
    else if (s < 100) num = [NSString stringWithFormat:@"%.1f", s];
    else              num = [NSString stringWithFormat:@"%.0f", s];
    return [num stringByAppendingFormat:@"%s", suffix[idx]];
}

// 大于等于 1000 的整数统一缩写（1.09M / 95.6B）
static NSString *FmtInt(NSInteger v) {
    if (v < 1000) return [NSString stringWithFormat:@"%ld", (long)v];
    return FmtNum((double)v);
}

// ================= 生产线行（整行点击购买）=================
// ================= 滚动数字 =================
@interface RollColView : UIView
@property (nonatomic, strong) UILabel *curLabel;
@property (nonatomic, strong) UILabel *nextLabel;
@property (nonatomic) BOOL rolling;
@property (nonatomic, copy) NSString *pendingChar;
@property (nonatomic) CGFloat cellW;
@property (nonatomic) CGFloat cellH;
- (instancetype)initWithWidth:(CGFloat)w height:(CGFloat)h font:(UIFont *)font color:(UIColor *)color;
- (void)setChar:(NSString *)ch;
@end

static NSArray<NSString *> *SplitComposedChars(NSString *s) {
    if (s.length == 0) return @[];
    NSMutableArray<NSString *> *arr = [NSMutableArray array];
    [s enumerateSubstringsInRange:NSMakeRange(0, s.length)
                           options:NSStringEnumerationByComposedCharacterSequences
                        usingBlock:^(NSString *sub, NSRange r1, NSRange r2, BOOL *stop) {
        if (sub) [arr addObject:sub];
    }];
    return arr;
}

@implementation RollColView
- (instancetype)initWithWidth:(CGFloat)w height:(CGFloat)h font:(UIFont *)font color:(UIColor *)color {
    self = [super initWithFrame:CGRectMake(0, 0, w, h)];
    if (self) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        _cellW = w;
        _cellH = h;
        _curLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        _nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, h, w, h)];
        for (UILabel *l in @[_curLabel, _nextLabel]) {
            l.textAlignment = NSTextAlignmentCenter;
            l.font = font;
            l.textColor = color;
            l.adjustsFontSizeToFitWidth = NO;
            [self addSubview:l];
        }
        _nextLabel.hidden = YES;
    }
    return self;
}
- (void)setChar:(NSString *)ch {
    _curLabel.text = ch;
    _nextLabel.hidden = YES;
    _curLabel.frame = CGRectMake(0, 0, _cellW, _cellH);
}
@end

@interface RollNumberView : UIView
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *glowColor;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, strong) UILabel *glowLabel;
@property (nonatomic, strong) UIView *inner;
@property (nonatomic, strong) NSMutableArray *cols;
@property (nonatomic) CGFloat colW;
@property (nonatomic) CGFloat cellH;
- (instancetype)initWithFrame:(CGRect)frame font:(UIFont *)font;
- (void)setString:(NSString *)string animated:(BOOL)animated;
@end

@implementation RollNumberView
- (instancetype)initWithFrame:(CGRect)frame font:(UIFont *)font {
    self = [super initWithFrame:frame];
    if (self) {
        _font = font;
        _cols = [NSMutableArray array];
        _string = @"";
        _textColor = [UIColor whiteColor];
        _colW = ceil([@"0" sizeWithAttributes:@{NSFontAttributeName: font}].width) + 1.0;
        _cellH = CGRectGetHeight(frame);
        self.clipsToBounds = NO;

        _inner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), _cellH)];
        _inner.clipsToBounds = NO;
        [self addSubview:_inner];

        _glowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), _cellH)];
        _glowLabel.font = font;
        _glowLabel.textColor = [UIColor colorWithWhite:1 alpha:0.26];
        _glowLabel.userInteractionEnabled = NO;
        _glowLabel.layer.shadowOffset = CGSizeZero;
        _glowLabel.layer.shadowRadius = 14;
        _glowLabel.layer.shadowOpacity = 0.55;
        [_inner addSubview:_glowLabel];
        [self setString:@"0" animated:NO];
    }
    return self;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for (RollColView *c in self.cols) {
        c.curLabel.textColor = textColor;
        c.nextLabel.textColor = textColor;
    }
}

- (void)setGlowColor:(UIColor *)glowColor {
    _glowColor = glowColor;
    self.glowLabel.layer.shadowColor = glowColor.CGColor;
}

- (void)layoutCols {
    CGFloat x = 0;
    for (RollColView *c in self.cols) {
        c.frame = CGRectMake(x, 0, self.colW, self.cellH);
        x += self.colW;
    }
    CGFloat avail = CGRectGetWidth(self.bounds);
    CGFloat scale = (x > avail && x > 0) ? avail / x : 1.0;
    self.inner.bounds = CGRectMake(0, 0, MAX(x, 1), self.cellH);
    self.inner.transform = CGAffineTransformMakeScale(scale, scale);
    self.inner.center = CGPointMake(x * scale / 2.0, self.cellH / 2.0);
    self.glowLabel.frame = CGRectMake(0, 0, MAX(x, 1), self.cellH);
}

- (void)setString:(NSString *)string animated:(BOOL)animated {
    if (string == nil) string = @"";
    if ([string isEqualToString:_string]) return;
    NSArray<NSString *> *chars = SplitComposedChars(string);
    BOOL lengthChanged = (chars.count != self.cols.count);
    _string = [string copy];
    self.glowLabel.text = string;

    if (lengthChanged || self.cols.count == 0) {
        for (UIView *v in self.cols) [v removeFromSuperview];
        [self.cols removeAllObjects];
        for (NSUInteger i = 0; i < chars.count; i++) {
            NSString *ch = chars[i];
            RollColView *c = [[RollColView alloc] initWithWidth:self.colW height:self.cellH
                                                           font:self.font color:self.textColor];
            [c setChar:ch];
            [self.inner addSubview:c];
            [self.cols addObject:c];
        }
        [self layoutCols];
        return;
    }

    for (NSUInteger i = 0; i < chars.count; i++) {
        NSString *ch = chars[i];
        RollColView *c = self.cols[i];
        if ([c.curLabel.text isEqualToString:ch] && c.pendingChar == nil) continue;
        c.pendingChar = ch;
        [self rollCol:c];
    }
}

- (void)rollCol:(RollColView *)col {
    if (col.rolling || col.pendingChar == nil) return;
    NSString *ch = col.pendingChar;
    col.pendingChar = nil;
    if ([col.curLabel.text isEqualToString:ch]) return;

    col.rolling = YES;
    col.nextLabel.text = ch;
    col.nextLabel.hidden = NO;
    col.nextLabel.frame = CGRectMake(0, col.cellH, col.cellW, col.cellH);
    col.curLabel.frame = CGRectMake(0, 0, col.cellW, col.cellH);

    [UIView animateWithDuration:0.11 delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        col.curLabel.frame = CGRectMake(0, -col.cellH, col.cellW, col.cellH);
        col.nextLabel.frame = CGRectMake(0, 0, col.cellW, col.cellH);
    } completion:^(BOOL finished) {
        col.curLabel.text = ch;
        col.curLabel.frame = CGRectMake(0, 0, col.cellW, col.cellH);
        col.nextLabel.hidden = YES;
        col.nextLabel.frame = CGRectMake(0, col.cellH, col.cellW, col.cellH);
        col.rolling = NO;
        if (col.pendingChar != nil) [self rollCol:col];
    }];
}
@end

@interface GenRow : UIView
@property (nonatomic, strong) UIView *iconBox;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, strong) UILabel *milestoneLabel;
@property (nonatomic, strong) UILabel *costLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *bestLabel;
@property (nonatomic, strong) UIView *barTrack;
@property (nonatomic, strong) UIView *barFill;
@property (nonatomic, strong) UIView *cardFill;   // 整卡进度填充（攒钱进度）
@property (nonatomic) NSInteger stageIndex;
@property (nonatomic, copy) void (^onTapBlock)(NSInteger stageIndex);
- (instancetype)initWithFrame:(CGRect)frame stage:(NSInteger)i;
@end


// ================= 逐位滚动 UILabel =================
@interface RollLabel : UILabel
@property (nonatomic, copy) NSString *valueText;
@property (nonatomic, strong) NSMutableArray *cols;
@property (nonatomic) BOOL animatedFlag;
- (void)setValueText:(NSString *)text animated:(BOOL)animated;
@end

@implementation RollLabel
// 只保留左上角能量数字的逐位滚动；其余位置的 RollLabel 退化为普通 UILabel
- (void)setValueText:(NSString *)text animated:(BOOL)animated {
    [super setText:text];
}
- (void)setText:(NSString *)text {
    [super setText:text];
}
@end

@implementation GenRow
- (instancetype)initWithFrame:(CGRect)frame stage:(NSInteger)i {
    self = [super initWithFrame:frame];
    if (self) {
        _stageIndex = i;
        CGFloat w = frame.size.width;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
        self.layer.cornerRadius = 16;
        self.clipsToBounds = YES;

        // 整卡进度填充：从左向右铺满整张卡片，直观显示距离可购买还差多少
        _cardFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        _cardFill.backgroundColor = [UIColor colorWithWhite:1 alpha:0.010];
        _cardFill.userInteractionEnabled = NO;
        [self addSubview:_cardFill];

        _iconBox = [[UIView alloc] initWithFrame:CGRectMake(10, 14, 44, 44)];
        _iconBox.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
        _iconBox.layer.cornerRadius = 11;
        [self addSubview:_iconBox];

        _iconLabel = [[UILabel alloc] initWithFrame:_iconBox.bounds];
        _iconLabel.font = [UIFont systemFontOfSize:26];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.text = StageEmoji(i);
        [_iconBox addSubview:_iconLabel];

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 9, w - 190, 22)];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.text = StageName(i);
        [self addSubview:_nameLabel];

        _subLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 32, w - 196, 14)];
        _subLabel.font = [UIFont systemFontOfSize:11];
        _subLabel.textColor = [UIColor colorWithWhite:1 alpha:0.78];
        [self addSubview:_subLabel];

        _milestoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 47, w - 196, 13)];
        _milestoneLabel.font = [UIFont systemFontOfSize:10];
        _milestoneLabel.textColor = [UIColor colorWithWhite:1 alpha:0.38];
        [self addSubview:_milestoneLabel];

        _costLabel = [[UILabel alloc] initWithFrame:CGRectMake(w - 186, 11, 108, 18)];
        _costLabel.font = [UIFont boldSystemFontOfSize:12];
        _costLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_costLabel];

        _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(w - 186, 30, 108, 14)];
        _hintLabel.font = [UIFont systemFontOfSize:10];
        _hintLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_hintLabel];

        _bestLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 12, 44, 14)];
        _bestLabel.font = [UIFont boldSystemFontOfSize:10.5];
        _bestLabel.textColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.35 alpha:1];
        _bestLabel.textAlignment = NSTextAlignmentRight;
        _bestLabel.text = @"★ 最优";
        _bestLabel.hidden = YES;
        [self addSubview:_bestLabel];

        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(w - 74, 9, 60, 24)];
        _countLabel.font = [UIFont monospacedDigitSystemFontOfSize:19 weight:UIFontWeightBold];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_countLabel];

        _barTrack = [[UIView alloc] initWithFrame:CGRectMake(w - 74, 40, 60, 3)];
        _barTrack.backgroundColor = [UIColor colorWithWhite:1 alpha:0.14];
        _barTrack.layer.cornerRadius = 1.5;
        _barTrack.clipsToBounds = YES;
        [self addSubview:_barTrack];

        _barFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
        _barFill.backgroundColor = [UIColor colorWithRed:0.72 green:0.45 blue:1 alpha:1];
        [_barTrack addSubview:_barFill];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rowTapped)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)rowTapped {
    if (self.onTapBlock) self.onTapBlock(self.stageIndex);
}
@end

// ================= 多点触控点击区域 =================
@interface TapZoneView : UIView
@property (nonatomic, copy) void (^onTouchBlock)(CGPoint pointInSelf);
@end

@implementation TapZoneView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.multipleTouchEnabled = YES;
        self.exclusiveTouch = NO;
    }
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        CGPoint p = [t locationInView:self];
        if (self.onTouchBlock) self.onTouchBlock(p);
    }
}
@end

// ================= 主控制器 =================
@interface GameViewController () {
    NSInteger _counts[64];      // 各生产线数量（形态上限 48）
    NSInteger _muts[16];        // 本轮变异次数
    NSInteger _relicLv[8];      // 遗物等级（0 = 未解锁）
    BOOL _achDone[16];          // 成就是否已达成
    BOOL _bossDone[64];         // 各守关者是否通过
    NSInteger _bossFails[64];   // 本次轮回各守关者的失败次数（满 2 次封锁，须飞升重开）
    BOOL _bossDoneRound[64];    // 本次轮回是否已通过（飞升清零，保证每轮都要闯关）
}
// 运行状态
@property (nonatomic) double energy;
@property (nonatomic) double runEarned;
@property (nonatomic) NSInteger stage;
// 永久状态
@property (nonatomic) NSInteger dna;
@property (nonatomic) NSInteger ascensions;
@property (nonatomic) BOOL offlineUnlocked;
@property (nonatomic) NSInteger geneLevel;
// 临时状态
@property (nonatomic) double combo;
@property (nonatomic) NSTimeInterval lastTapTime;



@property (nonatomic) NSInteger buyQtyMode;      // 0:1 1:10 2:100 3:最大
@property (nonatomic) BOOL sporeActive;
@property (nonatomic) BOOL mutationSheetOpen;
@property (nonatomic, strong) NSArray *mutationCandidates;   // 本轮 3 个候选变异（供 AI 挑选）

// UI
@property (nonatomic, strong) CAGradientLayer *bgLayer;
@property (nonatomic, strong) RollNumberView *energyRoller;
@property (nonatomic, strong) UIImageView *artBackdrop;
@property (nonatomic, strong) AVAudioPlayer *musicA;
@property (nonatomic, strong) AVAudioPlayer *musicB;
@property (nonatomic) NSInteger musicEra;
@property (nonatomic) BOOL musicOn;
@property (nonatomic) NSInteger maxStage;      // 历史最高形态
@property (nonatomic) NSInteger relicPoints;   // 遗物点
@property (nonatomic) NSInteger totalTaps;     // 累计点击
@property (nonatomic) NSInteger eventKind;     // 0 无 1 陨石 2 爆发 3 超新星 4 熵坍缩
@property (nonatomic, strong) UIView *eventBanner;
@property (nonatomic, strong) UILabel *eventBannerIcon, *eventBannerTitle, *eventBannerSub, *eventBannerTime;
@property (nonatomic, strong) UIView *eventBannerFill;
@property (nonatomic) BOOL eventBannerVisible;
@property (nonatomic) NSTimeInterval eventBannerHideAt, eventBannerShownAt;
@property (nonatomic) NSInteger eventFXTick;
@property (nonatomic, strong) UIButton *eventCleanseBtn;
@property (nonatomic) double cleanseCost;
@property (nonatomic) NSTimeInterval eventEnd;
@property (nonatomic) NSTimeInterval nextEventAt;
@property (nonatomic, strong) UIView *codexPage, *relicPage;
@property (nonatomic, strong) NSMutableArray<UILabel *> *codexNameLabels, *codexLoreLabels, *codexStatusLabels;
@property (nonatomic, strong) NSMutableArray *codexCards;
@property (nonatomic, strong) NSMutableArray<UILabel *> *codexIconLabels, *codexEraLabels;
@property (nonatomic, strong) NSMutableArray<UIButton *> *relicBtns;
@property (nonatomic, strong) UILabel *relicPointLabel, *achTitleLabel;
@property (nonatomic, strong) NSMutableArray<UILabel *> *achLabels;
@property (nonatomic, strong) UIView *bossOverlay, *bossFill;
@property (nonatomic, strong) UILabel *bossHPLabel, *bossTimeLabel, *bossNameLabel, *bossEmojiLabel;
@property (nonatomic) double bossHP, bossMaxHP;
@property (nonatomic) NSTimeInterval bossEnd;
@property (nonatomic) NSInteger bossTarget;
@property (nonatomic, strong) NSTimer *bossTimer;
@property (weak, nonatomic) UIButton *musicBtn;
@property (weak, nonatomic) UIButton *aiBtn;          // 🤖 AI 托管开关
@property (nonatomic) BOOL aiOn;                     // 托管是否开启
@property (nonatomic, strong) NSTimer *aiTimer;
@property (nonatomic) NSTimeInterval aiNextEvolveAt; // 托管下次允许进化的时间
@property (nonatomic, strong) UIView *artScrim;
@property (nonatomic) NSInteger artShown;
@property (nonatomic, strong) RollLabel *dnaRoll;
@property (nonatomic, strong) RollLabel *evolveRoll;
@property (nonatomic, strong) RollLabel *ascendRoll;


@property (nonatomic, strong) UILabel *autoLabel;
@property (nonatomic, strong) UILabel *sporeBuffPill;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UIButton *dnaBtn;
@property (nonatomic, strong) UILabel *creatureNameLabel;
@property (nonatomic, strong) UILabel *eraLabel;
@property (nonatomic, strong) UIView *creatureArea;
@property (nonatomic, strong) UILabel *autoProdFeed;
@property (nonatomic, strong) UILabel *autoTapFeed;
@property (nonatomic, strong) AVAudioEngine *sfxEngine;
@property (nonatomic, strong) AVAudioPlayerNode *sfxNode;
@property (nonatomic, strong) NSMutableDictionary *sfxBuffers;
@property (nonatomic) BOOL sfxReady;
@property (nonatomic) NSTimeInterval lastBestAt;
@property (nonatomic) NSTimeInterval evoWarmUntil;
@property (nonatomic) BOOL ascendGlowOn;
@property (nonatomic, strong) CADisplayLink *energyLink;
@property (nonatomic) double shownEnergy;
@property (nonatomic) CGFloat energyPop;
@property (nonatomic, strong) CAShapeLayer *ringBg;
@property (nonatomic, strong) CAShapeLayer *ringFill;
@property (nonatomic, strong) UILabel *creatureLabel;
@property (nonatomic, strong) UILabel *comboLabel;
@property (nonatomic) double secAccum;


@property (nonatomic, strong) UIButton *evolveBtn;
@property (nonatomic, strong) UILabel *ascLabel;
@property (nonatomic, strong) UILabel *ascPctLabel;
@property (nonatomic, strong) UIView *ascTrack;
@property (nonatomic, strong) UIView *ascFill;
@property (nonatomic, strong) UIButton *ascendBtn;
@property (nonatomic, strong) NSMutableArray<UIButton *> *qtyBtns;
@property (nonatomic, strong) UIScrollView *listScroll;
@property (nonatomic, strong) NSMutableArray<GenRow *> *rows;
@property (nonatomic, strong) UIView *tabBar;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *tabIcons;
@property (nonatomic, strong) NSMutableArray<UILabel *> *tabLabels;
@property (nonatomic) NSInteger currentTab;
@property (nonatomic, strong) UIView *genePage, *mutPage, *recordPage;
@property (nonatomic, strong) UILabel *geneDnaLabel;
@property (nonatomic, strong) NSMutableArray<UIButton *> *geneBuyBtns;
@property (nonatomic, strong) NSMutableArray<UILabel *> *geneNameLabels;
@property (nonatomic, strong) NSMutableArray<RollLabel *> *genePriceRolls;
@property (nonatomic, strong) NSMutableArray<RollLabel *> *geneSubRolls;
@property (nonatomic) NSInteger geneTapLevel, geneSporeLevel, geneAutoLevel, geneOfflineLevel;
@property (nonatomic) NSInteger geneAscendLevel, geneStartLevel, geneSporeRateLevel, geneBossLevel;
@property (nonatomic) NSInteger autoDiff;       // 自适应难度（飞升时按本轮进化速度固化）
@property (nonatomic) NSInteger fastEvoCount;   // 本轮"进化过快"次数
@property (nonatomic) NSInteger bossRushCount;    // 本轮"守关者被秒破"的累积惩罚（越高越难）
@property (nonatomic) NSTimeInterval lastEvolveAt;
@property (nonatomic) NSInteger geneQtyMode;      // 0=1级 1=10级 2=最大
@property (nonatomic, strong) NSMutableArray<UIButton *> *geneQtyBtns;
@property (nonatomic, strong) NSMutableArray<UILabel *> *mutCountLabels;
@property (nonatomic, strong) NSMutableArray<UILabel *> *recordValueLabels;
@property (nonatomic) double totalEarned;
@property (nonatomic, strong) UIButton *sporeBtn;
@property (nonatomic) NSTimeInterval sporeBoostEnd;
@property (nonatomic) double sporeBoostMult;
@property (nonatomic, strong) UIView *mutationCardView;
@property (nonatomic, strong) UIView *mutationDimView;
@property (nonatomic, strong) NSMutableArray<UIImpactFeedbackGenerator *> *haptics;
@property (nonatomic) NSInteger hapticIdx;
@property (nonatomic, strong) CAGradientLayer *vignette;
@property (nonatomic, strong) CAGradientLayer *auroraA;
@property (nonatomic, strong) CAGradientLayer *auroraB;
@property (nonatomic, strong) CAShapeLayer *aura1;
@property (nonatomic, strong) CAShapeLayer *aura2;
@property (nonatomic, strong) CAEmitterLayer *ambientEmitter;
@property (nonatomic, strong) UIImage *sparkDot;
@property (nonatomic, strong) UIView *flashView;
@property (nonatomic, strong) CHHapticEngine *hapticEngine;
@property (nonatomic, strong) NSMutableArray *tapPool;
@property (nonatomic, strong) NSMutableArray *critPool;
@property (nonatomic) NSInteger tapIdx, critIdx;
@property (nonatomic) BOOL hapticReady;
@property (nonatomic) CFTimeInterval lastHapticAt;
@property (nonatomic) CFTimeInterval lastRebuildAt;
@property (nonatomic, strong) NSTimer *tickTimer;
@end

// ===== 多指同时攻击：单个 UITapGestureRecognizer 只承载 1 指，2 指以上同时落下会整体判定失败，
// 这里改成 touchesBegan 逐指结算，每根手指按下都独立算一次攻击 =====
@protocol BossHitTarget <NSObject>
- (void)bossHitAtWindowPoint:(CGPoint)p;
@end

@interface BossTapView : UIView
@property (nonatomic, weak) id<BossHitTarget> bossOwner;
@end

@implementation BossTapView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    id<BossHitTarget> o = self.bossOwner;
    if (!o) return;
    for (UITouch *t in touches) {
        [o bossHitAtWindowPoint:[t locationInView:nil]];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}
@end

// ===== 飞升确认弹窗：自定义暗色卡片（替代系统白底 UIAlertController） =====
@interface AscendDialogView : UIView
@property (nonatomic, strong) UIView *card;
@property (nonatomic, copy) void (^onConfirm)(void);
+ (void)presentInView:(UIView *)host gain:(NSInteger)gain prod:(double)np cost:(double)nc
                   evo:(double)ne fast:(NSInteger)fast autoP:(NSInteger)ap
               confirm:(void (^)(void))confirm;
@end

@implementation AscendDialogView

+ (void)presentInView:(UIView *)host gain:(NSInteger)gain prod:(double)np cost:(double)nc
                  evo:(double)ne fast:(NSInteger)fast autoP:(NSInteger)ap
              confirm:(void (^)(void))confirm {
    AscendDialogView *d = [[AscendDialogView alloc] initWithFrame:host.bounds];
    d.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    d.onConfirm = confirm;
    [d buildGain:gain prod:np cost:nc evo:ne fast:fast autoP:ap];
    [host addSubview:d];
    d.alpha = 0.0;
    d.card.transform = CGAffineTransformMakeScale(0.86, 0.86);
    [UIView animateWithDuration:0.32 delay:0 usingSpringWithDamping:0.74 initialSpringVelocity:0.4
                         options:UIViewAnimationOptionAllowUserInteraction animations:^{
        d.alpha = 1.0;
        d.card.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (UILabel *)putLabel:(NSString *)text font:(UIFont *)font color:(UIColor *)color
                 frame:(CGRect)fr align:(NSTextAlignment)al lines:(NSInteger)ln to:(UIView *)pv {
    UILabel *l = [[UILabel alloc] initWithFrame:fr];
    l.text = text;
    l.font = font;
    l.textColor = color;
    l.textAlignment = al;
    l.numberOfLines = ln;
    if (ln == 1) l.adjustsFontSizeToFitWidth = YES;
    [pv addSubview:l];
    return l;
}

- (void)onBackdropTap:(UITapGestureRecognizer *)g {
    CGPoint p = [g locationInView:self];
    if (CGRectContainsPoint(self.card.frame, p)) return;
    [self close];
}

- (void)close {
    [UIView animateWithDuration:0.18 animations:^{
        self.alpha = 0.0;
        self.card.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL f) {
        [self removeFromSuperview];
    }];
}

- (void)onCancelTap { [self close]; }

- (void)onConfirmTap {
    void (^cb)(void) = self.onConfirm;
    [self close];
    if (cb) cb();
}

- (void)buildGain:(NSInteger)gain prod:(double)np cost:(double)nc evo:(double)ne
              fast:(NSInteger)fast autoP:(NSInteger)ap {
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.58];
    UITapGestureRecognizer *tk = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackdropTap:)];
    tk.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tk];

    CGFloat W = self.bounds.size.width, H = self.bounds.size.height;
    CGFloat cw = MIN(W - 44.0, 376.0);
    CGFloat pad = 20.0;
    CGFloat inW = cw - pad * 2.0;

    UIView *card = [[UIView alloc] initWithFrame:CGRectMake((W - cw) / 2.0, 0, cw, 400)];
    card.layer.cornerRadius = 26.0;
    card.backgroundColor = [UIColor colorWithRed:0.085 green:0.055 blue:0.135 alpha:1];
    card.layer.borderWidth = 1.0 / UIScreen.mainScreen.scale;
    card.layer.borderColor = [UIColor colorWithRed:0.62 green:0.42 blue:1.0 alpha:0.55].CGColor;
    card.clipsToBounds = YES;
    self.card = card;

    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.colors = @[(id)[UIColor colorWithRed:0.19 green:0.10 blue:0.30 alpha:1].CGColor,
                    (id)[UIColor colorWithRed:0.07 green:0.045 blue:0.11 alpha:1].CGColor];
    grad.startPoint = CGPointMake(0.15, 0.0);
    grad.endPoint = CGPointMake(0.85, 1.0);
    grad.frame = card.bounds;
    [card.layer insertSublayer:grad atIndex:0];

    CGFloat y = 18.0;
    [self putLabel:@"🕊" font:[UIFont systemFontOfSize:32 weight:UIFontWeightRegular]
             color:[UIColor whiteColor] frame:CGRectMake(0, y, cw, 42)
             align:NSTextAlignmentCenter lines:1 to:card];
    y += 42.0;
    [self putLabel:@"飞升" font:[UIFont systemFontOfSize:23 weight:UIFontWeightBold]
             color:[UIColor colorWithRed:0.90 green:0.82 blue:1.0 alpha:1] frame:CGRectMake(0, y, cw, 30)
             align:NSTextAlignmentCenter lines:1 to:card];
    y += 30.0;
    [self putLabel:@"本轮生命将归于起源" font:[UIFont systemFontOfSize:12.5]
             color:[UIColor colorWithWhite:1 alpha:0.5] frame:CGRectMake(0, y, cw, 18)
             align:NSTextAlignmentCenter lines:1 to:card];
    y += 24.0;

    UIView *gainBox = [[UIView alloc] initWithFrame:CGRectMake(pad, y, inW, 74)];
    gainBox.backgroundColor = [UIColor colorWithWhite:1 alpha:0.07];
    gainBox.layer.cornerRadius = 16.0;
    [card addSubview:gainBox];

    CGFloat halfW = inW / 2.0;
    [self putLabel:@"🧬 DNA" font:[UIFont systemFontOfSize:10.5 weight:UIFontWeightSemibold]
             color:[UIColor colorWithWhite:1 alpha:0.5] frame:CGRectMake(0, 12, halfW, 16)
             align:NSTextAlignmentCenter lines:1 to:gainBox];
    [self putLabel:[NSString stringWithFormat:@"+%@", FmtInt(gain)]
             font:[UIFont monospacedDigitSystemFontOfSize:19 weight:UIFontWeightBold]
             color:[UIColor colorWithRed:0.85 green:0.60 blue:1.0 alpha:1] frame:CGRectMake(0, 28, halfW, 24)
             align:NSTextAlignmentCenter lines:1 to:gainBox];
    [self putLabel:@"永久保留" font:[UIFont systemFontOfSize:10]
             color:[UIColor colorWithWhite:1 alpha:0.35] frame:CGRectMake(0, 50, halfW, 14)
             align:NSTextAlignmentCenter lines:1 to:gainBox];

    [self putLabel:@"🔮 遗物点" font:[UIFont systemFontOfSize:10.5 weight:UIFontWeightSemibold]
             color:[UIColor colorWithWhite:1 alpha:0.5] frame:CGRectMake(halfW, 12, halfW, 16)
             align:NSTextAlignmentCenter lines:1 to:gainBox];
    [self putLabel:@"+2" font:[UIFont monospacedDigitSystemFontOfSize:19 weight:UIFontWeightBold]
             color:[UIColor colorWithRed:1.0 green:0.80 blue:0.45 alpha:1] frame:CGRectMake(halfW, 28, halfW, 24)
             align:NSTextAlignmentCenter lines:1 to:gainBox];
    [self putLabel:@"可强化遗物" font:[UIFont systemFontOfSize:10]
             color:[UIColor colorWithWhite:1 alpha:0.35] frame:CGRectMake(halfW, 50, halfW, 14)
             align:NSTextAlignmentCenter lines:1 to:gainBox];

    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(halfW - 0.5, y + 14, 1, 46)];
    sep.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
    [card addSubview:sep];

    y += 74.0 + 10.0;
    [self putLabel:@"能量 · 物种 · 变异路线将重置" font:[UIFont systemFontOfSize:11]
             color:[UIColor colorWithWhite:1 alpha:0.40] frame:CGRectMake(0, y, cw, 16)
             align:NSTextAlignmentCenter lines:1 to:card];
    y += 26.0;

    [self putLabel:@"⚠️ 下一轮更难" font:[UIFont systemFontOfSize:13 weight:UIFontWeightBold]
             color:[UIColor colorWithRed:1.0 green:0.72 blue:0.35 alpha:1]
             frame:CGRectMake(pad, y, inW, 18) align:NSTextAlignmentLeft lines:1 to:card];
    y += 21.0;
    [self putLabel:[NSString stringWithFormat:@"产出 ×%.2f · 成本 ×%.2f · 进化 ×%.2f", np, nc, ne]
             font:[UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightMedium]
             color:[UIColor colorWithWhite:1 alpha:0.72] frame:CGRectMake(pad, y, inW, 17)
             align:NSTextAlignmentLeft lines:1 to:card];
    y += 26.0;

    [self putLabel:[NSString stringWithFormat:@"🎚 自适应难度 · 本轮过快 %ld 次", (long)fast]
             font:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]
             color:[UIColor colorWithWhite:1 alpha:fast > 0 ? 0.78 : 0.45]
             frame:CGRectMake(pad, y, inW, 17) align:NSTextAlignmentLeft lines:1 to:card];
    y += 19.0;
    [self putLabel:[NSString stringWithFormat:@"产出 ×%.2f  成本 ×%.2f  进化 ×%.2f\n门槛 ×%.2f  守关 ×%.2f  DNA ×%.2f",
                   pow(0.92, (double)(ap * 3)), pow(1.08, (double)(ap * 3)), pow(1.14, (double)(ap * 3)),
                   pow(1.15, (double)(ap * 3)), pow(1.35, (double)(ap * 3)), pow(0.85, (double)(ap * 3))]
             font:[UIFont monospacedDigitSystemFontOfSize:11.5 weight:UIFontWeightRegular]
             color:[UIColor colorWithWhite:1 alpha:0.55] frame:CGRectMake(pad, y, inW, 34)
             align:NSTextAlignmentLeft lines:2 to:card];

    CGFloat btnY = 336.0, btnH = 50.0;
    CGFloat bw = (inW - 12.0) / 2.0;

    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel.frame = CGRectMake(pad, btnY, bw, btnH);
    cancel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    cancel.layer.cornerRadius = 14.0;
    cancel.layer.borderWidth = 1.0 / UIScreen.mainScreen.scale;
    cancel.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.16].CGColor;
    [cancel setTitle:@"再想想" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithWhite:1 alpha:0.72] forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:15.5 weight:UIFontWeightMedium];
    [cancel addTarget:self action:@selector(onCancelTap) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:cancel];

    UIButton *ok = [UIButton buttonWithType:UIButtonTypeCustom];
    ok.frame = CGRectMake(pad + bw + 12.0, btnY, bw, btnH);
    ok.layer.cornerRadius = 14.0;
    ok.clipsToBounds = YES;
    CAGradientLayer *bg = [CAGradientLayer layer];
    bg.frame = ok.bounds;
    bg.colors = @[(id)[UIColor colorWithRed:0.52 green:0.30 blue:0.98 alpha:1].CGColor,
                  (id)[UIColor colorWithRed:0.86 green:0.36 blue:0.72 alpha:1].CGColor];
    bg.startPoint = CGPointMake(0.0, 0.0);
    bg.endPoint = CGPointMake(1.0, 1.0);
    [ok.layer insertSublayer:bg atIndex:0];
    [ok setTitle:@"🕊 飞升！" forState:UIControlStateNormal];
    [ok setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    ok.titleLabel.font = [UIFont systemFontOfSize:16.5 weight:UIFontWeightBold];
    [ok addTarget:self action:@selector(onConfirmTap) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:ok];

    CGFloat cardH = btnY + btnH + 20.0;
    card.frame = CGRectMake((W - cw) / 2.0, (H - cardH) / 2.0, cw, cardH);
    grad.frame = card.bounds;

    [self addSubview:card];
}
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.qtyBtns = [NSMutableArray array];
    self.rows = [NSMutableArray array];
    self.tabIcons = [NSMutableArray array];
    self.tabLabels = [NSMutableArray array];
    self.mutCountLabels = [NSMutableArray array];
    self.geneBuyBtns = [NSMutableArray array];
    self.geneQtyBtns = [NSMutableArray array];
    self.geneNameLabels = [NSMutableArray array];
    self.genePriceRolls = [NSMutableArray array];
    self.geneSubRolls = [NSMutableArray array];
    self.recordValueLabels = [NSMutableArray array];
    self.combo = 1.0;
    self.musicOn = YES;
    self.musicEra = -1;
    self.nextEventAt = [[NSDate date] timeIntervalSince1970] + 80.0;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    self.haptics = [NSMutableArray array];
    for (NSInteger i = 0; i < 6; i++) {
        UIImpactFeedbackGenerator *g = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [g prepare];
        [self.haptics addObject:g];
    }
    [self setupHapticEngine];
    [self setupSFX];

    [self loadState];
    [self buildUI];
    [self attachHapticsToView:self.view];
    [self rebuildRows];
    [self applyTheme:NO];
    [self setupAmbientParticles];
    [self refreshAll];

    self.tickTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.tickTimer forMode:NSRunLoopCommonModes];
    NSTimer *secTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(onSecondTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:secTimer forMode:NSRunLoopCommonModes];
    NSTimer *saveTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(saveState) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:saveTimer forMode:NSRunLoopCommonModes];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveState) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    // 顶部能量数字：60fps 平滑滚动，带缓动与微缩放
    self.shownEnergy = self.energy;
    self.energyLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onEnergyFrame)];
    // 请求满帧率；配合 Info.plist 的 CADisableMinimumFrameDurationOnPhone，
    // ProMotion 机型会跑到 120Hz，不支持的高刷/60Hz 机型系统自动降级
    self.energyLink.preferredFramesPerSecond = 120;
    [self.energyLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    [self scheduleSpore];
}

- (void)onEnergyFrame {
    if (self.view.window == nil) return;

    double target = self.energy;
    double diff = target - self.shownEnergy;

    if (fabs(diff) <= 0.5) {
        self.shownEnergy = target;
    } else {
        // 与刷新率无关的缓动：60Hz 下相当于每帧 20%
        CFTimeInterval dt = MAX(1.0 / 240.0, self.energyLink.duration);
        double step = diff * (1.0 - pow(0.80, dt * 60.0));
        if (fabs(step) < 6.0) step = (diff > 0 ? 6.0 : -6.0);
        if (fabs(step) > fabs(diff)) step = diff;
        self.shownEnergy += step;
    }

    NSString *text = FmtNum(self.shownEnergy);
    [self.energyRoller setString:text animated:YES];

    // 缩放脉冲：点击/收益到账时轻轻弹一下
    CGFloat scale = 1.0 + 0.055 * self.energyPop;
    self.energyPop *= 0.90;
    if (self.energyPop < 0.01) self.energyPop = 0;
    if (fabs(scale - 1.0) > 0.0005) {
        self.energyRoller.transform = CGAffineTransformMakeScale(scale, scale);
    } else {
        self.energyRoller.transform = CGAffineTransformIdentity;
    }

    // 呼吸辉光，加速中更亮
    CFTimeInterval t = CACurrentMediaTime();
    CGFloat base = 0.32;
    self.energyRoller.glowLabel.layer.shadowOpacity = base + 0.20 * (0.5 + 0.5 * sin(t * 1.7));
    self.energyRoller.textColor = [UIColor whiteColor];
}

- (BOOL)prefersStatusBarHidden { return YES; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskPortrait; }

// ================= 派生数值 =================
// 生效等级（封顶 kGeneMaxLevel）
- (NSInteger)geneEffLevel:(NSInteger)i { return MIN([self geneLevelFor:i], kGeneMaxLevel); }

- (double)geneMult       { return 1.0 + 0.5 * (double)[self geneEffLevel:1]; }
- (double)geneTapMult    { return 1.0 + 0.30 * (double)[self geneEffLevel:2]; }
- (double)geneSporeMult  { return 1.0 + 0.40 * (double)[self geneEffLevel:3]; }
- (double)geneAscendMult { return 1.0 + 0.20 * (double)[self geneEffLevel:5]; }
- (double)geneBossMult   { return 1.0 + 0.35 * (double)[self geneEffLevel:8]; }
- (double)geneSporeRateMult { return MAX(0.10, 1.0 - 0.10 * (double)[self geneEffLevel:7]); }

// 起始遗泽：每条产线起始等级（每 2 级 +1，最多 60 级）
- (NSInteger)geneStartLineLevel { return MIN((NSInteger)300, [self geneEffLevel:6] / 2 + 5 * _relicLv[4]); }

// ---- 图鉴 / 遗物 / 时代事件 带来的全局加成 ----
- (NSInteger)codexUnlocked { return MIN(self.maxStage + 1, kStageCount); }
- (double)codexMult { return 1.0 + 0.02 * (double)[self codexUnlocked]; }
- (double)relicProdMult   { return 1.0 + 0.15 * (double)_relicLv[0]; }
- (double)relicTapMult    { return 1.0 + 0.20 * (double)_relicLv[1]; }
- (double)relicSporeMult  { return 1.0 + 0.30 * (double)_relicLv[2]; }
- (double)relicAscendMult { return 1.0 + 0.10 * (double)_relicLv[3]; }
- (double)relicEventMult  { return MAX(0.35, pow(0.78, (double)_relicLv[5])); }
- (double)eventProdMult {
    NSInteger p = [self eventPressure];
    if (self.eventKind == 1) return MAX(0.12, 0.50 - 0.06 * (double)p);   // 陨石
    if (self.eventKind == 2) return 2.0;                                 // 寒武
    if (self.eventKind == 5) return MAX(0.10, 0.45 - 0.06 * (double)p);   // 日冕风暴
    if (self.eventKind == 7) return MAX(0.20, 0.40 - 0.05 * (double)p);   // 虚空抽取
    return 1.0;
}
- (double)eventCostMult {
    NSInteger p = [self eventPressure];
    if (self.eventKind == 4) return 1.35 + 0.12 * (double)p;   // 熵坍缩
    if (self.eventKind == 6) return 1.55 + 0.15 * (double)p;   // 基因崩解
    return 1.0;
}
- (double)boostMult      { return 1.0; }   // 加速功能已移除
- (double)mutTapMult     { return 1.0 + 0.30 * _muts[MutTap]; }
- (double)mutProdMult    { return 1.0 + 0.20 * _muts[MutProd]; }
- (double)mutCritChance  { return MIN(0.75, 0.15 * _muts[MutCrit] + 0.10 * _muts[MutCritUp]); }   // 暴击概率
- (double)mutComboStep   { return 0.10 + 0.04 * (double)_muts[MutComboRate]; }
- (double)mutEvoWarmMult { return ([[NSDate date] timeIntervalSince1970] < self.evoWarmUntil) ? (1.0 + 0.4 * (double)_muts[MutEvoWarm]) : 1.0; }
- (double)mutBoostTapMult{ return 1.0; }   // 加速类变异已移除
- (double)comboHoldTime  { return 1.2 + 1.0 * _muts[MutComboHold]; }   // 停手多久开始衰减

- (double)comboCap       { return 5.0 + 1.0 * _muts[MutCombo]; }
- (NSInteger)mutTotal {
    NSInteger t = 0;
    for (NSInteger i = 0; i < MutKinds; i++) t += _muts[i];
    return t;
}

- (double)sporeBoostMul {
    if (self.sporeBoostEnd <= 0) return 1.0;
    return ([[NSDate date] timeIntervalSince1970] < self.sporeBoostEnd) ? MAX(1.0, self.sporeBoostMult) : 1.0;
}

- (double)totalProd {
    double sum = 0;
    for (NSInteger i = 0; i <= self.stage && i < kStageCount; i++) {
        sum += _counts[i] * BaseProd(i) * MilestoneMult(_counts[i]);
    }
    return sum * [self geneMult] * [self boostMult] * [self mutProdMult] * [self difficultyProdMult]
           * [self mutEvoWarmMult] * [self codexMult] * [self relicProdMult] * [self eventProdMult]
           * [self sporeBoostMul] * [self autoProdMult];
}
- (double)tapPower { return (0.1 + [self totalProd] * 0.05) * self.combo * [self mutTapMult] * [self geneTapMult] * [self relicTapMult]; }
// 已投入的 DNA 强化总等级（单项按 200 级封顶计入，避免无限等级把难度打爆）
- (NSInteger)totalGeneLevels {
    NSInteger sum = 0;
    for (NSInteger i = 0; i < kGeneCount; i++) sum += MIN([self geneLevelFor:i], 200);
    return sum;
}
// 基因税：DNA 点得越多，进化与飞升越贵
- (double)ascGeneTax { return MIN(60.0, pow(1.05, (double)[self totalGeneLevels])); }
- (double)evoGeneTax { return MIN(25.0, pow(1.03, (double)[self totalGeneLevels])); }

- (NSInteger)eventPressure { return MIN(8, self.autoDiff + MIN(3, self.fastEvoCount / 6) + MIN(3, self.bossRushCount / 4)); }
// 自适应难度按当前压力实时生效（当轮进化过快也立刻变难），飞升后固化为新的基线
- (double)autoProdMult { return pow(0.92, (double)[self eventPressure]); }
- (double)autoCostMult { return pow(1.08, (double)[self eventPressure]); }
- (double)autoEvoMult  { return pow(1.14, (double)[self eventPressure]); }
- (double)autoAscMult  { return pow(1.15, (double)[self eventPressure]); }
- (double)autoDNAMult  { return pow(0.85, (double)[self eventPressure]); }

- (double)ascThreshold {
    // 首次 2e7；之后每次按 20 倍递增：4e8 / 8e9 / 1.6e11 …，再叠加基因税
    double base = (self.ascensions <= 0) ? 2.0e7 : 2.0e7 * pow(20.0, (double)self.ascensions);
    return base * [self ascGeneTax] * [self autoAscMult];
}
// 飞升难度：每次轮回产出效率下调、成本与进化费用上调
- (double)difficultyProdMult { return MAX(0.25, pow(0.85, (double)self.ascensions)); }
- (double)difficultyCostMult { return pow(1.22, (double)self.ascensions); }
- (double)difficultyEvoMult  { return pow(1.30, (double)self.ascensions); }
- (NSInteger)ascDNAGain {
    if (self.runEarned < [self ascThreshold]) return 0;
    NSInteger base = MAX(1, (NSInteger)floor(sqrt(self.runEarned / [self ascThreshold])));
    // 后期 DNA 收紧：每次飞升再乘 0.78，且自适应难度越高 DNA 越少
    double late = pow(0.78, (double)self.ascensions) * [self autoDNAMult];
    return MAX(1, (NSInteger)floor(base * [self geneAscendMult] * [self relicAscendMult] * late));
}

// 成本
- (double)costFor:(NSInteger)i owned:(NSInteger)owned count:(NSInteger)k {
    return BulkCost(i, owned, k) * [self difficultyCostMult] * [self eventCostMult] * [self autoCostMult];
}
- (NSInteger)maxAffordableFor:(NSInteger)i owned:(NSInteger)owned {
    NSInteger n = 0;
    double c = BaseCost(i) * pow(kCostGrowth, (double)owned) * [self difficultyCostMult];
    double total = 0;
    while (n < 5000 && total + c <= self.energy) { total += c; c *= kCostGrowth; n++; }
    return n;
}

// ================= 存档 =================
- (void)loadState {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    self.energy = [d doubleForKey:@"v3_energy"];
    if (self.energy < 0.0 || isnan(self.energy)) self.energy = 0.0;
    self.runEarned = [d doubleForKey:@"v3_runEarned"];
    self.totalEarned = [d doubleForKey:@"v3_total"];
    self.stage = MIN([d integerForKey:@"v3_stage"], kStageCount - 1);
    for (NSInteger i = 0; i < kStageCount; i++) {
        _counts[i] = [[d objectForKey:[NSString stringWithFormat:@"v3_count_%ld", (long)i]] integerValue];
    }
    for (NSInteger i = 0; i < MutKinds; i++) {
        _muts[i] = [[d objectForKey:[NSString stringWithFormat:@"v3_mut_%ld", (long)i]] integerValue];
    }
    self.dna = [d integerForKey:@"v3_dna"];
    self.ascensions = [d integerForKey:@"v3_asc"];
    self.offlineUnlocked = [d boolForKey:@"v3_offline"];
    self.aiOn = [d boolForKey:@"v3_ai"];
    self.geneOfflineLevel = [d integerForKey:@"v3_gene_offline_lv"];
    if (self.offlineUnlocked && self.geneOfflineLevel <= 0) self.geneOfflineLevel = 1;
    self.geneLevel = [d integerForKey:@"v3_gene"];
    self.geneTapLevel = [d integerForKey:@"v3_gene_tap"];
    self.geneSporeLevel = [d integerForKey:@"v3_gene_spore"];
    self.geneAutoLevel = [d integerForKey:@"v3_gene_auto"];
    self.geneAscendLevel = [d integerForKey:@"v3_gene_asc"];
    self.geneStartLevel = [d integerForKey:@"v3_gene_start"];
    self.geneSporeRateLevel = [d integerForKey:@"v3_gene_sporerate"];
    self.geneBossLevel = [d integerForKey:@"v3_gene_boss"];
    self.autoDiff = MIN(6, MAX(0, (NSInteger)[d integerForKey:@"v3_autodiff"]));
    self.bossRushCount = MAX(0, MIN(40, (NSInteger)[d integerForKey:@"v3_bossrush"]));
    self.buyQtyMode = [d integerForKey:@"v3_qty"];
    self.maxStage = MAX([d integerForKey:@"v3_maxstage"], self.stage);
    self.relicPoints = [d integerForKey:@"v3_relicpts"];
    self.totalTaps = [d integerForKey:@"v3_taps"];
    for (NSInteger i = 0; i < kRelicCount; i++)
        _relicLv[i] = [d integerForKey:[NSString stringWithFormat:@"v3_relic_%ld", (long)i]];
    for (NSInteger i = 0; i < 8; i++)
        _achDone[i] = [d boolForKey:[NSString stringWithFormat:@"v3_ach_%ld", (long)i]];
    for (NSInteger i = 0; i < kStageCount; i++)
        _bossDone[i] = [d boolForKey:[NSString stringWithFormat:@"v3_boss_%ld", (long)i]];
    for (NSInteger i = 0; i < 64; i++) {
        _bossFails[i] = [d integerForKey:[NSString stringWithFormat:@"v3_bossfail_%ld", (long)i]];
        _bossDoneRound[i] = [d boolForKey:[NSString stringWithFormat:@"v3_bossr_%ld", (long)i]];
    }
    [self applyOffline];
}

- (void)saveState {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setDouble:self.energy forKey:@"v3_energy"];
    [d setDouble:self.runEarned forKey:@"v3_runEarned"];
    [d setDouble:self.totalEarned forKey:@"v3_total"];
    [d setInteger:self.stage forKey:@"v3_stage"];
    for (NSInteger i = 0; i < kStageCount; i++) {
        [d setInteger:_counts[i] forKey:[NSString stringWithFormat:@"v3_count_%ld", (long)i]];
    }
    for (NSInteger i = 0; i < MutKinds; i++) {
        [d setInteger:_muts[i] forKey:[NSString stringWithFormat:@"v3_mut_%ld", (long)i]];
    }
    [d setInteger:self.dna forKey:@"v3_dna"];
    [d setInteger:self.ascensions forKey:@"v3_asc"];
    [d setBool:self.offlineUnlocked forKey:@"v3_offline"];
    [d setBool:self.aiOn forKey:@"v3_ai"];
    [d setInteger:self.geneOfflineLevel forKey:@"v3_gene_offline_lv"];
    [d setInteger:self.geneLevel forKey:@"v3_gene"];
    [d setInteger:self.geneTapLevel forKey:@"v3_gene_tap"];
    [d setInteger:self.geneSporeLevel forKey:@"v3_gene_spore"];
    [d setInteger:self.geneAutoLevel forKey:@"v3_gene_auto"];
    [d setInteger:self.geneAscendLevel forKey:@"v3_gene_asc"];
    [d setInteger:self.geneStartLevel forKey:@"v3_gene_start"];
    [d setInteger:self.geneSporeRateLevel forKey:@"v3_gene_sporerate"];
    [d setInteger:self.geneBossLevel forKey:@"v3_gene_boss"];
    [d setInteger:self.autoDiff forKey:@"v3_autodiff"];
    [d setInteger:self.bossRushCount forKey:@"v3_bossrush"];
    [d setInteger:self.buyQtyMode forKey:@"v3_qty"];
    [d setInteger:self.maxStage forKey:@"v3_maxstage"];
    [d setInteger:self.relicPoints forKey:@"v3_relicpts"];
    [d setInteger:self.totalTaps forKey:@"v3_taps"];
    for (NSInteger i = 0; i < kRelicCount; i++)
        [d setInteger:_relicLv[i] forKey:[NSString stringWithFormat:@"v3_relic_%ld", (long)i]];
    for (NSInteger i = 0; i < 8; i++)
        [d setBool:_achDone[i] forKey:[NSString stringWithFormat:@"v3_ach_%ld", (long)i]];
    for (NSInteger i = 0; i < kStageCount; i++)
        [d setBool:_bossDone[i] forKey:[NSString stringWithFormat:@"v3_boss_%ld", (long)i]];
    for (NSInteger i = 0; i < 64; i++) {
        [d setInteger:_bossFails[i] forKey:[NSString stringWithFormat:@"v3_bossfail_%ld", (long)i]];
        [d setBool:_bossDoneRound[i] forKey:[NSString stringWithFormat:@"v3_bossr_%ld", (long)i]];
    }
    [d setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"v3_lastSeen"];
    [d synchronize];
}

- (double)offlineReturnRate { return MIN(1.0, 0.5 + 0.10 * (double)[self geneEffLevel:0]); }
- (double)offlineCapHours   { return MIN(24.0, 8.0 + (double)[self geneEffLevel:0]); }

- (void)applyOffline {
    if (!self.offlineUnlocked || [self geneEffLevel:0] <= 0) return;
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    double last = [d doubleForKey:@"v3_lastSeen"];
    if (last <= 0) return;
    double elapsed = MIN([[NSDate date] timeIntervalSince1970] - last, [self offlineCapHours] * 3600.0);
    if (elapsed < 15) return;
    double gain = [self totalProd] * elapsed * [self offlineReturnRate];
    if (gain >= 1) {
        self.energy += gain;
        self.runEarned += gain;
    self.totalEarned += gain;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self floatGain:gain prefix:@"🌙" color:[UIColor colorWithRed:1.0 green:0.50 blue:0.82 alpha:1]
                         size:22 at:[self creatureCenterInView] rise:90];
            [self toast:[NSString stringWithFormat:@"离线收益 ⚡+%@", FmtNum(gain)]];
        });
    }
}

- (void)onForeground { [self startHapticEngine]; [self applyOffline]; }

// ================= UI 构建 =================
- (void)buildUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    self.bgLayer = [CAGradientLayer layer];
    self.bgLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.bgLayer];

    // 暗角，让中心更亮
    self.vignette = [CAGradientLayer layer];
    self.vignette.type = kCAGradientLayerRadial;
    self.vignette.frame = self.view.bounds;
    self.vignette.startPoint = CGPointMake(0.5, 0.45);
    self.vignette.endPoint = CGPointMake(1.0, 1.0);
    self.vignette.colors = @[(id)[[UIColor clearColor] CGColor],
                             (id)[[UIColor colorWithWhite:0 alpha:0.45] CGColor]];
    self.vignette.locations = @[@0.35, @1.0];
    [self.view.layer addSublayer:self.vignette];

    // 背景极光（两团缓慢漂移的径向光晕）
    self.auroraA = [CAGradientLayer layer];
    self.auroraA.type = kCAGradientLayerRadial;
    self.auroraA.startPoint = CGPointMake(0.5, 0.5);
    self.auroraA.endPoint = CGPointMake(1.0, 1.0);
    self.auroraA.frame = CGRectMake(-120, H * 0.18, 520, 520);
    [self.view.layer addSublayer:self.auroraA];

    self.auroraB = [CAGradientLayer layer];
    self.auroraB.type = kCAGradientLayerRadial;
    self.auroraB.startPoint = CGPointMake(0.5, 0.5);
    self.auroraB.endPoint = CGPointMake(1.0, 1.0);
    self.auroraB.frame = CGRectMake(W - 380, H * 0.42, 460, 460);
    [self.view.layer addSublayer:self.auroraB];

    CABasicAnimation *drift = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    drift.fromValue = @(-18); drift.toValue = @(18);
    drift.duration = 9; drift.autoreverses = YES; drift.repeatCount = HUGE_VALF;
    [self.auroraA addAnimation:drift forKey:@"drift"];
    CABasicAnimation *drift2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    drift2.fromValue = @(-14); drift2.toValue = @(14);
    drift2.duration = 12; drift2.autoreverses = YES; drift2.repeatCount = HUGE_VALF;
    [self.auroraB addAnimation:drift2 forKey:@"drift"];

    // ---- 顶部统计 ----
    self.energyRoller = [[RollNumberView alloc] initWithFrame:CGRectMake(18, 40, W - 136, 44)
                                                         font:[UIFont monospacedSystemFontOfSize:33 weight:UIFontWeightHeavy]];
    self.energyRoller.textColor = [UIColor whiteColor];
    [self.view addSubview:self.energyRoller];

    self.autoLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 82, W - 120, 14)];
    self.autoLabel.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightMedium];
    self.autoLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
    [self.view addSubview:self.autoLabel];

    self.sporeBuffPill = [[UILabel alloc] initWithFrame:CGRectMake(W - 158, 74, 140, 22)];
    self.sporeBuffPill.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightBold];
    self.sporeBuffPill.textColor = [UIColor colorWithRed:1.0 green:0.86 blue:0.42 alpha:1];
    self.sporeBuffPill.backgroundColor = [UIColor colorWithRed:0.55 green:0.36 blue:0.03 alpha:0.55];
    self.sporeBuffPill.textAlignment = NSTextAlignmentCenter;
    self.sporeBuffPill.layer.cornerRadius = 11;
    self.sporeBuffPill.clipsToBounds = YES;
    self.sporeBuffPill.layer.borderWidth = 1.2;
    self.sporeBuffPill.layer.borderColor = [UIColor colorWithRed:1.0 green:0.80 blue:0.30 alpha:0.9].CGColor;
    self.sporeBuffPill.hidden = YES;
    [self.view addSubview:self.sporeBuffPill];

    self.rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 98, W - 120, 13)];
    self.rateLabel.font = [UIFont systemFontOfSize:10];
    self.rateLabel.textColor = [UIColor colorWithWhite:1 alpha:0.42];
    [self.view addSubview:self.rateLabel];

    self.dnaBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dnaBtn.frame = CGRectMake(W - 96, 44, 82, 30);
    self.dnaBtn.layer.cornerRadius = 15;
    self.dnaBtn.layer.borderWidth = 1;
    self.dnaBtn.layer.borderColor = [UIColor colorWithRed:0.7 green:0.5 blue:1 alpha:0.7].CGColor;
    self.dnaBtn.backgroundColor = [UIColor colorWithRed:0.3 green:0.16 blue:0.5 alpha:0.55];
    [self.dnaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.dnaBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.dnaBtn addTarget:self action:@selector(onDNA) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dnaBtn];
    self.dnaRoll = [self attachRollLabelToButton:self.dnaBtn];
    self.dnaRoll.font = [UIFont boldSystemFontOfSize:14];

    UIButton *reset = [UIButton buttonWithType:UIButtonTypeSystem];
    reset.frame = CGRectMake(W - 96, 80, 82, 22);
    [reset setTitle:@"重置存档" forState:UIControlStateNormal];
    [reset setTitleColor:[UIColor colorWithWhite:1 alpha:0.38] forState:UIControlStateNormal];
    reset.titleLabel.font = [UIFont systemFontOfSize:11];
    [reset addTarget:self action:@selector(onReset) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reset];

    UIButton *music = [UIButton buttonWithType:UIButtonTypeSystem];
    music.frame = CGRectMake(W - 62, 104, 50, 50);
    [music setTitle:@"🔊" forState:UIControlStateNormal];
    music.titleLabel.font = [UIFont systemFontOfSize:26];
    music.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
    music.layer.cornerRadius = 25;
    music.layer.borderWidth = 1;
    music.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.22] CGColor];
    music.clipsToBounds = YES;
    music.alpha = 0.95;
    [music addTarget:self action:@selector(onToggleMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:music];
    self.musicBtn = music;

    UIButton *aib = [UIButton buttonWithType:UIButtonTypeSystem];
    aib.frame = CGRectMake(W - 122, 104, 50, 50);
    [aib setTitle:@"🤖" forState:UIControlStateNormal];
    aib.titleLabel.font = [UIFont systemFontOfSize:24];
    aib.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
    aib.layer.cornerRadius = 25;
    aib.layer.borderWidth = 1;
    aib.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.22] CGColor];
    aib.clipsToBounds = YES;
    [aib addTarget:self action:@selector(onToggleAI) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aib];
    self.aiBtn = aib;

    // ---- 生物区 ----
    CGFloat zoneY = 116;
    CGFloat zoneH = MAX(170, MIN(205, H * 0.24));
    TapZoneView *zone = [[TapZoneView alloc] initWithFrame:CGRectMake(0, zoneY, W, zoneH)];
    __weak typeof(self) weakSelf = self;
    zone.onTouchBlock = ^(CGPoint p) {
        [weakSelf handleTapAtPointInArea:p];
    };
    self.creatureArea = zone;
    [self.view addSubview:self.creatureArea];
    if (self.musicBtn) [self.view bringSubviewToFront:self.musicBtn];
    if (self.aiBtn) [self.view bringSubviewToFront:self.aiBtn];
    [self updateAIButton];
    if (self.aiOn) [self startAITimer];

    self.creatureNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, W, 24)];
    self.creatureNameLabel.textAlignment = NSTextAlignmentCenter;
    self.creatureNameLabel.font = [UIFont boldSystemFontOfSize:19];
    self.creatureNameLabel.textColor = [UIColor whiteColor];
    [self.creatureArea addSubview:self.creatureNameLabel];

    self.eraLabel = [[RollLabel alloc] initWithFrame:CGRectMake(0, 25, W, 14)];
    self.eraLabel.textAlignment = NSTextAlignmentCenter;
    self.eraLabel.font = [UIFont systemFontOfSize:11];
    self.eraLabel.textColor = [UIColor colorWithWhite:1 alpha:0.45];
    [self.creatureArea addSubview:self.eraLabel];

    CGFloat ringSize = zoneH - 78;
    CGFloat ringX = (W - ringSize) / 2, ringY = 42;
    UIBezierPath *ringPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ringSize/2, ringSize/2)
                                                            radius:ringSize/2 - 4
                                                        startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
    UIView *ringHost = [[UIView alloc] initWithFrame:CGRectMake(ringX, ringY, ringSize, ringSize)];
    ringHost.userInteractionEnabled = NO;
    [self.creatureArea addSubview:ringHost];

    // 两圈向外扩散的光环
    self.aura1 = [CAShapeLayer layer];
    self.aura1.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ringSize/2, ringSize/2)
                                                     radius:ringSize/2 - 12
                                                 startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
    self.aura1.fillColor = [UIColor clearColor].CGColor;
    self.aura1.lineWidth = 2;
    self.aura1.opacity = 0;
    [ringHost.layer insertSublayer:self.aura1 atIndex:0];

    self.aura2 = [CAShapeLayer layer];
    self.aura2.path = self.aura1.path;
    self.aura2.fillColor = [UIColor clearColor].CGColor;
    self.aura2.lineWidth = 1.5;
    self.aura2.opacity = 0;
    [ringHost.layer insertSublayer:self.aura2 atIndex:0];

    CABasicAnimation *breathe = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    breathe.fromValue = @1.0; breathe.toValue = @1.045;
    breathe.duration = 2.3; breathe.autoreverses = YES; breathe.repeatCount = HUGE_VALF;
    [ringHost.layer addAnimation:breathe forKey:@"breathe"];

    UIView *glow = [[UIView alloc] initWithFrame:CGRectInset(ringHost.bounds, 10, 10)];
    glow.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    glow.layer.cornerRadius = glow.bounds.size.width / 2;
    [ringHost addSubview:glow];

    self.ringBg = [CAShapeLayer layer];
    self.ringBg.path = ringPath.CGPath;
    self.ringBg.strokeColor = [UIColor colorWithWhite:1 alpha:0.10].CGColor;
    self.ringBg.fillColor = [UIColor clearColor].CGColor;
    self.ringBg.lineWidth = 3;
    [ringHost.layer addSublayer:self.ringBg];

    self.ringFill = [CAShapeLayer layer];
    self.ringFill.path = ringPath.CGPath;
    self.ringFill.fillColor = [UIColor clearColor].CGColor;
    self.ringFill.lineWidth = 3;
    self.ringFill.lineCap = kCALineCapRound;
    self.ringFill.strokeEnd = 0;
    [ringHost.layer addSublayer:self.ringFill];

    self.creatureLabel = [[UILabel alloc] initWithFrame:ringHost.bounds];
    self.creatureLabel.textAlignment = NSTextAlignmentCenter;
    self.creatureLabel.font = [UIFont systemFontOfSize:ringSize * 0.5];
    self.creatureLabel.layer.shadowRadius = 12;
    self.creatureLabel.layer.shadowOpacity = 0.55;
    self.creatureLabel.layer.shadowOffset = CGSizeZero;
    [ringHost addSubview:self.creatureLabel];

    self.comboLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, zoneH - 24, W, 20)];
    self.comboLabel.textAlignment = NSTextAlignmentCenter;
    self.comboLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.creatureArea addSubview:self.comboLabel];

    CGFloat y = zoneY + zoneH + 6;

    // ---- 进化按钮 ----
    self.evolveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.evolveBtn.frame = CGRectMake(18, y, W - 36, 46);
    self.evolveBtn.layer.cornerRadius = 14;
    self.evolveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.evolveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.evolveBtn addTarget:self action:@selector(onEvolve) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.evolveBtn];
    self.evolveRoll = [self attachRollLabelToButton:self.evolveBtn];
    self.evolveRoll.font = [UIFont boldSystemFontOfSize:16];
    y += 54;

    // ---- 飞升：文字行 + 进度条 + 全宽按钮 ----
    self.ascLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, W - 120, 16)];
    self.ascLabel.font = [UIFont systemFontOfSize:11];
    self.ascLabel.textColor = [UIColor colorWithWhite:1 alpha:0.55];
    [self.view addSubview:self.ascLabel];

    self.ascPctLabel = [[UILabel alloc] initWithFrame:CGRectMake(W - 100, y, 80, 16)];
    self.ascPctLabel.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightMedium];
    self.ascPctLabel.textColor = [UIColor colorWithRed:0.75 green:0.55 blue:1 alpha:1];
    self.ascPctLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.ascPctLabel];

    self.ascTrack = [[UIView alloc] initWithFrame:CGRectMake(20, y + 20, W - 40, 6)];
    self.ascTrack.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
    self.ascTrack.layer.cornerRadius = 3;
    self.ascTrack.clipsToBounds = YES;
    [self.view addSubview:self.ascTrack];

    self.ascFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 6)];
    self.ascFill.backgroundColor = [UIColor colorWithRed:0.72 green:0.45 blue:1 alpha:1];
    [self.ascTrack addSubview:self.ascFill];

    self.ascendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.ascendBtn.frame = CGRectMake(18, y + 32, W - 36, 46);
    self.ascendBtn.layer.cornerRadius = 14;
    self.ascendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.ascendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.ascendBtn addTarget:self action:@selector(onAscend) forControlEvents:UIControlEventTouchUpInside];
    self.ascendRoll = [self attachRollLabelToButton:self.ascendBtn];
    self.ascendBtn.enabled = NO;
    [self.view addSubview:self.ascendBtn];
    y += 86;

    // ---- 购买数量 ----
    UILabel *qtyTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, y + 4, 86, 22)];
    qtyTitle.text = @"每次购买数量";
    qtyTitle.font = [UIFont systemFontOfSize:11];
    qtyTitle.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self.view addSubview:qtyTitle];

    NSArray *qtyTitles = @[@"1", @"10", @"100", @"最大"];
    CGFloat qx = 108, qw = (W - 128) / 4.0;
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(qx + i * qw + 2, y, qw - 6, 28);
        b.layer.cornerRadius = 14;
        b.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        b.tag = i;
        [b setTitle:qtyTitles[i] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(onQty:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
        [self.qtyBtns addObject:b];
    }
    y += 36;

    // ---- 生产线列表 ----
    self.listScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(12, y, W - 24, H - y - 84 - 10)];
    self.listScroll.alwaysBounceVertical = YES;
    [self.view addSubview:self.listScroll];

    [self buildTabBar];
    [self buildPanels];
    [self buildEventBanner];
    [self selectTab:0];
}

// ================= 底部四标签 =================
- (void)buildTabBar {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    CGFloat barH = 84;
    self.tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, H - barH, W, barH)];
    self.tabBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.78];
    [self.view addSubview:self.tabBar];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, 0.5)];
    line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
    [self.tabBar addSubview:line];

    NSArray *titles = @[@"生命", @"基因组", @"变异", @"图鉴", @"转生", @"记录"];
    NSArray *symbols = @[@"drop.fill", @"circle.hexagongrid.fill", @"arrow.triangle.branch",
                         @"book.closed.fill", @"sparkles", @"chart.bar.fill"];
    CGFloat colW = W / 6.0;
    for (NSInteger i = 0; i < 6; i++) {
        UIImage *img = [UIImage systemImageNamed:symbols[i]];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(colW * i + colW / 2 - 10, 14, 20, 20)];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.image = img;
        iv.tintColor = [UIColor colorWithWhite:1 alpha:0.35];
        [self.tabBar addSubview:iv];
        [self.tabIcons addObject:iv];

        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(colW * i, 38, colW, 14)];
        lb.text = titles[i];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.font = [UIFont systemFontOfSize:10];
        lb.textColor = [UIColor colorWithWhite:1 alpha:0.35];
        [self.tabBar addSubview:lb];
        [self.tabLabels addObject:lb];

        UIButton *hit = [UIButton buttonWithType:UIButtonTypeCustom];
        hit.frame = CGRectMake(colW * i, 0, colW, barH - 20);
        hit.tag = i;
        [hit addTarget:self action:@selector(onTab:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBar addSubview:hit];
    }
}

- (void)onTab:(UIButton *)b {
    [self selectTab:b.tag];
}

- (void)selectTab:(NSInteger)idx {
    self.currentTab = idx;
    for (UIView *v in self.view.subviews) {
        if (v.tag == 9901) [v removeFromSuperview];
    }
    self.genePage.hidden = (idx != 1);
    self.mutPage.hidden = (idx != 2);
    self.codexPage.hidden = (idx != 3);
    self.relicPage.hidden = (idx != 4);
    self.recordPage.hidden = (idx != 5);
    if (idx != 0) {
        [self.sporeBtn removeFromSuperview];
        self.sporeActive = NO;
    }
    for (NSInteger i = 0; i < 6; i++) {
        BOOL sel = (i == idx);
        UIImageView *iv = self.tabIcons[i];
        iv.tintColor = sel ? [UIColor whiteColor] : [UIColor colorWithWhite:1 alpha:0.35];
        UILabel *lb = self.tabLabels[i];
        lb.textColor = sel ? [UIColor whiteColor] : [UIColor colorWithWhite:1 alpha:0.35];
        lb.font = sel ? [UIFont boldSystemFontOfSize:11] : [UIFont systemFontOfSize:11];
    }
    [self.view bringSubviewToFront:self.tabBar];
    if (idx == 0) { [self applyTheme:NO]; [self refreshAll]; }
    if (idx == 1) [self refreshGenePage];
    if (idx == 2) [self refreshMutPage];
    if (idx == 3) [self refreshCodexPage];
    if (idx == 4) [self refreshRelicPage];
    if (idx == 5) [self refreshRecordPage];
}

// ================= 三个子页面 =================
- (UIView *)makePageWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    UIView *page = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, H - 84)];
    page.hidden = YES;

    UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blur.frame = page.bounds;
    [page addSubview:blur];
    UIView *tint = [[UIView alloc] initWithFrame:page.bounds];
    tint.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    [page addSubview:tint];

    UILabel *tl = [[UILabel alloc] initWithFrame:CGRectMake(18, 54, W - 36, 32)];
    tl.text = title;
    tl.font = [UIFont boldSystemFontOfSize:26];
    tl.textColor = [UIColor whiteColor];
    [page addSubview:tl];

    UILabel *sl = [[UILabel alloc] initWithFrame:CGRectMake(18, 88, W - 36, 16)];
    sl.text = subtitle;
    sl.font = [UIFont systemFontOfSize:11.5];
    sl.textColor = [UIColor colorWithWhite:1 alpha:0.45];
    [page addSubview:sl];

    [self.view addSubview:page];
    return page;
}

- (UILabel *)statRowIn:(UIView *)parent y:(CGFloat)y title:(NSString *)title {
    CGFloat W = self.view.bounds.size.width;
    CGFloat cw = W - 32;
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(16, y, cw, 46)];
    card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    card.layer.cornerRadius = 12;
    [parent addSubview:card];

    UILabel *tl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, cw * 0.55, 46)];
    tl.text = title;
    tl.font = [UIFont systemFontOfSize:13];
    tl.textColor = [UIColor colorWithWhite:1 alpha:0.55];
    [card addSubview:tl];

    RollLabel *vl = [[RollLabel alloc] initWithFrame:CGRectMake(cw * 0.45, 0, cw * 0.55 - 14, 46)];
    vl.textAlignment = NSTextAlignmentRight;
    vl.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightSemibold];
    vl.textColor = [UIColor whiteColor];
    [card addSubview:vl];
    return vl;
}

- (void)buildPanels {
    CGFloat W = self.view.bounds.size.width;

    // ---- 基因组 ----
    self.genePage = [self makePageWithTitle:@"基因组" subtitle:@"用 DNA 解锁永久强化 · 飞升后保留"];
    UIView *dnaPill = [[UIView alloc] initWithFrame:CGRectMake(W - 138, 52, 120, 40)];
    dnaPill.backgroundColor = [UIColor colorWithRed:0.30 green:0.16 blue:0.50 alpha:0.55];
    dnaPill.layer.cornerRadius = 20;
    dnaPill.layer.borderWidth = 1;
    dnaPill.layer.borderColor = [[UIColor colorWithRed:0.72 green:0.55 blue:1 alpha:0.8] CGColor];
    [self.genePage addSubview:dnaPill];

    UILabel *dnaCap = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 44, 40)];
    dnaCap.text = @"可用";
    dnaCap.font = [UIFont systemFontOfSize:10];
    dnaCap.textColor = [UIColor colorWithWhite:1 alpha:0.55];
    [dnaPill addSubview:dnaCap];

    self.geneDnaLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 64, 40)];
    self.geneDnaLabel.textAlignment = NSTextAlignmentRight;
    self.geneDnaLabel.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightBold];
    self.geneDnaLabel.textColor = [UIColor colorWithRed:0.82 green:0.70 blue:1 alpha:1];
    [dnaPill addSubview:self.geneDnaLabel];

    UILabel *qtyTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 118, 80, 28)];
    qtyTitle.text = @"每次升级";
    qtyTitle.font = [UIFont systemFontOfSize:11];
    qtyTitle.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self.genePage addSubview:qtyTitle];

    NSArray *qt = @[@"1 级", @"10 级", @"最大"];
    CGFloat qx = 100, qw = (W - 120) / 3.0;
    for (NSInteger i = 0; i < 3; i++) {
        UIButton *qb = [UIButton buttonWithType:UIButtonTypeCustom];
        qb.frame = CGRectMake(qx + i * qw + 2, 118, qw - 4, 28);
        qb.layer.cornerRadius = 14;
        qb.tag = i;
        qb.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [qb setTitle:qt[i] forState:UIControlStateNormal];
        [qb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [qb addTarget:self action:@selector(onGeneQty:) forControlEvents:UIControlEventTouchUpInside];
        [self.genePage addSubview:qb];
        [self.geneQtyBtns addObject:qb];
    }

    UIScrollView *geneScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 158, W, self.genePage.bounds.size.height - 158)];
    geneScroll.alwaysBounceVertical = YES;
    geneScroll.showsVerticalScrollIndicator = NO;
    [self.genePage addSubview:geneScroll];

    for (NSInteger i = 0; i < kGeneCount; i++) {
        CGFloat y = i * 100;
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(16, y, W - 32, 90)];
        card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
        card.layer.cornerRadius = 16;
        [geneScroll addSubview:card];

        UILabel *ic = [[UILabel alloc] initWithFrame:CGRectMake(14, 16, 40, 40)];
        ic.text = [NSString stringWithUTF8String:kGenes[i].icon];
        ic.font = [UIFont systemFontOfSize:26];
        ic.textAlignment = NSTextAlignmentCenter;
        ic.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
        ic.layer.cornerRadius = 11;
        ic.clipsToBounds = YES;
        [card addSubview:ic];

        RollLabel *nm = [[RollLabel alloc] initWithFrame:CGRectMake(64, 15, W - 32 - 168, 22)];
        nm.text = [NSString stringWithUTF8String:kGenes[i].name];
        nm.font = [UIFont boldSystemFontOfSize:15.5];
        nm.textColor = [UIColor whiteColor];
        [card addSubview:nm];
        [self.geneNameLabels addObject:nm];

        UILabel *ds = [[UILabel alloc] initWithFrame:CGRectMake(64, 39, W - 32 - 150, 30)];
        ds.numberOfLines = 2;
        ds.text = [NSString stringWithUTF8String:kGenes[i].desc];
        ds.font = [UIFont systemFontOfSize:10.5];
        ds.textColor = [UIColor colorWithWhite:1 alpha:0.45];
        [card addSubview:ds];

        UIButton *buy = [UIButton buttonWithType:UIButtonTypeSystem];
        buy.frame = CGRectMake(W - 32 - 84, 23, 74, 44);
        buy.layer.cornerRadius = 12;
        buy.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        buy.tag = i;
        [buy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buy addTarget:self action:@selector(onGeneRow:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:buy];
        [self.geneBuyBtns addObject:buy];

        RollLabel *pr = [[RollLabel alloc] initWithFrame:CGRectMake(2, 4, 70, 18)];
        pr.textAlignment = NSTextAlignmentCenter;
        pr.font = [UIFont boldSystemFontOfSize:12];
        pr.textColor = [UIColor whiteColor];
        pr.userInteractionEnabled = NO;
        [buy addSubview:pr];
        [self.genePriceRolls addObject:pr];

        RollLabel *sr = [[RollLabel alloc] initWithFrame:CGRectMake(2, 23, 70, 13)];
        sr.textAlignment = NSTextAlignmentCenter;
        sr.font = [UIFont systemFontOfSize:9];
        sr.textColor = [UIColor colorWithWhite:1 alpha:0.62];
        sr.userInteractionEnabled = NO;
        [buy addSubview:sr];
        [self.geneSubRolls addObject:sr];
    }

    UILabel *note = [[UILabel alloc] initWithFrame:CGRectMake(20, kGeneCount * 100 + 6, W - 40, 54)];
    note.numberOfLines = 3;
    note.text = @"DNA 只能通过飞升获得：飞升门槛每轮 ×20，收益越高 DNA 越多。你投入的 DNA 强化等级越多，进化费用与下次飞升门槛越高（基因税）。";
    note.font = [UIFont systemFontOfSize:10.5];
    note.textColor = [UIColor colorWithWhite:1 alpha:0.35];
    [geneScroll addSubview:note];

    geneScroll.contentSize = CGSizeMake(W, kGeneCount * 100 + 70);

    // ---- 变异 ----
    self.mutPage = [self makePageWithTitle:@"变异" subtitle:@"每次进化随机 3 选 1 · 本轮有效，飞升或重置后清空"];
    UIScrollView *mutScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 112, W, self.mutPage.bounds.size.height - 112)];
    mutScroll.alwaysBounceVertical = YES;
    mutScroll.showsVerticalScrollIndicator = NO;
    [self.mutPage addSubview:mutScroll];

    for (NSInteger i = 0; i < MutKinds; i++) {
        CGFloat y = i * 72;
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(16, y, W - 32, 66)];
        card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
        card.layer.cornerRadius = 14;
        [mutScroll addSubview:card];

        UILabel *ic = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 38, 38)];
        ic.text = [NSString stringWithUTF8String:kMuts[i].icon];
        ic.font = [UIFont systemFontOfSize:24];
        ic.textAlignment = NSTextAlignmentCenter;
        ic.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
        ic.layer.cornerRadius = 10;
        ic.clipsToBounds = YES;
        [card addSubview:ic];

        UILabel *nm = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, W - 32 - 140, 20)];
        nm.text = [NSString stringWithUTF8String:kMuts[i].name];
        nm.font = [UIFont boldSystemFontOfSize:15];
        nm.textColor = [UIColor whiteColor];
        [card addSubview:nm];

        UILabel *ds = [[UILabel alloc] initWithFrame:CGRectMake(60, 34, W - 32 - 140, 16)];
        ds.text = [NSString stringWithUTF8String:kMuts[i].desc];
        ds.font = [UIFont systemFontOfSize:10.5];
        ds.textColor = [UIColor colorWithWhite:1 alpha:0.45];
        [card addSubview:ds];

        RollLabel *cnt = [[RollLabel alloc] initWithFrame:CGRectMake(W - 32 - 64, 20, 52, 24)];
        cnt.textAlignment = NSTextAlignmentRight;
        cnt.font = [UIFont monospacedDigitSystemFontOfSize:15 weight:UIFontWeightBold];
        cnt.textColor = [UIColor whiteColor];
        [card addSubview:cnt];
        [self.mutCountLabels addObject:cnt];
    }
    mutScroll.contentSize = CGSizeMake(W, MutKinds * 72 + 20);

    // ---- 记录 ----
    self.recordPage = [self makePageWithTitle:@"记录" subtitle:@"本局数据总览"];
    NSArray *stats = @[@"本轮累计收益", @"历史总收益", @"每秒自动产出", @"每次点击收益",
                       @"连击上限", @"飞升次数", @"当前 DNA", @"本轮变异数", @"当前形态",
                       @"轮回难度", @"难度修正"];
    UIScrollView *recScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 112, W, self.recordPage.bounds.size.height - 112)];
    recScroll.alwaysBounceVertical = YES;
    recScroll.showsVerticalScrollIndicator = NO;
    [self.recordPage addSubview:recScroll];

    for (NSInteger i = 0; i < (NSInteger)stats.count; i++) {
        UILabel *v = [self statRowIn:recScroll y:8 + i * 52 title:stats[i]];
        [self.recordValueLabels addObject:v];
    }
    recScroll.contentSize = CGSizeMake(W, stats.count * 52 + 24);

    [self buildCodexPage];
    [self buildRelicPage];
}

- (NSInteger)geneLevelFor:(NSInteger)i {
    switch (i) {
        case 0: return self.geneOfflineLevel;
        case 1: return self.geneLevel;
        case 2: return self.geneTapLevel;
        case 3: return self.geneSporeLevel;
        case 4: return self.geneAutoLevel;
        case 5: return self.geneAscendLevel;
        case 6: return self.geneStartLevel;
        case 7: return self.geneSporeRateLevel;
        case 8: return self.geneBossLevel;
        default: return 0;
    }
}

// 单级在当前等级的花费（不含已涨的等级）
- (NSInteger)geneStepFor:(NSInteger)i { return (i == 4) ? 3 : 1; }

// 基因单价按等级指数上涨（1.12^L），避免 DNA 无限灌进线性强化
#define GENE_PRICE_GROWTH 1.10

- (double)geneBasePrice:(NSInteger)i {
    switch (i) {
        case 0: return 1;    // 离线收益（可无限叠加）
        case 4: return 3;    // 自动触手
        case 5: return 2;    // 飞升红利
        case 6: return 3;    // 起始遗泽
        case 7: return 1;    // 孢子之频
        case 8: return 2;    // 试炼锋芒
        default: return 1;
    }
}

- (NSInteger)geneCostAtLevel:(NSInteger)i {
    double c = [self geneBasePrice:i] * pow(GENE_PRICE_GROWTH, (double)[self geneLevelFor:i]);
    if (c >= 9.0e18) return (NSInteger)9.0e18;
    return MAX(1, (NSInteger)ceil(c));
}

// 连买 k 级的总花费（等比求和）
- (NSInteger)geneCostSum:(NSInteger)i count:(NSInteger)k {
    if (k <= 0) k = 1;
    double a = (double)[self geneCostAtLevel:i];
    double r = GENE_PRICE_GROWTH;
    double sum = a * (pow(r, (double)k) - 1.0) / (r - 1.0);
    if (sum >= 9.0e18) return (NSInteger)9.0e18;
    return MAX(1, (NSInteger)ceil(sum));
}

- (NSInteger)geneMaxCountFor:(NSInteger)i {
    double a = (double)[self geneCostAtLevel:i];
    double dna = (double)self.dna;
    if (a > dna) return 1;
    double k = log(1.0 + dna * (GENE_PRICE_GROWTH - 1.0) / a) / log(GENE_PRICE_GROWTH);
    NSInteger kk = (NSInteger)floor(k);
    if (i == 0) kk = MIN(kk, (NSInteger)5);
    if (kk < 1) kk = 1;
    if (kk > 500) kk = 500;
    while (kk > 1 && [self geneCostSum:i count:kk] > self.dna) kk--;
    while (kk < 500 && [self geneCostSum:i count:kk + 1] <= self.dna) kk++;
    return MAX(1, kk);
}

- (NSInteger)geneBuyCountFor:(NSInteger)i {
    if (self.geneQtyMode == 0) return 1;
    if (self.geneQtyMode == 1) return 10;
    return [self geneMaxCountFor:i];
}

- (void)onGeneQty:(UIButton *)b {
    self.geneQtyMode = b.tag;
    [self refreshGenePage];
}

- (NSInteger)geneCostFor:(NSInteger)i {
    if (i == 4) return 3 + 3 * self.geneAutoLevel;
    if (i == 5) return self.geneAscendLevel + 2;
    if (i == 6) return self.geneStartLevel + 3;
    if (i == 7) return self.geneSporeRateLevel + 1;
    if (i == 8) return self.geneBossLevel + 2;
    return [self geneLevelFor:i] + 1;
}

- (void)refreshGenePage {
    if (self.genePage.hidden) return;
    self.geneDnaLabel.text = FmtInt(self.dna);

    for (NSInteger i = 0; i < (NSInteger)self.geneQtyBtns.count; i++) {
        UIButton *qb = self.geneQtyBtns[i];
        BOOL sel = (i == self.geneQtyMode);
        qb.backgroundColor = [UIColor colorWithWhite:1 alpha:sel ? 0.14 : 0.05];
        qb.layer.borderWidth = sel ? 1.5 : 0;
        qb.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.85].CGColor;
        [qb setTitleColor:[UIColor colorWithWhite:1 alpha:sel ? 1.0 : 0.5] forState:UIControlStateNormal];
    }

    for (NSInteger i = 0; i < (NSInteger)self.geneBuyBtns.count; i++) {
        UIButton *buy = self.geneBuyBtns[i];
        UILabel *nm = self.geneNameLabels[i];
        NSString *base = [NSString stringWithUTF8String:kGenes[i].name];

        if (i == 0) {
            NSInteger olv = self.geneOfflineLevel;
            NSInteger ok = [self geneBuyCountFor:0];
            NSInteger ocost = [self geneCostSum:0 count:ok];
            nm.text = [NSString stringWithFormat:@"%@ Lv.%@", base, FmtInt(olv)];
            RollLabel *pr = self.genePriceRolls[0];
            RollLabel *sr = self.geneSubRolls[0];
            BOOL ocan = (self.dna >= ocost);
            pr.text = [NSString stringWithFormat:@"%@ 🧬", FmtInt(ocost)];
            pr.textColor = ocan ? [UIColor colorWithWhite:0 alpha:0.85] : [UIColor colorWithWhite:1 alpha:0.45];
            sr.text = [NSString stringWithFormat:@"返还 %.0f%% · 上限 %.0f 小时%@", [self offlineReturnRate] * 100.0,
                       [self offlineCapHours], (ok > 1) ? [NSString stringWithFormat:@" · +%@ 级", FmtInt(ok)] : @""];
            sr.textColor = [UIColor colorWithWhite:1 alpha:0.55];
            [buy setTitle:@"" forState:UIControlStateNormal];
            buy.backgroundColor = ocan ? [UIColor colorWithRed:0.35 green:0.95 blue:0.55 alpha:0.9]
                                       : [UIColor colorWithWhite:1 alpha:0.10];
            continue;
        }

        NSInteger lv = [self geneLevelFor:i];
        NSInteger k = [self geneBuyCountFor:i];
        NSInteger cost = [self geneCostSum:i count:k];
        nm.text = [NSString stringWithFormat:@"%@ Lv.%@", base, FmtInt(lv)];
        RollLabel *pr2 = self.genePriceRolls[i];
        RollLabel *sr2 = self.geneSubRolls[i];
        pr2.text = [NSString stringWithFormat:@"%@ 🧬", FmtInt(cost)];
        sr2.text = (k > 1) ? [NSString stringWithFormat:@"+%@ 级", FmtInt(k)] : @"";
        [buy setTitle:@"" forState:UIControlStateNormal];
        BOOL can = (self.dna >= cost);
        buy.backgroundColor = can ? [UIColor colorWithRed:0.35 green:0.95 blue:0.55 alpha:0.9]
                                  : [UIColor colorWithWhite:1 alpha:0.10];
        pr2.textColor = can ? [UIColor colorWithWhite:0 alpha:0.85] : [UIColor colorWithWhite:1 alpha:0.45];
    }
}

- (void)onGeneRow:(UIButton *)b {
    NSInteger i = b.tag;


    NSInteger k = [self geneBuyCountFor:i];
    NSInteger cost = [self geneCostSum:i count:k];
    if (self.dna < cost && self.geneQtyMode == 2 && i != 0) {
        // 最大档位时按买得起的级别收缩
        k = [self geneMaxCountFor:i];
        cost = [self geneCostSum:i count:k];
    }
    if (self.dna < cost) {
        [self toast:[NSString stringWithFormat:@"DNA 不足（需要 %@🧬）", FmtInt(cost)]];
        return;
    }

    self.dna -= cost;
    NSString *msg = nil;
    switch (i) {
        case 0:
            self.geneOfflineLevel += k;
            self.offlineUnlocked = YES;
            msg = [NSString stringWithFormat:@"⏳ 离线收益 Lv.%@（返还 %.0f%% · 上限 %.0f 小时）",
                   FmtInt(self.geneOfflineLevel), [self offlineReturnRate] * 100.0, [self offlineCapHours]];
            break;
        case 1:
            self.geneLevel += k;
            msg = [NSString stringWithFormat:@"🧬 基因强化 Lv.%@（全产出 +%@%%）", FmtInt(self.geneLevel), FmtInt(50 * self.geneLevel)];
            break;
        case 2:
            self.geneTapLevel += k;
            msg = [NSString stringWithFormat:@"👆 点击强化 Lv.%@（点击 +%@%%）", FmtInt(self.geneTapLevel), FmtInt(30 * self.geneTapLevel)];
            break;
        case 3:
            self.geneSporeLevel += k;
            msg = [NSString stringWithFormat:@"✨ 孢子亲和 Lv.%@（孢子 +%@%%）", FmtInt(self.geneSporeLevel), FmtInt(40 * self.geneSporeLevel)];
            break;
        case 4:
            self.geneAutoLevel += k;
            msg = [NSString stringWithFormat:@"🤖 自动触手 Lv.%@（每秒 %@ 次自动点击）", FmtInt(self.geneAutoLevel), FmtInt(self.geneAutoLevel)];
            break;
        case 5:
            self.geneAscendLevel += k;
            msg = [NSString stringWithFormat:@"🕊 飞升红利 Lv.%@（DNA +%@%%）", FmtInt(self.geneAscendLevel), FmtInt(20 * self.geneAscendLevel)];
            break;
        case 6:
            self.geneStartLevel += k;
            msg = [NSString stringWithFormat:@"🌱 起始遗泽 Lv.%@（每条产线起始 Lv.%@）", FmtInt(self.geneStartLevel), FmtInt([self geneStartLineLevel])];
            break;
        case 7:
            self.geneSporeRateLevel += k;
            msg = [NSString stringWithFormat:@"🌠 孢子之频 Lv.%@（间隔 %.0f%%）", FmtInt(self.geneSporeRateLevel), [self geneSporeRateMult] * 100];
            break;
        case 8:
            self.geneBossLevel += k;
            msg = [NSString stringWithFormat:@"⚔️ 试炼锋芒 Lv.%@（对守关者伤害 +%.0f%%）", FmtInt(self.geneBossLevel), 35.0 * self.geneBossLevel];
            break;
    }
    [self saveState];
    [self refreshGenePage];
    [self refreshAll];
    [self toast:msg];
}

- (void)refreshMutPage {
    if (self.mutPage.hidden) return;
    for (NSInteger i = 0; i < (NSInteger)self.mutCountLabels.count; i++) {
        NSInteger c = _muts[i];
        UILabel *l = self.mutCountLabels[i];
        l.text = c > 0 ? [NSString stringWithFormat:@"×%ld", (long)c] : @"未获得";
        l.textColor = c > 0 ? [UIColor colorWithRed:0.72 green:0.55 blue:1 alpha:1]
                            : [UIColor colorWithWhite:1 alpha:0.28];
        l.font = [UIFont monospacedDigitSystemFontOfSize:(c > 0 ? 17 : 12) weight:UIFontWeightBold];
    }
}

- (void)refreshRecordPage {
    if (self.recordPage.hidden) return;
    NSArray *vals = @[
        FmtNum(self.runEarned),
        FmtNum(self.totalEarned),
        [NSString stringWithFormat:@"%@/秒", FmtNum([self totalProd])],
        [NSString stringWithFormat:@"%@/次", FmtNum([self tapPower])],
        [NSString stringWithFormat:@"×%.1f", [self comboCap]],
        [NSString stringWithFormat:@"%@ 次", FmtInt(self.ascensions)],
        [NSString stringWithFormat:@"%@", FmtInt(self.dna)],
        [NSString stringWithFormat:@"%ld 条", (long)[self mutTotal]],
        StageName(self.stage),
        [NSString stringWithFormat:@"Lv.%@", FmtInt(self.ascensions)],
        [NSString stringWithFormat:@"产出×%.2f / 成本×%.2f", [self difficultyProdMult], [self difficultyCostMult]]
    ];
    for (NSInteger i = 0; i < (NSInteger)self.recordValueLabels.count && i < (NSInteger)vals.count; i++) {
        UILabel *l = self.recordValueLabels[i];
        l.text = vals[i];
    }
}


// ================= 图鉴 & 转生页面 =================
- (void)buildCodexPage {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    self.codexPage = [self makePageWithTitle:@"图鉴" subtitle:@"每解锁一个形态，永久 +2% 产出"];
    UIScrollView *sc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 112, W, H - 84 - 112)];
    sc.alwaysBounceVertical = YES;
    sc.showsVerticalScrollIndicator = NO;
    [self.codexPage addSubview:sc];

    self.codexNameLabels = [NSMutableArray array];
    self.codexLoreLabels = [NSMutableArray array];
    self.codexStatusLabels = [NSMutableArray array];
    self.codexCards = [NSMutableArray array];
    self.codexIconLabels = [NSMutableArray array];
    self.codexEraLabels = [NSMutableArray array];

    for (NSInteger i = 0; i < kStageCount; i++) {
        CGFloat y = 6 + i * 82;
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(14, y, W - 28, 74)];
        card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
        card.layer.cornerRadius = 14;
        [sc addSubview:card];
        [self.codexCards addObject:card];

        UILabel *ic = [[UILabel alloc] initWithFrame:CGRectMake(8, 17, 40, 40)];
        ic.text = StageEmoji(i);
        ic.font = [UIFont systemFontOfSize:22];
        ic.textAlignment = NSTextAlignmentCenter;
        ic.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
        ic.layer.cornerRadius = 10;
        ic.clipsToBounds = YES;
        [card addSubview:ic];
        [self.codexIconLabels addObject:ic];

        UILabel *nm = [[UILabel alloc] initWithFrame:CGRectMake(56, 10, W - 28 - 150, 20)];
        nm.text = StageName(i);
        nm.font = [UIFont boldSystemFontOfSize:14];
        nm.textColor = [UIColor whiteColor];
        [card addSubview:nm];
        [self.codexNameLabels addObject:nm];

        UILabel *era = [[UILabel alloc] initWithFrame:CGRectMake(56, 29, W - 28 - 150, 13)];
        era.text = [NSString stringWithFormat:@"第 %ld 形态 · %@", (long)(i + 1), StageEra(i)];
        era.font = [UIFont systemFontOfSize:9.5];
        era.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        [card addSubview:era];
        [self.codexEraLabels addObject:era];

        UILabel *lore = [[UILabel alloc] initWithFrame:CGRectMake(56, 44, W - 28 - 66, 26)];
        lore.font = [UIFont systemFontOfSize:9.5];
        lore.numberOfLines = 2;
        lore.textColor = [UIColor colorWithWhite:1 alpha:0.55];
        [card addSubview:lore];
        [self.codexLoreLabels addObject:lore];

        UILabel *st = [[UILabel alloc] initWithFrame:CGRectMake(W - 28 - 76, 10, 68, 18)];
        st.textAlignment = NSTextAlignmentRight;
        st.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightBold];
        [card addSubview:st];
        [self.codexStatusLabels addObject:st];
    }
    sc.contentSize = CGSizeMake(W, 6 + kStageCount * 82 + 20);
}

- (void)refreshCodexPage {
    if (self.codexPage.hidden) return;
    // 只亮出已抵达形态 + 之后两个预告，剩下全部是迷雾
    NSInteger revealTo = MIN(kStageCount - 1, self.maxStage + 2);
    for (NSInteger i = 0; i < (NSInteger)self.codexNameLabels.count && i < kStageCount; i++) {
        BOOL unlocked = (i <= self.maxStage);
        BOOL preview = (!unlocked && i <= revealTo);
        UILabel *nmL = self.codexNameLabels[i];
        UILabel *loreL = self.codexLoreLabels[i];
        UILabel *stL = self.codexStatusLabels[i];
        UIView *card = self.codexCards[i];
        UILabel *icL = self.codexIconLabels[i];
        UILabel *eraL = self.codexEraLabels[i];

        if (preview || unlocked) {
            card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
            icL.text = StageEmoji(i);
            nmL.text = StageName(i);
            eraL.text = [NSString stringWithFormat:@"第 %ld 形态 · %@", (long)(i + 1), StageEra(i)];
            eraL.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        } else {
            // 迷雾
            card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.02];
            icL.text = @"🌫";
            nmL.text = @"？？？";
            eraL.text = [NSString stringWithFormat:@"第 %ld 形态 · 迷雾之中", (long)(i + 1)];
            eraL.textColor = [UIColor colorWithWhite:1 alpha:0.18];
        }

        nmL.textColor = unlocked ? [UIColor whiteColor]
                     : (preview ? [UIColor colorWithWhite:1 alpha:0.55] : [UIColor colorWithWhite:1 alpha:0.22]);
        if (unlocked) {
            loreL.text = [NSString stringWithUTF8String:kLore[i]];
            loreL.textColor = [UIColor colorWithWhite:1 alpha:0.55];
            stL.text = [NSString stringWithFormat:@"+%ld%%", (long)(2 * (i + 1))];
            stL.textColor = [UIColor colorWithRed:0.55 green:0.95 blue:0.70 alpha:1];
        } else if (preview) {
            loreL.text = @"🔒 再前进一点就能看清它的轮廓";
            loreL.textColor = [UIColor colorWithWhite:1 alpha:0.3];
            stL.text = @"锁定";
            stL.textColor = [UIColor colorWithWhite:1 alpha:0.3];
        } else {
            loreL.text = @"🌫 迷雾尚未散开，继续进化才有可能窥见";
            loreL.textColor = [UIColor colorWithWhite:1 alpha:0.16];
            stL.text = @"迷雾";
            stL.textColor = [UIColor colorWithWhite:1 alpha:0.18];
        }
    }
}

static const char *kAchTitles[] = {"初次触摸", "完美连击", "深海远航", "进化狂潮",
                                  "守关者", "物种帝国", "恒星之火", "变异之海"};
static const char *kAchDescs[] = {"累计点击 500 次", "连击达到 100 层", "解锁 12 个形态",
                                  "飞升 3 次", "击败 3 个守关者", "任一产线持有 200 个",
                                  "能量突破 1.00e30", "变异累计 100 层"};
static const NSInteger kAchRewards[] = {1, 1, 1, 2, 2, 1, 2, 1};

- (void)buildRelicPage {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    self.relicPage = [self makePageWithTitle:@"转生" subtitle:@"飞升与成就获得遗物点 · 永久生效"];
    self.relicPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 116, W - 40, 22)];
    self.relicPointLabel.font = [UIFont boldSystemFontOfSize:14];
    self.relicPointLabel.textColor = [UIColor colorWithRed:0.78 green:0.62 blue:1.0 alpha:1];
    [self.relicPage addSubview:self.relicPointLabel];

    UIScrollView *sc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 146, W, H - 84 - 146)];
    sc.alwaysBounceVertical = YES;
    sc.showsVerticalScrollIndicator = NO;
    [self.relicPage addSubview:sc];

    self.relicBtns = [NSMutableArray array];
    for (NSInteger i = 0; i < kRelicCount; i++) {
        CGFloat y = i * 84;
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(14, y, W - 28, 76)];
        card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
        card.layer.cornerRadius = 14;
        [sc addSubview:card];

        UILabel *ic = [[UILabel alloc] initWithFrame:CGRectMake(8, 18, 40, 40)];
        ic.text = [NSString stringWithUTF8String:kRelics[i].icon];
        ic.font = [UIFont systemFontOfSize:22];
        ic.textAlignment = NSTextAlignmentCenter;
        ic.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
        ic.layer.cornerRadius = 10;
        ic.clipsToBounds = YES;
        [card addSubview:ic];

        UILabel *nm = [[UILabel alloc] initWithFrame:CGRectMake(56, 12, W - 28 - 140, 20)];
        nm.text = [NSString stringWithUTF8String:kRelics[i].name];
        nm.font = [UIFont boldSystemFontOfSize:15];
        nm.textColor = [UIColor whiteColor];
        [card addSubview:nm];

        UILabel *ds = [[UILabel alloc] initWithFrame:CGRectMake(56, 34, W - 28 - 140, 30)];
        ds.text = [NSString stringWithUTF8String:kRelics[i].desc];
        ds.font = [UIFont systemFontOfSize:10.5];
        ds.numberOfLines = 2;
        ds.textColor = [UIColor colorWithWhite:1 alpha:0.5];
        [card addSubview:ds];

        UIButton *buy = [UIButton buttonWithType:UIButtonTypeCustom];
        buy.frame = CGRectMake(W - 28 - 96, 22, 88, 32);
        buy.layer.cornerRadius = 16;
        buy.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [buy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buy.tag = i;
        [buy addTarget:self action:@selector(onRelicTap:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:buy];
        [self.relicBtns addObject:buy];
    }

    self.achTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, kRelicCount * 84 + 12, W - 40, 20)];
    self.achTitleLabel.text = @"🏆 成就（每项只达成一次）";
    self.achTitleLabel.font = [UIFont boldSystemFontOfSize:13];
    self.achTitleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75];
    [sc addSubview:self.achTitleLabel];

    self.achLabels = [NSMutableArray array];
    for (NSInteger i = 0; i < 8; i++) {
        CGFloat y = kRelicCount * 84 + 40 + i * 56;
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(14, y, W - 28, 50)];
        card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
        card.layer.cornerRadius = 12;
        [sc addSubview:card];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, W - 28 - 24, 36)];
        lb.font = [UIFont systemFontOfSize:11];
        lb.numberOfLines = 2;
        [card addSubview:lb];
        [self.achLabels addObject:lb];
    }
    sc.contentSize = CGSizeMake(W, kRelicCount * 84 + 40 + 8 * 56 + 20);
}

- (void)refreshRelicPage {
    if (self.relicPage.hidden) return;
    self.relicPointLabel.text = [NSString stringWithFormat:@"🔮 遗物点：%ld    飞升次数：%ld",
                                 (long)self.relicPoints, (long)self.ascensions];
    for (NSInteger i = 0; i < (NSInteger)self.relicBtns.count; i++) {
        UIButton *b = self.relicBtns[i];
        NSInteger lv = _relicLv[i];
        if (lv >= 20) {
            [b setTitle:[NSString stringWithFormat:@"Lv.%ld 满级", (long)lv] forState:UIControlStateNormal];
            b.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
        } else {
            NSInteger cost = [self relicCost:i];
            [b setTitle:[NSString stringWithFormat:@"Lv.%ld · %ld🔮", (long)lv, (long)cost] forState:UIControlStateNormal];
            b.backgroundColor = (self.relicPoints >= cost)
                ? [UIColor colorWithRed:0.45 green:0.35 blue:0.95 alpha:0.95]
                : [UIColor colorWithWhite:1 alpha:0.10];
        }
    }
    for (NSInteger i = 0; i < (NSInteger)self.achLabels.count; i++) {
        NSString *title = [NSString stringWithUTF8String:kAchTitles[i]];
        NSString *desc = [NSString stringWithUTF8String:kAchDescs[i]];
        NSInteger rw = kAchRewards[i];
        UILabel *l = self.achLabels[i];
        if (_achDone[i]) {
            l.text = [NSString stringWithFormat:@"🏆 %@ · 已完成   +%ld 🔮", title, (long)rw];
            l.textColor = [UIColor colorWithRed:0.95 green:0.80 blue:0.40 alpha:1];
        } else {
            l.text = [NSString stringWithFormat:@"%@ — %@   +%ld 🔮", title, desc, (long)rw];
            l.textColor = [UIColor colorWithWhite:1 alpha:0.45];
        }
    }
}

- (NSInteger)relicCost:(NSInteger)i {
    if (i < 0 || i >= kRelicCount) return 9999;
    double base = (double)kRelics[i].cost;
    return MAX(1, (NSInteger)ceil(base * pow(1.75, (double)_relicLv[i])));
}

- (void)onRelicTap:(UIButton *)b {
    NSInteger i = b.tag;
    if (i < 0 || i >= kRelicCount) return;
    if (_relicLv[i] >= 20) { [self toast:@"这件遗物已经满级了"]; return; }
    NSInteger cost = [self relicCost:i];
    if (self.relicPoints < cost) {
        [self toast:[NSString stringWithFormat:@"遗物点不足（需要 %ld 🔮）", (long)cost]];
        return;
    }
    self.relicPoints -= cost;
    _relicLv[i] += 1;
    [self saveState];
    [self refreshRelicPage];
    [self refreshAll];
    [self toast:[NSString stringWithFormat:@"🔮 遗物「%@」升至 Lv.%ld（- %ld🔮，剩余 %ld）",
               [NSString stringWithUTF8String:kRelics[i].name], (long)_relicLv[i], (long)cost, (long)self.relicPoints]];
    [self vibrateLight];
    [self sparkBurstAt:[self creatureCenterInView] color:[UIColor colorWithRed:0.75 green:0.55 blue:1 alpha:1] count:26 speed:200];
}

- (void)applyTheme:(BOOL)animated {
    UIColor *bg = StageBG(self.stage);
    CGFloat r, g, b, a;
    [bg getRed:&r green:&g blue:&b alpha:&a];
    UIColor *bottom = [UIColor colorWithRed:MIN(1, r*1.8) green:MIN(1, g*1.8) blue:MIN(1, b*1.8) alpha:1];
    NSArray *colors = @[(id)bg.CGColor, (id)bottom.CGColor];
    if (animated) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"colors"];
        anim.fromValue = self.bgLayer.colors;
        anim.toValue = colors;
        anim.duration = 0.8;
        [self.bgLayer addAnimation:anim forKey:@"theme"];
    }
    self.bgLayer.colors = colors;

    UIColor *accent = StageAccent(self.stage);
    self.ringFill.strokeColor = accent.CGColor;
    self.ringFill.shadowColor = accent.CGColor;
    self.ringFill.shadowRadius = 6;
    self.ringFill.shadowOpacity = 0.8;
    self.ringFill.shadowOffset = CGSizeZero;
    self.comboLabel.textColor = accent;

    self.aura1.strokeColor = [accent colorWithAlphaComponent:0.55].CGColor;
    self.aura2.strokeColor = [accent colorWithAlphaComponent:0.30].CGColor;
    self.creatureLabel.layer.shadowColor = accent.CGColor;
    self.creatureNameLabel.layer.shadowColor = accent.CGColor;
    self.creatureNameLabel.layer.shadowRadius = 8;
    self.creatureNameLabel.layer.shadowOpacity = 0.55;
    self.creatureNameLabel.layer.shadowOffset = CGSizeZero;
    self.energyRoller.glowColor = accent;

    self.auroraA.colors = @[(id)[accent colorWithAlphaComponent:0.34].CGColor,
                            (id)[[UIColor clearColor] CGColor]];
    self.auroraB.colors = @[(id)[accent colorWithAlphaComponent:0.22].CGColor,
                            (id)[[UIColor clearColor] CGColor]];

    if (self.ambientEmitter.emitterCells.count > 0) {
        CAEmitterCell *cell = self.ambientEmitter.emitterCells.firstObject;
        cell.color = accent.CGColor;
    }

    // 光环持续外扩
    [self.aura1 removeAnimationForKey:@"pulse"];
    [self.aura2 removeAnimationForKey:@"pulse"];
    CABasicAnimation *p1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    p1.fromValue = @0.92; p1.toValue = @1.16;
    CABasicAnimation *f1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    f1.fromValue = @0.55; f1.toValue = @0.0;
    CAAnimationGroup *g1 = [CAAnimationGroup animation];
    g1.animations = @[p1, f1]; g1.duration = 2.4; g1.repeatCount = HUGE_VALF;
    [self.aura1 addAnimation:g1 forKey:@"pulse"];

    CABasicAnimation *p2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    p2.fromValue = @0.92; p2.toValue = @1.22;
    CABasicAnimation *f2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    f2.fromValue = @0.35; f2.toValue = @0.0;
    CAAnimationGroup *g2 = [CAAnimationGroup animation];
    g2.animations = @[p2, f2]; g2.duration = 2.4; g2.beginTime = CACurrentMediaTime() + 1.2; g2.repeatCount = HUGE_VALF;
    [self.aura2 addAnimation:g2 forKey:@"pulse"];
}

- (RollLabel *)attachRollLabelToButton:(UIButton *)btn {
    [btn setTitle:@"" forState:UIControlStateNormal];
    [btn setTitle:@"" forState:UIControlStateDisabled];
    RollLabel *l = [[RollLabel alloc] initWithFrame:CGRectMake(2, 1, btn.bounds.size.width - 4, btn.bounds.size.height - 2)];
    l.textAlignment = NSTextAlignmentCenter;
    l.userInteractionEnabled = NO;
    l.font = btn.titleLabel.font ?: [UIFont boldSystemFontOfSize:15];
    l.textColor = [UIColor whiteColor];
    l.adjustsFontSizeToFitWidth = YES;
    l.minimumScaleFactor = 0.55;
    [btn addSubview:l];
    return l;
}

// ================= 特效 =================
- (UIImage *)sparkDotImage {
    if (self.sparkDot) return self.sparkDot;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(16, 16), NO, 0);
    for (NSInteger i = 10; i >= 1; i--) {
        CGFloat a = 0.10 + 0.06 * (CGFloat)(10 - i);
        [[UIColor colorWithWhite:1 alpha:a] setFill];
        CGFloat inset = 8 - (CGFloat)i * 0.7;
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(inset, inset, 16 - inset * 2, 16 - inset * 2)] fill];
    }
    self.sparkDot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return self.sparkDot;
}

- (void)setupAmbientParticles {
    CAEmitterLayer *em = [CAEmitterLayer layer];
    em.emitterPosition = CGPointMake(CGRectGetMidX(self.creatureArea.frame), CGRectGetMidY(self.creatureArea.frame) + 30);
    em.emitterSize = CGSizeMake(self.view.bounds.size.width - 60, 30);
    em.emitterShape = kCAEmitterLayerRectangle;
    em.emitterMode = kCAEmitterLayerVolume;

    CAEmitterCell *c = [CAEmitterCell emitterCell];
    c.contents = (id)[self sparkDotImage].CGImage;
    c.birthRate = 3.0;
    c.lifetime = 5.5;
    c.lifetimeRange = 1.5;
    c.velocity = 16;
    c.velocityRange = 10;
    c.emissionRange = M_PI * 0.9;
    c.yAcceleration = -8;
    c.scale = 0.28;
    c.scaleRange = 0.12;
    c.alphaSpeed = -0.16;
    c.color = StageAccent(self.stage).CGColor;
    em.emitterCells = @[c];
    [self.view.layer insertSublayer:em atIndex:1];
    self.ambientEmitter = em;
}

- (void)rippleAt:(CGPoint)pt color:(UIColor *)color radius:(CGFloat)radius {
    CAShapeLayer *ring = [CAShapeLayer layer];
    ring.path = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:radius
                                               startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
    ring.strokeColor = color.CGColor;
    ring.fillColor = [UIColor clearColor].CGColor;
    ring.lineWidth = 2.0;
    ring.position = pt;
    ring.opacity = 0;
    [self.view.layer addSublayer:ring];

    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @0.18; scale.toValue = @1.0;
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @0.85; fade.toValue = @0.0;
    CAAnimationGroup *g = [CAAnimationGroup animation];
    g.animations = @[scale, fade];
    g.duration = 0.45;
    g.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [ring addAnimation:g forKey:@"ripple"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ring removeFromSuperlayer];
    });
}

- (void)sparkBurstAt:(CGPoint)pt color:(UIColor *)color count:(NSInteger)count speed:(CGFloat)speed {
    CAEmitterLayer *em = [CAEmitterLayer layer];
    em.emitterPosition = pt;
    em.emitterSize = CGSizeMake(6, 6);
    em.emitterShape = kCAEmitterLayerPoint;
    em.emitterMode = kCAEmitterLayerPoints;

    CAEmitterCell *c = [CAEmitterCell emitterCell];
    c.contents = (id)[self sparkDotImage].CGImage;
    c.birthRate = (float)count * 26.0f;
    c.lifetime = 0.55;
    c.lifetimeRange = 0.18;
    c.velocity = speed;
    c.velocityRange = speed * 0.55;
    c.emissionRange = M_PI * 2;
    c.scale = 0.42;
    c.scaleRange = 0.18;
    c.scaleSpeed = -0.55;
    c.alphaSpeed = -2.0;
    c.spin = 0.6;
    c.color = color.CGColor;
    em.emitterCells = @[c];
    [self.view.layer addSublayer:em];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        em.birthRate = 0;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.95 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [em removeFromSuperlayer];
    });
}

- (void)shockwaveAt:(CGPoint)pt color:(UIColor *)color maxRadius:(CGFloat)radius {
    CAShapeLayer *ring = [CAShapeLayer layer];
    ring.path = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:radius
                                               startAngle:0 endAngle:M_PI * 2 clockwise:YES].CGPath;
    ring.strokeColor = color.CGColor;
    ring.fillColor = [UIColor clearColor].CGColor;
    ring.lineWidth = 5;
    ring.position = pt;
    ring.opacity = 0;
    [self.view.layer addSublayer:ring];

    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @0.05; scale.toValue = @1.0;
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @0.9; fade.toValue = @0.0;
    CABasicAnimation *thin = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    thin.fromValue = @8; thin.toValue = @1;
    CAAnimationGroup *g = [CAAnimationGroup animation];
    g.animations = @[scale, fade, thin];
    g.duration = 0.6;
    g.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [ring addAnimation:g forKey:@"shock"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ring removeFromSuperlayer];
    });
}

- (void)flashScreen:(UIColor *)color alpha:(CGFloat)alpha {
    UIView *flash = [[UIView alloc] initWithFrame:self.view.bounds];
    flash.backgroundColor = color;
    flash.alpha = 0;
    flash.userInteractionEnabled = NO;
    flash.tag = 9902;
    [self.view addSubview:flash];
    [UIView animateWithDuration:0.10 animations:^{ flash.alpha = alpha; } completion:^(BOOL f) {
        [UIView animateWithDuration:0.32 animations:^{ flash.alpha = 0; } completion:^(BOOL f2) {
            [flash removeFromSuperview];
        }];
    }];
}

- (void)shakeScreen:(CGFloat)amp {
    CAKeyframeAnimation *a = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    a.values = @[@0, @(-amp), @(amp), @(-amp * 0.7), @(amp * 0.6), @(-amp * 0.35), @0];
    a.duration = 0.30;
    a.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.view.layer addAnimation:a forKey:@"screenShake"];
}

- (void)popCreature {
    CABasicAnimation *pop = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pop.fromValue = @1.0; pop.toValue = @1.18;
    pop.duration = 0.12; pop.autoreverses = YES;
    pop.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.creatureLabel.layer addAnimation:pop forKey:@"pop"];
}

// ================= 列表 =================
- (void)rebuildRows {
    for (GenRow *r in self.rows) [r removeFromSuperview];
    [self.rows removeAllObjects];

    CGFloat rowW = self.listScroll.bounds.size.width;
    CGFloat y = 0;
    __weak typeof(self) weakSelf = self;
    for (NSInteger i = 0; i <= self.stage && i < kStageCount; i++) {
        GenRow *row = [[GenRow alloc] initWithFrame:CGRectMake(0, y, rowW, 76) stage:i];
        row.onTapBlock = ^(NSInteger idx) {
            [weakSelf vibrateLight];
            [weakSelf buyRow:idx];
        };
        [self.listScroll addSubview:row];
        [self.rows addObject:row];
        y += 84;
    }
    if (self.stage < kStageCount - 1) {
        UIView *locked = [[UIView alloc] initWithFrame:CGRectMake(0, y, rowW, 76)];
        locked.backgroundColor = [UIColor colorWithWhite:1 alpha:0.03];
        locked.layer.cornerRadius = 16;

        UIView *iconBox = [[UIView alloc] initWithFrame:CGRectMake(10, 14, 44, 44)];
        iconBox.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
        iconBox.layer.cornerRadius = 11;
        [locked addSubview:iconBox];
        UILabel *icon = [[UILabel alloc] initWithFrame:iconBox.bounds];
        icon.text = @"🔒";
        icon.font = [UIFont systemFontOfSize:22];
        icon.textAlignment = NSTextAlignmentCenter;
        [iconBox addSubview:icon];

        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(66, 20, rowW - 120, 20)];
        name.text = @"???";
        name.font = [UIFont boldSystemFontOfSize:15];
        name.textColor = [UIColor colorWithWhite:1 alpha:0.3];
        [locked addSubview:name];
        RollLabel *sub = [[RollLabel alloc] initWithFrame:CGRectMake(66, 41, rowW - 120, 16)];
        sub.text = @"进化后解锁";
        sub.font = [UIFont systemFontOfSize:10.5];
        sub.textColor = [UIColor colorWithWhite:1 alpha:0.25];
        [locked addSubview:sub];
        UILabel *dash = [[UILabel alloc] initWithFrame:CGRectMake(rowW - 74, 26, 60, 22)];
        dash.text = @"—";
        dash.textColor = [UIColor colorWithWhite:1 alpha:0.3];
        dash.textAlignment = NSTextAlignmentRight;
        dash.font = [UIFont boldSystemFontOfSize:16];
        [locked addSubview:dash];

        [self.listScroll addSubview:locked];
        [self.rows addObject:(GenRow *)locked];
        y += 84;
    }
    self.listScroll.contentSize = CGSizeMake(rowW, y);
    [self attachHapticsToView:self.listScroll];
    [self refreshRows];
}

- (NSInteger)buyCountForRow:(NSInteger)i {
    NSInteger owned = _counts[i];
    switch (self.buyQtyMode) {
        case 0: return 1;
        case 1: return 10;
        case 2: return 100;
        default: {
            NSInteger n = [self maxAffordableFor:i owned:owned];
            return MAX(1, n);
        }
    }
}

// 在当前能量下：把能买的都买进某一条产线，哪一条带来的新增产出最多（按每点能量的效率排）
- (NSInteger)bestRowIndex {
    NSInteger best = -1;
    double bestRoi = 0;
    for (NSInteger i = 0; i <= self.stage && i < kStageCount; i++) {
        NSInteger owned = _counts[i];
        double cost1 = [self costFor:i owned:owned count:1];
        if (cost1 <= 0 || cost1 > self.energy) continue;   // 现在买不起就别推荐
        NSInteger n = [self maxAffordableFor:i owned:owned];
        if (n < 1) continue;
        double costN = [self costFor:i owned:owned count:n];
        if (costN <= 0) continue;
        double unit = BaseProd(i) * [self geneMult] * [self boostMult] * [self mutProdMult];
        double delta = unit * ((double)(owned + n) * MilestoneMult(owned + n)
                               - (double)owned * MilestoneMult(owned));
        double roi = delta / costN;
        if (roi > bestRoi) { bestRoi = roi; best = i; }
    }
    return best;
}

- (void)refreshBestBadge {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - self.lastBestAt < 0.4) return;
    self.lastBestAt = now;
    NSInteger best = [self bestRowIndex];
    for (GenRow *row in self.rows) {
        if (![row isKindOfClass:[GenRow class]] || row.bestLabel == nil) continue;
        BOOL isBest = (row.stageIndex == best);
        row.bestLabel.hidden = !isBest;
        if (!isBest) continue;
        [row.bestLabel sizeToFit];
        CGFloat nameW = [row.nameLabel.text sizeWithAttributes:@{NSFontAttributeName: row.nameLabel.font}].width;
        CGFloat bx = CGRectGetMinX(row.nameLabel.frame) + nameW + 6;
        row.bestLabel.frame = CGRectMake(bx,
                                         CGRectGetMinY(row.nameLabel.frame) + (row.nameLabel.bounds.size.height - row.bestLabel.bounds.size.height) / 2.0,
                                         row.bestLabel.bounds.size.width,
                                         row.bestLabel.bounds.size.height);
    }
}

- (void)refreshRows {
    for (GenRow *row in self.rows) {
        if (![row isKindOfClass:[GenRow class]] || row.costLabel == nil) continue;
        NSInteger i = row.stageIndex;
        NSInteger owned = _counts[i];
        double each = BaseProd(i) * MilestoneMult(owned) * [self geneMult] * [self boostMult] * [self mutProdMult];
        double total = each * owned;
        row.countLabel.text = FmtInt(owned);

        NSInteger next = NextMilestone(owned);
        NSInteger prevM = PrevMilestone(owned);

        CGFloat prog = 1.0;
        NSString *mText;
        if (next == 0) {
            mText = [NSString stringWithFormat:@"里程碑已满 ×%@", FmtInt((NSInteger)pow(2.0, (double)kMileCount))];
        } else {
            prog = (CGFloat)(owned - prevM) / (CGFloat)(next - prevM);
            prog = MAX(0.0, MIN(1.0, prog));
            mText = [NSString stringWithFormat:@"达到 %@ 个 产出×2", FmtInt(next)];
        }
        row.subLabel.text = owned > 0
            ? [NSString stringWithFormat:@"%@/秒", FmtNum(total)]
            : [NSString stringWithFormat:@"每个 %@/秒", FmtNum(each)];
        row.milestoneLabel.text = mText;
        CGRect bf = row.barFill.frame;
        bf.size.width = row.barTrack.bounds.size.width * prog;
        row.barFill.frame = bf;
        row.barFill.backgroundColor = (next == 0)
            ? [UIColor colorWithRed:0.85 green:0.7 blue:0.25 alpha:1]
            : [UIColor colorWithRed:0.72 green:0.45 blue:1 alpha:1];

        NSInteger k = [self buyCountForRow:i];
        // 价格仍按当前批量总价；进度条改按"买 1 个"的价格算
        double cost = [self costFor:i owned:owned count:k];
        double cost1 = [self costFor:i owned:owned count:1];
        BOOL can = self.energy >= cost;
        row.costLabel.text = [NSString stringWithFormat:@"⚡ %@", FmtNum(cost)];
        row.costLabel.textColor = can
            ? [UIColor colorWithRed:0.35 green:0.95 blue:0.55 alpha:1]
            : [UIColor colorWithWhite:1 alpha:0.4];

        // 整卡攒钱进度（买 1 个）
        CGFloat cp = cost1 > 0 ? (CGFloat)(self.energy / cost1) : 1.0;
        cp = MAX(0.0, MIN(1.0, cp));
        CGFloat rowW = row.bounds.size.width;
        row.cardFill.frame = CGRectMake(0, 0, rowW * cp, row.bounds.size.height);
        if (self.energy >= cost1) {
            row.cardFill.backgroundColor = [UIColor colorWithRed:0.35 green:0.95 blue:0.55 alpha:0.16];
        } else {
            UIColor *accent = StageAccent(self.stage);
            CGFloat ar = 0, ag = 0, ab = 0, aa = 0;
            [accent getRed:&ar green:&ag blue:&ab alpha:&aa];
            row.cardFill.backgroundColor = [UIColor colorWithRed:ar green:ag blue:ab alpha:0.20];
        }
        row.cardFill.hidden = (cp < 0.02);

        if (self.energy >= cost1) {
            NSInteger n = [self maxAffordableFor:i owned:owned];
            row.hintLabel.text = [NSString stringWithFormat:@"现可买 ×%@", FmtInt(MAX(1, n))];
        } else {
            row.hintLabel.text = @"";
        }
        row.hintLabel.textColor = (self.energy >= cost1)
            ? [UIColor colorWithRed:0.35 green:0.95 blue:0.55 alpha:0.85]
            : [UIColor colorWithWhite:1 alpha:0.45];
    }
    [self refreshBestBadge];
}

// ================= 刷新 =================
- (void)refreshAll {
    self.creatureNameLabel.text = StageName(self.stage);
    NSString *era = StageEra(self.stage);
    if ([self mutTotal] > 0) era = [NSString stringWithFormat:@"%@ · 变异 %ld", era, (long)[self mutTotal]];
    if (self.eventKind > 0) {
        NSTimeInterval left = self.eventEnd - [[NSDate date] timeIntervalSince1970];
        if (left > 0) era = [NSString stringWithFormat:@"%@ · %@ %lds", era, [self eventTitle:self.eventKind], (long)ceil(left)];
    }
    self.eraLabel.text = era;
    self.creatureLabel.text = StageEmoji(self.stage);
    self.dnaRoll.text = [NSString stringWithFormat:@"🧬 %@", FmtInt(self.dna)];

    for (NSInteger i = 0; i < 4; i++) {
        UIButton *b = self.qtyBtns[i];
        BOOL sel = (i == self.buyQtyMode);
        b.backgroundColor = [UIColor colorWithWhite:1 alpha:sel ? 0.12 : 0.04];
        b.layer.borderWidth = sel ? 1.5 : 0;
        b.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.85].CGColor;
        [b setTitleColor:[UIColor colorWithWhite:1 alpha:sel ? 1.0 : 0.55] forState:UIControlStateNormal];
    }
    [self refreshDynamic];
    [self refreshRows];
    [self refreshGenePage];
    [self refreshMutPage];
    [self refreshRecordPage];
}

// 4K 母版按需降采样到 1600px 再上屏，避免 4096×4096 解码占 67MB 内存
- (UIImage *)artImageNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    if (path == nil) path = [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
    if (path == nil) return [UIImage imageNamed:name];
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (src == NULL) return [UIImage imageWithContentsOfFile:path];
    NSDictionary *opts = @{(id)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
                           (id)kCGImageSourceThumbnailMaxPixelSize: @1600,
                           (id)kCGImageSourceCreateThumbnailWithTransform: @YES};
    CGImageRef thumb = CGImageSourceCreateThumbnailAtIndex(src, 0, (__bridge CFDictionaryRef)opts);
    CFRelease(src);
    if (thumb == NULL) return [UIImage imageWithContentsOfFile:path];
    UIImage *img = [UIImage imageWithCGImage:thumb];
    CGImageRelease(thumb);
    return img;
}

- (NSInteger)eraIndexForStage:(NSInteger)i {
    if (i <= 3)  return 0;
    if (i <= 9)  return 1;
    if (i <= 13) return 2;
    if (i <= 15) return 3;
    if (i <= 23) return 4;
    if (i <= 28) return 5;
    if (i <= 33) return 6;
    if (i <= 38) return 7;
    if (i <= 43) return 8;
    return 9;
}

// 每个形态对应的背景美术资源
- (NSString *)artAssetForStage:(NSInteger)i {
    if (i <= 3)  return @"art_origin";
    if (i <= 9)  return @"art_paleo";
    if (i <= 13) return @"art_meso";
    if (i <= 15) return @"art_civ";
    if (i <= 23) return @"art_star";
    if (i <= 28) return @"art_quantum";
    if (i <= 35) return @"art_multi";
    return @"art_void";
}

- (void)updateMusicForEra:(NSInteger)era {
    if (!self.musicOn) return;
    if (self.musicEra == era && self.musicA.isPlaying) return;
    NSString *base = @[@"art_origin", @"art_paleo", @"art_meso", @"art_civ",
                       @"art_star", @"art_quantum", @"art_multi",
                       @"art_beyond", @"art_void", @"art_epilogue"][era];
    NSString *path = [[NSBundle mainBundle] pathForResource:base ofType:@"m4a"];
    if (path == nil) path = [[NSBundle mainBundle] pathForResource:base ofType:@"wav"];
    if (path == nil) return;
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAudioPlayer *next = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    if (next == nil) return;
    next.numberOfLoops = -1;
    next.volume = 0;
    [next prepareToPlay];
    [next play];

    AVAudioPlayer *old = self.musicA;
    self.musicA = next;
    self.musicEra = era;
    // 2.6 秒交叉淡化
    for (NSInteger step = 1; step <= 26; step++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(step * 0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            next.volume = 0.55 * (float)step / 26.0f;
            if (old) old.volume = 0.55 * (1.0f - (float)step / 26.0f);
            if (step == 26 && old) { [old stop]; }
        });
    }
}

- (void)onToggleMusic {
    self.musicOn = !self.musicOn;
    if (self.musicOn) {
        self.musicEra = -1;
        [self updateMusicForEra:[self eraIndexForStage:self.stage]];
        [self.musicBtn setTitle:@"🔊" forState:UIControlStateNormal];
        self.musicBtn.alpha = 1.0;
        [self toast:@"🔊 配乐已开启"];
    } else {
        for (AVAudioPlayer *p in @[self.musicA]) { [p stop]; }
        self.musicA = nil;
        [self.musicBtn setTitle:@"🔇" forState:UIControlStateNormal];
        self.musicBtn.alpha = 0.62;
        [self toast:@"🔇 配乐已静音"];
    }
}

- (void)updateArtForStage:(NSInteger)i {
    if (self.artBackdrop != nil && self.artShown == i) return;
    BOOL first = (self.artBackdrop == nil);
    NSString *artName = [self artAssetForStage:i];
    UIImage *img = [self artImageNamed:artName];
    self.artShown = i;
    if (first) {
        self.artBackdrop = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.artBackdrop.contentMode = UIViewContentModeScaleAspectFill;
        self.artBackdrop.clipsToBounds = YES;
        self.artBackdrop.alpha = 0;
        self.artBackdrop.userInteractionEnabled = NO;
        self.artBackdrop.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.artBackdrop];
        // 背景渐变/暗角/极光都是直接加在 view.layer 上的子层，
        // 插到 subview index 0 反而会落到它们下面被完全盖住，这里显式插到暗角层之上
        if (self.vignette != nil) {
            [self.view.layer insertSublayer:self.artBackdrop.layer above:self.vignette];
        } else {
            [self.view.layer insertSublayer:self.artBackdrop.layer atIndex:0];
        }

        self.artScrim = [[UIView alloc] initWithFrame:self.view.bounds];
        self.artScrim.backgroundColor = [UIColor colorWithWhite:0 alpha:0.52];
        self.artScrim.userInteractionEnabled = NO;
        self.artScrim.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.artScrim];
        [self.view.layer insertSublayer:self.artScrim.layer above:self.artBackdrop.layer];
    }
    if (first) {
        self.artBackdrop.image = img;
        [UIView animateWithDuration:1.1 animations:^{ self.artBackdrop.alpha = 0.62; }];
    } else {
        [UIView transitionWithView:self.artBackdrop duration:0.9
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{ self.artBackdrop.image = img; }
                         completion:nil];
    }
}

- (void)refreshDynamic {
    [self updateArtForStage:self.stage];
    [self updateMusicForEra:[self eraIndexForStage:self.stage]];
    // 顶部数字由 CADisplayLink 平滑驱动，这里不再直接赋值，避免跳动
    self.autoLabel.text = [NSString stringWithFormat:@"💧 自动 +%@/秒%@", FmtNum([self totalProd]),
                           self.aiOn ? @" · 🤖 托管中" : @""];
    [self updateSporePill];
    self.rateLabel.text = [NSString stringWithFormat:@"👆 点击 %@/次    ⏳ 离线收益 %@",
                           FmtNum([self tapPower]),
                           ([self geneEffLevel:0] > 0)
                               ? [NSString stringWithFormat:@"Lv.%@（%.0f%%/%.0fh）", FmtInt(self.geneOfflineLevel),
                                  [self offlineReturnRate] * 100.0, [self offlineCapHours]]
                               : @"待DNA解锁"];

    // 连击
    if (self.combo > 1.05) {
        self.comboLabel.font = [UIFont boldSystemFontOfSize:16];
        self.comboLabel.text = [NSString stringWithFormat:@"×%.1f", self.combo];
        self.comboLabel.alpha = 1;
    } else {
        self.comboLabel.font = [UIFont systemFontOfSize:12];
        self.comboLabel.text = @"点击生物获取能量";
        self.comboLabel.alpha = 0.3;
    }

    // 进化环 + 按钮
    if (self.stage < kStageCount - 1) {
        double cost = kEvolveCost[self.stage + 1] * kEvolveMult * [self difficultyEvoMult] * [self evoGeneTax] * [self autoEvoMult];
        if ([self needsBossForStage:self.stage + 1]) {
            self.ringFill.strokeEnd = 1.0;
            NSInteger fails = _bossFails[self.stage + 1];
            if (fails >= 2) {
                self.evolveRoll.text = [NSString stringWithFormat:@"⛔️ 试炼封锁 · 需飞升重开"];
                self.evolveBtn.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1];
                self.evolveBtn.alpha = 0.75;
            } else {
                self.evolveRoll.text = [NSString stringWithFormat:@"⚔️ 试炼 · 守关者 %@（剩 %ld 次）",
                                        StageName(self.stage + 1), (long)(2 - fails)];
                self.evolveBtn.backgroundColor = [UIColor colorWithRed:0.62 green:0.16 blue:0.20 alpha:1];
                self.evolveBtn.alpha = 1;
            }
            self.energyRoller.textColor = [UIColor whiteColor];
        } else {
        self.ringFill.strokeEnd = MIN(1.0, self.energy / cost);
        BOOL can = self.energy >= cost;
        NSInteger pr = [self eventPressure];
        self.evolveRoll.text = (pr > 0)
            ? [NSString stringWithFormat:@"进化 %@ %@ · ⚡ %@ · 压力×%.1f", StageEmoji(self.stage + 1), StageName(self.stage + 1), FmtNum(cost), pow(1.14, (double)pr)]
            : [NSString stringWithFormat:@"进化 %@ %@   ·   ⚡ %@", StageEmoji(self.stage + 1), StageName(self.stage + 1), FmtNum(cost)];
        self.evolveBtn.backgroundColor = can
            ? [UIColor colorWithRed:0.16 green:0.62 blue:0.36 alpha:1]
            : [UIColor colorWithWhite:1 alpha:0.09];
        self.evolveBtn.alpha = can ? 1 : 0.8;
        }
    } else {
        self.ringFill.strokeEnd = 1;
        self.evolveRoll.text = @"🌌 已是最终形态";
        self.evolveBtn.backgroundColor = [UIColor colorWithRed:0.4 green:0.25 blue:0.6 alpha:0.8];
        self.evolveBtn.alpha = 1;
    }

    // 飞升
    double th = [self ascThreshold];
    CGFloat ratio = MIN(1.0, self.runEarned / th);
    NSInteger gain = [self ascDNAGain];
    CGRect ff = self.ascFill.frame;
    ff.size.width = self.ascTrack.bounds.size.width * ratio;
    self.ascFill.frame = ff;
    self.ascPctLabel.text = [NSString stringWithFormat:@"%.0f%%", ratio * 100];
    double tax = [self ascGeneTax];
    NSString *ascBase = (self.ascensions == 0)
        ? [NSString stringWithFormat:@"%@ 时首次飞升", FmtNum(th)]
        : [NSString stringWithFormat:@"第%ld次飞升 %@", (long)(self.ascensions + 1), FmtNum(th)];
    NSString *ascText = (tax > 1.02) ? [ascBase stringByAppendingFormat:@" · 基因×%.1f", tax] : ascBase;
    if (self.autoDiff > 0)
        ascText = [ascText stringByAppendingFormat:@" · 自适应×%.1f", [self autoAscMult]];
    self.ascLabel.text = ascText;
    if (gain > 0 && !self.ascendGlowOn) {
        self.ascendGlowOn = YES;
        self.ascendBtn.layer.shadowColor = [UIColor colorWithRed:0.78 green:0.62 blue:1.0 alpha:1].CGColor;
        self.ascendBtn.layer.shadowRadius = 14;
        self.ascendBtn.layer.shadowOpacity = 0.85;
        self.ascendBtn.layer.shadowOffset = CGSizeZero;
        CABasicAnimation *glow = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        glow.fromValue = @0.35; glow.toValue = @0.95;
        glow.duration = 1.1; glow.autoreverses = YES; glow.repeatCount = HUGE_VALF;
        [self.ascendBtn.layer addAnimation:glow forKey:@"glow"];
    } else if (gain <= 0 && self.ascendGlowOn) {
        self.ascendGlowOn = NO;
        [self.ascendBtn.layer removeAnimationForKey:@"glow"];
        self.ascendBtn.layer.shadowOpacity = 0;
    }
    if (gain > 0) {
        self.ascendBtn.enabled = YES;
        self.ascendBtn.backgroundColor = [UIColor colorWithRed:0.72 green:0.6 blue:1 alpha:0.95];
        self.ascendRoll.text = [NSString stringWithFormat:@"🕊 飞升  ·  +%@ DNA", FmtInt(gain)];
        self.ascendRoll.textColor = [UIColor colorWithWhite:0.10 alpha:1];
    } else {
        self.ascendBtn.enabled = NO;
        self.ascendBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
        self.ascendRoll.text = [NSString stringWithFormat:@"🕊 飞升（还差 ⚡%@）", FmtNum(th - self.runEarned)];
        self.ascendRoll.textColor = [UIColor colorWithWhite:1 alpha:0.45];
    }

}

- (NSString *)shortTime:(NSTimeInterval)sec {
    if (sec >= 3600) return [NSString stringWithFormat:@"%ldh%02ldm", (long)(sec / 3600), (long)(((long)sec % 3600) / 60)];
    return [NSString stringWithFormat:@"%ldm%02lds", (long)(sec / 60), (long)((long)sec % 60)];
}

// ================= 主循环 =================
- (void)floatInCreature:(NSString *)text color:(UIColor *)color font:(UIFont *)font offsetY:(CGFloat)dy {
    if (self.currentTab != 0 || self.view.window == nil) return;
    CGFloat W = self.creatureArea.bounds.size.width;
    CGFloat midY = CGRectGetMidY(self.creatureArea.bounds);
    UILabel *fly = [[UILabel alloc] init];
    fly.text = text;
    fly.font = font;
    fly.textColor = color;
    fly.layer.shadowColor = [UIColor blackColor].CGColor;
    fly.layer.shadowOpacity = 0.5;
    fly.layer.shadowRadius = 2.5;
    fly.layer.shadowOffset = CGSizeZero;
    [fly sizeToFit];
    CGFloat fx = W / 2 + (CGFloat)((int)arc4random_uniform(30) - 15) - fly.bounds.size.width / 2;
    CGFloat fy = midY - 6 + dy;
    fly.frame = CGRectMake(fx, fy, fly.bounds.size.width, fly.bounds.size.height);
    [self.creatureArea addSubview:fly];
    [UIView animateWithDuration:0.95 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        fly.frame = CGRectMake(fx, fy - 66, fly.bounds.size.width, fly.bounds.size.height);
        fly.alpha = 0;
    } completion:^(BOOL finished) { [fly removeFromSuperview]; }];
}

// 右边缘收益播报：不遮挡中央生物，持续显示最新一条自动收益
- (UILabel *)ensureFeed:(NSInteger)slot offsetY:(CGFloat)dy {
    CGFloat W = self.creatureArea.bounds.size.width;
    CGFloat midY = CGRectGetMidY(self.creatureArea.bounds);
    UILabel *lab = (slot == 0) ? self.autoProdFeed : self.autoTapFeed;
    if (lab == nil) {
        lab = [[RollLabel alloc] init];
        lab.backgroundColor = [UIColor colorWithWhite:0 alpha:0.42];
        lab.layer.cornerRadius = 7;
        lab.clipsToBounds = YES;
        lab.userInteractionEnabled = NO;
        [self.creatureArea addSubview:lab];
        if (slot == 0) self.autoProdFeed = lab;
        else self.autoTapFeed = lab;
    }
    lab.hidden = NO;
    [lab sizeToFit];
    CGFloat w = lab.bounds.size.width + 14;
    CGFloat h = lab.bounds.size.height + 5;
    lab.frame = CGRectMake(W - 14 - w, midY + dy, w, h);
    return lab;
}

- (void)clearFeeds {
    if (self.autoProdFeed) { self.autoProdFeed.text = nil; self.autoProdFeed.hidden = YES; }
    if (self.autoTapFeed)  { self.autoTapFeed.text = nil;  self.autoTapFeed.hidden = YES; }
}

- (void)feedPulse:(UILabel *)lab {
    lab.alpha = 0.55;
    [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{ lab.alpha = 1.0; } completion:nil];
}


// ================= 守关者 · 试炼 =================
- (BOOL)needsBossForStage:(NSInteger)t {
    if (t <= 0 || t >= kStageCount) return NO;
    // 守关者出现间隔随形态推进收紧：6 级一次 → 4 级 → 3 级 → 2 级
    NSInteger gap = 6;
    if (t >= 48) gap = 2;
    else if (t >= 30) gap = 3;
    else if (t >= 15) gap = 4;
    if (t % gap != 0) return NO;
    return !_bossDoneRound[t];
}

- (NSInteger)bossCount {
    NSInteger c = 0;
    for (NSInteger i = 0; i < kStageCount; i++) if (_bossDone[i]) c++;
    return c;
}

- (void)startBossForStage:(NSInteger)t {
    if (self.bossOverlay != nil) return;
    CGFloat W = self.view.bounds.size.width, H = self.view.bounds.size.height;
    UIView *ov = [[UIView alloc] initWithFrame:self.view.bounds];
    ov.backgroundColor = [UIColor colorWithWhite:0 alpha:0.88];
    ov.tag = 9910;
    self.bossOverlay = ov;
    [self.view addSubview:ov];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, H * 0.16, W, 20)];
    title.text = [NSString stringWithFormat:@"⚔️ 第 %ld 道试炼 · 守关者", (long)(t / 6)];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:14];
    title.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    [ov addSubview:title];

    self.bossEmojiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, H * 0.19, W, 110)];
    self.bossEmojiLabel.text = StageEmoji(t);
    self.bossEmojiLabel.textAlignment = NSTextAlignmentCenter;
    self.bossEmojiLabel.font = [UIFont systemFontOfSize:72];
    self.bossEmojiLabel.layer.shadowColor = StageAccent(t).CGColor;
    self.bossEmojiLabel.layer.shadowRadius = 18;
    self.bossEmojiLabel.layer.shadowOpacity = 0.8;
    self.bossEmojiLabel.layer.shadowOffset = CGSizeZero;
    [ov addSubview:self.bossEmojiLabel];

    self.bossNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, H * 0.35, W, 26)];
    self.bossNameLabel.text = [NSString stringWithFormat:@"%@ 的化身", StageName(t)];
    self.bossNameLabel.textAlignment = NSTextAlignmentCenter;
    self.bossNameLabel.font = [UIFont boldSystemFontOfSize:20];
    self.bossNameLabel.textColor = [UIColor whiteColor];
    [ov addSubview:self.bossNameLabel];

    UIView *track = [[UIView alloc] initWithFrame:CGRectMake(40, H * 0.41, W - 80, 16)];
    track.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
    track.layer.cornerRadius = 8;
    track.clipsToBounds = YES;
    [ov addSubview:track];
    self.bossFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W - 80, 16)];
    self.bossFill.backgroundColor = [UIColor colorWithRed:0.95 green:0.30 blue:0.30 alpha:1];
    [track addSubview:self.bossFill];

    self.bossHPLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, H * 0.41 + 22, W - 80, 18)];
    self.bossHPLabel.textAlignment = NSTextAlignmentCenter;
    self.bossHPLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightBold];
    self.bossHPLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75];
    [ov addSubview:self.bossHPLabel];

    self.bossTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, H * 0.53, W, 30)];
    self.bossTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.bossTimeLabel.font = [UIFont boldSystemFontOfSize:22];
    self.bossTimeLabel.textColor = [UIColor colorWithRed:1 green:0.75 blue:0.35 alpha:1];
    [ov addSubview:self.bossTimeLabel];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(0, H * 0.60, W, 20)];
    hint.text = [NSString stringWithFormat:@"连续点击守关者造成伤害 · 40 秒内点破（约 %.0f 次）",
                 MAX(1.0, self.bossMaxHP / (((0.1 + [self totalProd] * 0.05) * [self mutTapMult] * [self geneTapMult] * [self relicTapMult]) * [self geneBossMult]))];
    hint.textAlignment = NSTextAlignmentCenter;
    hint.font = [UIFont systemFontOfSize:11.5];
    hint.textColor = [UIColor colorWithWhite:1 alpha:0.45];
    [ov addSubview:hint];

    BossTapView *tap = [[BossTapView alloc] initWithFrame:CGRectMake(0, H * 0.16, W, H * 0.54)];
    tap.userInteractionEnabled = YES;
    tap.multipleTouchEnabled = YES;
    tap.bossOwner = (id<BossHitTarget>)self;
    [ov addSubview:tap];

    // 守关者血量按“需要点多少次”定，随关卡递增；基础点击取不含连击的裸伤害
    double base = (0.1 + [self totalProd] * 0.05) * [self mutTapMult] * [self geneTapMult] * [self relicTapMult];
    NSInteger gateIdx = MAX(0, (t / 6) - 1);
    // 进化过快带来的压力同样抬高守关者强度（最多 +120% 血量）
    double bossStrength = (1.0 + 0.35 * (double)[self eventPressure])
                        * (1.0 + 0.05 * (double)MIN(20, self.bossRushCount));
    double needHits = (220.0 + 80.0 * (double)gateIdx) * bossStrength;
    self.bossMaxHP = MAX(1.0, needHits * base);
    self.bossHP = self.bossMaxHP;
    self.bossTarget = t;
    self.bossEnd = [[NSDate date] timeIntervalSince1970] + 40.0;
    [self updateBossLabels];

    self.bossTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(bossTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.bossTimer forMode:NSRunLoopCommonModes];

    [self flashScreen:[UIColor redColor] alpha:0.18];
    [self shakeScreen:6];
}

- (void)updateBossLabels {
    CGFloat ratio = MAX(0.0, self.bossHP / self.bossMaxHP);
    CGRect f = self.bossFill.frame;
    f.size.width = (self.view.bounds.size.width - 80) * ratio;
    self.bossFill.frame = f;
    self.bossHPLabel.text = [NSString stringWithFormat:@"%@ / %@", FmtNum(self.bossHP), FmtNum(self.bossMaxHP)];
}

- (void)bossHitAtWindowPoint:(CGPoint)p {
    [self damageBossAt:[self.view convertPoint:p fromView:nil]];
}

- (void)onBossTapGesture:(UITapGestureRecognizer *)g {
    CGPoint p = [g locationInView:self.view];
    [self damageBossAt:p];
}

- (void)damageBossAt:(CGPoint)p {
    if (self.bossOverlay == nil) return;
    double dmg = [self tapPower] * [self geneBossMult];
    self.bossHP -= dmg;
    [self updateBossLabels];
    [self vibrateLight];
    [self playSFX:@"tap"];
    UIColor *hit = [UIColor colorWithRed:1.0 green:0.42 blue:0.32 alpha:1];
    [self sparkBurstAt:p color:hit count:12 speed:170];
    [self rippleAt:p color:hit radius:46];
    [self floatText:[NSString stringWithFormat:@"⚔️ -%@", FmtNum(dmg)] color:hit at:p];
    [self shakeScreen:2];
    if (self.bossHP <= 0) { [self finishBoss:YES]; }
}

- (void)onBossTap {
    [self damageBossAt:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height * 0.3)];
}

- (void)bossTick {
    if (self.bossOverlay == nil) return;
    NSTimeInterval left = self.bossEnd - [[NSDate date] timeIntervalSince1970];
    self.bossTimeLabel.text = [NSString stringWithFormat:@"%.1fs", MAX(0.0, left)];
    if (left <= 0) [self finishBoss:NO];
}

- (void)finishBoss:(BOOL)win {
    [self.bossTimer invalidate];
    self.bossTimer = nil;
    NSInteger t = self.bossTarget;
    [self.bossOverlay removeFromSuperview];
    self.bossOverlay = nil;
    self.bossFill = nil;
    if (win) {
        _bossDone[t] = YES;
        _bossDoneRound[t] = YES;
        _bossFails[t] = 0;
        NSInteger reward = 5 + (t / 6) * 4;
        double used = 40.0 - MAX(0.0, self.bossEnd - [[NSDate date] timeIntervalSince1970]);
        NSInteger rushAdd = used < 10.0 ? 4 : (used < 16.0 ? 2 : (used < 24.0 ? 1 : -1));
        self.bossRushCount = MAX(0, MIN(40, self.bossRushCount + rushAdd));
        if (rushAdd >= 2) reward = MAX(2, reward / 2);   // 秒破不给满额 DNA
        self.dna += reward;
        [self flashScreen:[UIColor colorWithRed:1 green:0.85 blue:0.4 alpha:1] alpha:0.5];
        [self shakeScreen:10];
        [self sparkBurstAt:[self creatureCenterInView] color:[UIColor colorWithRed:1 green:0.8 blue:0.3 alpha:1] count:40 speed:300];
        if (rushAdd >= 2) {
            [self flashScreen:[UIColor redColor] alpha:0.30];
            [self shakeScreen:8];
            [self toast:[NSString stringWithFormat:@"⚔️ %.1fs 击破 +%ld 🧬（减半）· ⚠️ 反噬 压力 %ld", used, (long)reward, (long)[self eventPressure]]];
        } else {
            [self toast:[NSString stringWithFormat:@"⚔️ 守关者被击破！+%ld 🧬", (long)reward]];
        }
        [self saveState];
        [self refreshAll];
    } else {
        _bossFails[t] = MIN(2, _bossFails[t] + 1);
        [self shakeScreen:5];
        if (_bossFails[t] >= 2) {
            [self toast:@"⛔️ 本关试炼已封锁：请飞升重开轮回，用 DNA 强化后再来"];
        } else {
            [self toast:[NSString stringWithFormat:@"试炼失败，还剩 1 次机会（再次失败将封锁本关）"]];
        }
        [self saveState];
        [self refreshAll];
    }
}

// ================= 时代事件 =================
- (NSString *)eventNamePlain:(NSInteger)k {
    switch (k) {
        case 1: return @"陨石撞击";
        case 2: return @"寒武纪大爆发";
        case 3: return @"超新星爆发";
        case 4: return @"熵坍缩";
        case 5: return @"日冕风暴";
        case 6: return @"基因崩解";
        case 7: return @"虚空抽取";
        default: return @"";
    }
}

- (NSString *)eventTitle:(NSInteger)k {
    switch (k) {
        case 1: return @"☄️ 陨石撞击";
        case 2: return @"🌋 寒武爆发";
        case 3: return @"💥 超新星";
        case 4: return @"🕳 熵坍缩";
        case 5: return @"🌞 日冕风暴";
        case 6: return @"🧬 基因崩解";
        case 7: return @"🕳 虚空抽取";
        default: return @"";
    }
}

static UIColor *EventColor(NSInteger k) {
    switch (k) {
        case 1: return [UIColor colorWithRed:1.00 green:0.42 blue:0.22 alpha:1];
        case 2: return [UIColor colorWithRed:0.30 green:1.00 blue:0.62 alpha:1];
        case 3: return [UIColor colorWithRed:1.00 green:0.86 blue:0.40 alpha:1];
        case 5: return [UIColor colorWithRed:1.00 green:0.70 blue:0.25 alpha:1];
        case 6: return [UIColor colorWithRed:0.85 green:0.28 blue:0.72 alpha:1];
        case 7: return [UIColor colorWithRed:0.35 green:0.45 blue:1.00 alpha:1];
        default: return [UIColor colorWithRed:0.72 green:0.42 blue:1.00 alpha:1];
    }
}

static NSString *EventIcon(NSInteger k) {
    switch (k) {
        case 1: return @"☄️";
        case 2: return @"🦠";
        case 3: return @"💥";
        case 5: return @"🌞";
        case 6: return @"🧬";
        case 7: return @"🕳";
        default: return @"🌀";
    }
}

static NSString *EventEffectText(NSInteger k, double d, double gain) {
    switch (k) {
        case 1: return [NSString stringWithFormat:@"产出 −50%% · 持续 %.0f 秒", d];
        case 2: return [NSString stringWithFormat:@"产出 ×2 · 持续 %.0f 秒", d];
        case 3: return [NSString stringWithFormat:@"瞬间 +%@ 能量", FmtNum(gain)];
        case 5: return [NSString stringWithFormat:@"产出大幅萎缩 · 持续 %.0f 秒", d];
        case 6: return [NSString stringWithFormat:@"所有成本大幅上涨 · 持续 %.0f 秒", d];
        case 7: return [NSString stringWithFormat:@"立刻抽走一大笔能量 · 产出萎缩 %.0f 秒", d];
        default: return [NSString stringWithFormat:@"成本 +35%% · 持续 %.0f 秒", d];
    }
}

- (void)buildEventBanner {
    CGFloat W = self.view.bounds.size.width;
    CGRect f = CGRectMake(14, 106, W - 28, 70);
    UIView *b = [[UIView alloc] initWithFrame:CGRectOffset(f, 0, -130)];
    b.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.92];
    b.layer.cornerRadius = 16;
    b.layer.borderWidth = 1.6;
    b.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.35] CGColor];
    b.layer.shadowColor = [[UIColor blackColor] CGColor];
    b.layer.shadowOpacity = 0.45;
    b.layer.shadowRadius = 10;
    b.layer.shadowOffset = CGSizeMake(0, 4);
    b.userInteractionEnabled = NO;
    b.alpha = 0;
    b.hidden = YES;
    [self.view addSubview:b];
    self.eventBanner = b;

    self.eventBannerIcon = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 52, 46)];
    self.eventBannerIcon.textAlignment = NSTextAlignmentCenter;
    self.eventBannerIcon.font = [UIFont systemFontOfSize:30];
    [b addSubview:self.eventBannerIcon];

    CGFloat bw = W - 28;                               // 横幅自身宽度
    self.eventBannerTitle = [[UILabel alloc] initWithFrame:CGRectMake(64, 10, bw - 64 - 86, 24)];
    self.eventBannerTitle.font = [UIFont boldSystemFontOfSize:16];
    self.eventBannerTitle.textColor = [UIColor whiteColor];
    [b addSubview:self.eventBannerTitle];

    self.eventBannerSub = [[UILabel alloc] initWithFrame:CGRectMake(64, 33, bw - 64 - 86, 17)];
    self.eventBannerSub.font = [UIFont systemFontOfSize:11.5];
    self.eventBannerSub.textColor = [UIColor colorWithWhite:1 alpha:0.72];
    self.eventBannerSub.adjustsFontSizeToFitWidth = YES;
    self.eventBannerSub.minimumScaleFactor = 0.7;
    [b addSubview:self.eventBannerSub];

    self.eventBannerTime = [[UILabel alloc] initWithFrame:CGRectMake(bw - 76, 12, 62, 32)];
    self.eventBannerTime.textAlignment = NSTextAlignmentRight;
    self.eventBannerTime.font = [UIFont monospacedDigitSystemFontOfSize:19 weight:UIFontWeightBold];
    self.eventBannerTime.textColor = [UIColor whiteColor];
    [b addSubview:self.eventBannerTime];

    UIView *fillBg = [[UIView alloc] initWithFrame:CGRectMake(14, 56, bw - 28, 5)];
    fillBg.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
    fillBg.layer.cornerRadius = 2.5;
    fillBg.clipsToBounds = YES;
    [b addSubview:fillBg];

    self.eventBannerFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fillBg.bounds.size.width, 5)];
    self.eventBannerFill.backgroundColor = [UIColor whiteColor];
    [fillBg addSubview:self.eventBannerFill];
    [self.view bringSubviewToFront:b];

    // 负面事件的“解除”按钮：贴在底部标签栏上方
    CGFloat H = self.view.bounds.size.height;
    UIButton *cb = [UIButton buttonWithType:UIButtonTypeCustom];
    cb.frame = CGRectMake(16, H - 84 - 58, W - 32, 46);
    cb.backgroundColor = [UIColor colorWithRed:0.58 green:0.13 blue:0.18 alpha:0.94];
    cb.layer.cornerRadius = 23;
    cb.layer.borderWidth = 1.5;
    cb.layer.borderColor = [[UIColor colorWithRed:1 green:0.45 blue:0.40 alpha:0.85] CGColor];
    cb.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    cb.titleLabel.adjustsFontSizeToFitWidth = YES;
    cb.titleLabel.minimumScaleFactor = 0.7;
    [cb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cb addTarget:self action:@selector(onCleanseEvent) forControlEvents:UIControlEventTouchUpInside];
    cb.hidden = YES;
    [self.view addSubview:cb];
    self.eventCleanseBtn = cb;
}

- (void)showEventBannerForKind:(NSInteger)k duration:(double)d gain:(double)gain {
    if (self.eventBanner == nil) [self buildEventBanner];
    UIColor *c = EventColor(k);
    self.eventBannerIcon.text = EventIcon(k);
    self.eventBannerTitle.text = [self eventNamePlain:k];
    NSString *effectText = EventEffectText(k, d, gain);
    if (k != 3) effectText = [effectText stringByAppendingFormat:@" · 强度 ×%.1f", 1.0 + 0.15 * (double)[self eventPressure]];
    self.eventBannerSub.text = effectText;
    self.eventBannerSub.textColor = [UIColor colorWithWhite:1 alpha:0.75];
    self.eventBannerTime.textColor = c;
    self.eventBannerTime.text = [NSString stringWithFormat:@"%.0fs", d];
    self.eventBanner.layer.borderColor = [c CGColor];
    self.eventBannerFill.backgroundColor = c;

    CGRect target = CGRectMake(14, 106, self.view.bounds.size.width - 28, 70);
    self.eventBanner.hidden = NO;
    self.eventBannerVisible = YES;
    self.eventBannerHideAt = [[NSDate date] timeIntervalSince1970] + d;
    self.eventBannerShownAt = [[NSDate date] timeIntervalSince1970];
    self.eventBannerTime.text = [NSString stringWithFormat:@"%.0fs", d];
    self.eventBanner.frame = CGRectMake(target.origin.x, -150, target.size.width, target.size.height);
    self.eventBanner.alpha = 0;
    [UIView animateWithDuration:0.42 delay:0 usingSpringWithDamping:0.72 initialSpringVelocity:0.6
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.eventBanner.frame = target;
        self.eventBanner.alpha = 1;
    } completion:nil];

    // 横幅呼吸光晕
    CABasicAnimation *glow = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    glow.fromValue = @0.20; glow.toValue = @0.85;
    glow.duration = 0.9; glow.autoreverses = YES; glow.repeatCount = 8;
    [self.eventBanner.layer addAnimation:glow forKey:@"eventGlow"];
    [self.view bringSubviewToFront:self.eventBanner];
    [self updateCleanseButton];
}

- (void)updateCleanseButton {
    if (self.eventCleanseBtn == nil) return;
    BOOL negative = (self.eventKind == 1 || self.eventKind == 4 || self.eventKind == 5 || self.eventKind == 6 || self.eventKind == 7);
    if (!negative) {
        self.eventCleanseBtn.hidden = YES;
        return;
    }
    double cost = MAX(10.0, [self totalProd] * 20.0) * (1.0 + 0.45 * (double)[self eventPressure]);
    self.cleanseCost = cost;
    BOOL enough = (self.energy >= cost);
    self.eventCleanseBtn.hidden = NO;
    self.eventCleanseBtn.enabled = enough;
    self.eventCleanseBtn.alpha = enough ? 1.0 : 0.55;
    NSString *name = [self eventNamePlain:self.eventKind];
    NSString *title = enough
        ? [NSString stringWithFormat:@"🛡 消耗 ⚡%@ 解除「%@」", FmtNum(cost), name]
        : [NSString stringWithFormat:@"能量不足 · 还需 ⚡%@ 才能解除「%@」", FmtNum(cost - self.energy), name];
    [self.eventCleanseBtn setTitle:title forState:UIControlStateNormal];
    [self.view bringSubviewToFront:self.eventCleanseBtn];
}

- (void)onCleanseEvent {
    if (!(self.eventKind == 1 || self.eventKind == 4 || self.eventKind == 5 || self.eventKind == 6 || self.eventKind == 7)) return;
    if (self.energy < self.cleanseCost) {
        [self toast:[NSString stringWithFormat:@"能量不足（需要 ⚡%@）", FmtNum(self.cleanseCost)]];
        return;
    }
    NSString *name = [self eventNamePlain:self.eventKind];
    self.energy = MAX(0.0, self.energy - self.cleanseCost);
    self.eventKind = 0;
    self.eventEnd = 0;
    [self hideEventBanner];
    self.eventCleanseBtn.hidden = YES;
    [self playSFX:@"spore"];
    [self flashScreen:[UIColor colorWithRed:0.55 green:0.95 blue:0.85 alpha:1] alpha:0.30];
    [self toast:[NSString stringWithFormat:@"🛡 已解除「%@」", name]];
    [self refreshDynamic];
    [self saveState];
}

- (void)hideEventBanner {
    if (self.eventBanner == nil || !self.eventBannerVisible) return;
    self.eventBannerVisible = NO;
    UIView *b = self.eventBanner;
    CGRect up = b.frame;
    up.origin.y = -150;
    [UIView animateWithDuration:0.32 animations:^{
        b.frame = up;
        b.alpha = 0;
    } completion:^(BOOL f) {
        b.hidden = YES;
        b.frame = CGRectMake(14, 106, self.view.bounds.size.width - 28, 70);
    }];
}

- (void)eventFXForKind:(NSInteger)k {
    CGFloat W = self.view.bounds.size.width, H = self.view.bounds.size.height;
    CGPoint ctr = CGPointMake(W / 2, H * 0.34);
    UIColor *c = EventColor(k);

    // 全屏闪光 + 震屏：陨石的冲击放在落地那一刻，避免提前闪
    if (k != 1) {
        CGFloat alpha = (k == 3) ? 0.62 : 0.22;
        [self flashScreen:c alpha:alpha];
        [self shakeScreen:(k == 3 ? 11 : 6)];
    }

    if (k == 1) {
        // 陨石：一整块巨岩砸穿屏幕
        [self meteorStrikeFX];
    } else if (k == 2) {
        // 寒武爆发：多层绿色扩张波 + 粒子雨
        [self shockwaveAt:ctr color:c maxRadius:MIN(W, 460)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.22 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shockwaveAt:CGPointMake(W / 2, H * 0.44) color:c maxRadius:MIN(W, 360)];
        });
        for (NSInteger i = 0; i < 6; i++) {
            CGPoint p = CGPointMake(30 + arc4random_uniform((uint32_t)(W - 60)), H * 0.18 + arc4random_uniform((uint32_t)(H * 0.5)));
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((0.15 + 0.1 * i) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sparkBurstAt:p color:c count:12 speed:150];
            });
        }
    } else if (k == 3) {
        // 超新星：白金色大冲击波 + 大量粒子
        [self shockwaveAt:ctr color:c maxRadius:MIN(W, 520)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.14 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shockwaveAt:ctr color:[UIColor whiteColor] maxRadius:MIN(W, 380)];
        });
        [self sparkBurstAt:ctr color:c count:44 speed:340];
        [self sparkBurstAt:ctr color:[UIColor whiteColor] count:18 speed:200];
    } else if (k == 5) {
        // 日冕风暴：从右向左横扫的橙色热浪 + 密集火星
        UIView *wave = [[UIView alloc] initWithFrame:CGRectMake(W, H * 0.12, W * 0.42, H * 0.78)];
        CAGradientLayer *wg = [CAGradientLayer layer];
        wg.frame = wave.bounds;
        wg.startPoint = CGPointMake(1, 0.5);
        wg.endPoint = CGPointMake(0, 0.5);
        wg.colors = @[(id)[[UIColor colorWithRed:1.0 green:0.72 blue:0.22 alpha:0.75] CGColor],
                      (id)[[UIColor colorWithRed:1.0 green:0.36 blue:0.10 alpha:0.35] CGColor],
                      (id)[[UIColor colorWithRed:1.0 green:0.25 blue:0.06 alpha:0.0] CGColor]];
        [wave.layer addSublayer:wg];
        wave.userInteractionEnabled = NO;
        [self.view addSubview:wave];
        [UIView animateWithDuration:1.05 animations:^{
            wave.frame = CGRectMake(-W * 0.42, H * 0.12, W * 0.42, H * 0.78);
            wave.alpha = 0;
        } completion:^(BOOL f) { [wave removeFromSuperview]; }];
        for (NSInteger i = 0; i < 5; i++) {
            CGPoint q = CGPointMake(W * 0.15 + arc4random_uniform((uint32_t)(W * 0.7)), H * 0.2 + arc4random_uniform((uint32_t)(H * 0.5)));
            [self sparkBurstAt:q color:c count:14 speed:200];
        }
    } else if (k == 7) {
        // 虚空抽取：向内收缩的蓝色漩涡 + 碎光
        [self shockwaveAt:ctr color:c maxRadius:MIN(W, 460)];
        for (NSInteger i = 0; i < 14; i++) {
            CGFloat ang = (M_PI * 2 * i) / 14.0;
            CGPoint q = CGPointMake(ctr.x + cos(ang) * 160, ctr.y + sin(ang) * 160);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((0.05 * i) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self sparkBurstAt:q color:c count:6 speed:110];
            });
        }
        [self sparkBurstAt:ctr color:[UIColor colorWithWhite:0.7 alpha:1] count:20 speed:90];
    } else if (k == 6) {
        // 基因崩解：紫色螺旋碎块 + 画面抖动
        [self shockwaveAt:ctr color:c maxRadius:MIN(W, 400)];
        for (NSInteger i = 0; i < 18; i++) {
            CGFloat ang = (M_PI * 2 * i) / 18.0;
            CGPoint q = CGPointMake(ctr.x + cos(ang) * 90, ctr.y + sin(ang) * 90);
            [self sparkBurstAt:q color:c count:6 speed:150];
        }
        [self shakeScreen:9];
    } else {
        // 熵坍缩：自上而下的紫色扫描带 + 暗紫闪
        UIView *scan = [[UIView alloc] initWithFrame:CGRectMake(0, -60, W, 60)];
        scan.backgroundColor = [UIColor colorWithRed:0.62 green:0.28 blue:1 alpha:0.35];
        scan.userInteractionEnabled = NO;
        [self.view addSubview:scan];
        [UIView animateWithDuration:1.1 animations:^{
            scan.frame = CGRectMake(0, H, W, 60);
            scan.alpha = 0;
        } completion:^(BOOL f) { [scan removeFromSuperview]; }];
        [self shockwaveAt:CGPointMake(W / 2, H * 0.5) color:c maxRadius:MIN(W, 380)];
        [self sparkBurstAt:ctr color:c count:16 speed:120];
    }
}

- (void)meteorStrikeFX {
    CGFloat W = self.view.bounds.size.width, H = self.view.bounds.size.height;
    CGFloat size = MIN(W * 0.68, 310);
    CGPoint hit = CGPointMake(W * 0.50, H * 0.29);

    // 陨石本体：深棕岩块 + 炽热边缘
    UIView *rock = [[UIView alloc] initWithFrame:CGRectMake(W * 0.95, -size * 1.6, size, size)];
    rock.backgroundColor = [UIColor colorWithRed:0.30 green:0.14 blue:0.07 alpha:1];
    rock.layer.cornerRadius = size / 2;
    rock.layer.shadowColor = [[UIColor colorWithRed:1.0 green:0.45 blue:0.12 alpha:1] CGColor];
    rock.layer.shadowOpacity = 1.0;
    rock.layer.shadowRadius = 46;
    rock.layer.shadowOffset = CGSizeZero;
    rock.clipsToBounds = NO;
    rock.userInteractionEnabled = NO;
    [self.view addSubview:rock];

    // 表面坑洞
    for (NSInteger i = 0; i < 6; i++) {
        CGFloat d = size * (0.08 + 0.10 * (i % 3));
        UIView *pit = [[UIView alloc] initWithFrame:CGRectMake(0, 0, d, d)];
        pit.backgroundColor = [UIColor colorWithWhite:0.10 alpha:0.55];
        pit.layer.cornerRadius = d / 2;
        pit.center = CGPointMake(size * (0.20 + 0.13 * i), size * (0.28 + 0.09 * (i % 4)));
        [rock addSubview:pit];
    }

    // 火焰拖尾
    UIView *tail = [[UIView alloc] initWithFrame:CGRectMake(size * 0.5, size * 0.12, size * 1.9, size * 0.42)];
    CAGradientLayer *tg = [CAGradientLayer layer];
    tg.frame = tail.bounds;
    tg.startPoint = CGPointMake(0, 0.5);
    tg.endPoint = CGPointMake(1, 0.5);
    tg.colors = @[(id)[[UIColor colorWithRed:1.0 green:0.85 blue:0.35 alpha:0.95] CGColor],
                  (id)[[UIColor colorWithRed:1.0 green:0.35 blue:0.08 alpha:0.55] CGColor],
                  (id)[[UIColor colorWithRed:1.0 green:0.2 blue:0.05 alpha:0.0] CGColor]];
    tg.locations = @[@0.0, @0.35, @1.0];
    [tail.layer addSublayer:tg];
    tail.transform = CGAffineTransformMakeRotation(M_PI * 0.25);
    tail.userInteractionEnabled = NO;
    [rock addSubview:tail];

    // 砸落
    [UIView animateWithDuration:0.60 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        rock.center = hit;
        rock.transform = CGAffineTransformMakeRotation(M_PI * 0.10);
    } completion:^(BOOL f) {
        [self meteorImpactAt:hit];
        [UIView animateWithDuration:0.24 animations:^{
            rock.transform = CGAffineTransformMakeScale(1.45, 1.45);
            rock.alpha = 0;
        } completion:^(BOOL f2) { [rock removeFromSuperview]; }];
    }];
}

- (void)meteorImpactAt:(CGPoint)hit {
    CGFloat W = self.view.bounds.size.width;
    UIColor *fire = [UIColor colorWithRed:1.0 green:0.45 blue:0.12 alpha:1];

    [self flashScreen:fire alpha:0.92];
    [self shakeScreen:17];
    [self vibrateHeavy];
    [self shockwaveAt:hit color:fire maxRadius:MIN(W, 620)];
    [self sparkBurstAt:hit color:fire count:80 speed:470];
    [self sparkBurstAt:hit color:[UIColor colorWithRed:1 green:0.88 blue:0.45 alpha:1] count:34 speed:300];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self shockwaveAt:hit color:[UIColor whiteColor] maxRadius:MIN(W, 430)];
        [self shakeScreen:12];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.26 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self shakeScreen:8];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.44 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self shakeScreen:5];
    });
}

- (void)eventAmbientPulse {
    // 事件期间的环境粒子，强化"世界正在变化"的感觉
    if (self.eventKind == 0) return;
    CGFloat W = self.view.bounds.size.width, H = self.view.bounds.size.height;
    UIColor *c = EventColor(self.eventKind);
    CGPoint p = CGPointMake(20 + arc4random_uniform((uint32_t)(W - 40)), H * 0.2 + arc4random_uniform((uint32_t)(H * 0.55)));
    [self sparkBurstAt:p color:c count:5 speed:70];
}

- (void)triggerEvent {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSInteger p = [self eventPressure];
    // 压力越高，负面灾害占比越高（0 压力约 42%，满压力约 84%），种类在 4 种负面里随机
    double negChance = MIN(0.92, 0.42 + 0.07 * (double)p);
    NSInteger k;
    if ((double)arc4random_uniform(1000) / 1000.0 < negChance) {
        NSArray *negKinds = @[@1, @4, @5, @6, @7];
        k = [negKinds[arc4random_uniform(5)] integerValue];
    } else {
        k = (arc4random_uniform(10) < 3) ? 2 : 3;   // 寒武 / 超新星
    }
    if (k == 3) {
        double gain = MAX(1.0, [self totalProd] * 900.0);
        self.energy += gain;
        self.runEarned += gain;
        self.totalEarned += gain;
        [self flashScreen:[UIColor colorWithRed:1 green:0.75 blue:0.4 alpha:1] alpha:0.55];
        [self shakeScreen:9];
        [self floatGain:gain prefix:@"💥" color:[UIColor colorWithRed:1 green:0.62 blue:0.30 alpha:1]
                     size:24 at:[self creatureCenterInView] rise:100];
        [self toast:[NSString stringWithFormat:@"💥 超新星爆发 ⚡+%@", FmtNum(gain)]];
        [self playSFX:@"event"];
        [self eventFXForKind:3];
        [self showEventBannerForKind:3 duration:5.0 gain:gain];
        self.nextEventAt = now + MAX(28.0, 130.0 - 16.0 * (double)p);
        return;
    }
    double d = (k == 1) ? 25.0 : (k == 2) ? 18.0 : (k == 5 ? 22.0 : 20.0);
    d = d * (1.0 + 0.05 * (double)p) * [self relicEventMult];
    self.eventKind = k;
    self.eventEnd = now + d;
    double drained = 0.0;
    if (k == 7) {
        double ratio = MIN(0.75, 0.35 + 0.06 * (double)p);
        drained = self.energy * ratio;
        self.energy = MAX(0.0, self.energy - drained);
        [self floatText:[NSString stringWithFormat:@"🕳 −%@", FmtNum(drained)]
                  color:[UIColor colorWithRed:0.55 green:0.62 blue:1 alpha:1]
                     at:[self creatureCenterInView]];
        [self shakeScreen:12];
        [self vibrateHeavy];
    }
    self.nextEventAt = now + MAX(25.0, 150.0 - 18.0 * (double)p);
    [self playSFX:@"event"];
    [self eventFXForKind:k];
    [self showEventBannerForKind:k duration:d gain:0];
    if (k == 7) {
        [self toast:[NSString stringWithFormat:@"%@ 降临：能量 −%@（%.0f 秒）", [self eventTitle:k], FmtNum(drained), d]];
    } else {
        [self toast:[NSString stringWithFormat:@"%@ 降临（%.0f 秒）", [self eventTitle:k], d]];
    }
    [self refreshDynamic];
}

- (void)handleEventsAndAchievements {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (self.sporeBoostEnd > 0) {
        NSTimeInterval left = self.sporeBoostEnd - now;
        if (left <= 0) {
            self.sporeBoostEnd = 0;
            self.sporeBoostMult = 1.0;
            [self toast:@"✨ 孢子增益结束"];
            [self updateSporePill];
            [self refreshDynamic];
        } else {
            [self updateSporePill];
        }
    }

    // 事件横幅：倒计时 + 进度条 + 环境粒子
    if (self.eventBannerVisible) {
        double left = self.eventBannerHideAt - now;
        double span = MAX(0.1, self.eventBannerHideAt - self.eventBannerShownAt);
        double ratio = MAX(0.0, MIN(1.0, left / span));
        CGFloat bw = self.eventBanner.bounds.size.width - 56;
        self.eventBannerTime.text = [NSString stringWithFormat:@"%.0fs", MAX(0.0, left)];
        self.eventBannerFill.frame = CGRectMake(0, 0, bw * ratio, 5);
        if (left <= 0) [self hideEventBanner];
    }
    if (self.eventKind > 0) {
        self.eventFXTick += 1;
        if (self.eventFXTick % 2 == 0) [self eventAmbientPulse];
        [self updateCleanseButton];
    } else if (self.eventCleanseBtn != nil) {
        self.eventCleanseBtn.hidden = YES;
    }

    if (self.eventKind > 0 && now >= self.eventEnd) {
        self.eventKind = 0;
        [self hideEventBanner];
        [self toast:@"环境恢复平静"];
        [self refreshDynamic];
    }
    if (self.eventKind == 0 && now >= self.nextEventAt) [self triggerEvent];
    [self checkAchievements];
}

// ================= 成就 =================
- (void)checkAchievements {
    BOOL cond[8];
    cond[0] = (self.totalTaps >= 500);
    cond[1] = (self.combo >= 100.0);
    cond[2] = (self.maxStage >= 11);
    cond[3] = (self.ascensions >= 3);
    cond[4] = ([self bossCount] >= 3);
    cond[5] = NO;
    for (NSInteger i = 0; i < kStageCount; i++) if (_counts[i] >= 200) cond[5] = YES;
    cond[6] = (self.energy >= 1.0e30);
    cond[7] = ([self mutTotal] >= 100);

    for (NSInteger i = 0; i < 8; i++) {
        if (cond[i] && !_achDone[i]) {
            _achDone[i] = YES;
            self.relicPoints += kAchRewards[i];
            [self toast:[NSString stringWithFormat:@"🏆 成就达成：%@  +%ld 🔮",
                        [NSString stringWithUTF8String:kAchTitles[i]], (long)kAchRewards[i]]];
            [self saveState];
        }
    }
}

- (void)onSecondTick {
    [self handleEventsAndAchievements];
    double autoGain = 0;
    NSInteger autoHands = [self geneEffLevel:4];
    if (autoHands > 0) {
        autoGain = [self tapPower] * (double)autoHands;
        self.energyPop = MIN(1.0, self.energyPop + 0.18);
        self.energy += autoGain;
        self.runEarned += autoGain;
        self.totalEarned += autoGain;
    }

    double added = self.secAccum;
    self.secAccum = 0;

    if (added > 0.01) {
        UILabel *lab = [self ensureFeed:0 offsetY:-20];
        lab.font = [UIFont boldSystemFontOfSize:13];
        lab.textColor = [UIColor colorWithRed:0.40 green:0.78 blue:1.0 alpha:1];
        lab.text = [NSString stringWithFormat:@"💧 +%@", FmtNum(added)];
        lab = [self ensureFeed:0 offsetY:-20];
        [self feedPulse:lab];
    } else if (self.autoProdFeed) {
        self.autoProdFeed.hidden = YES;
    }
    // 自动触手：按秒合并成一条，避免每秒多个数字堆叠
    if (autoGain > 0.01) {
        UILabel *lab2 = [self ensureFeed:1 offsetY:6];
        lab2.font = [UIFont boldSystemFontOfSize:13];
        lab2.textColor = [UIColor colorWithRed:0.30 green:0.86 blue:0.74 alpha:1];
        lab2.text = [NSString stringWithFormat:@"🤖 +%@", FmtNum(autoGain)];
        lab2 = [self ensureFeed:1 offsetY:6];
        [self feedPulse:lab2];
    } else if (self.autoTapFeed) {
        self.autoTapFeed.hidden = YES;
    }
}


// ================= 主循环 =================
- (void)tick {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    double gain = [self totalProd] * 0.1;   // totalProd 已含加速与基因/变异加成
    self.energy += gain;
    self.runEarned += gain;
    self.totalEarned += gain;
    self.secAccum += gain;

    if (self.combo > 1.0 && now - self.lastTapTime > [self comboHoldTime]) {
        self.combo = MAX(1.0, self.combo - 0.15);
    }
    [self refreshDynamic];
    [self refreshRows];
}

// ================= 震动 =================
// UIImpactFeedbackGenerator 由系统统一节流，快速连点时会吞脉冲（表现为"震动消失"）。
// 主路径用 Core Haptics 预建 transient 播放器，可高频重复触发；异常时回退 UIImpact 池。
- (void)setupHapticEngine {
    if (@available(iOS 13.0, *)) {
        if (![[CHHapticEngine capabilitiesForHardware] supportsHaptics]) return;
        NSError *err = nil;
        self.hapticEngine = [[CHHapticEngine alloc] initAndReturnError:&err];
        if (err || self.hapticEngine == nil) return;

        __weak typeof(self) weakSelf = self;
        // reset/stop 回调可能在任意线程，回主线程重建再启动，避免中间态吞脉冲
        self.hapticEngine.resetHandler = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf rebuildHapticPlayers];
                [weakSelf startHapticEngine];
            });
        };
        self.hapticEngine.stoppedHandler = ^(CHHapticEngineStoppedReason reason) {
            weakSelf.hapticReady = NO;
            dispatch_async(dispatch_get_main_queue(), ^{ [weakSelf startHapticEngine]; });
        };
        // 关键：不要自动休眠，否则闲置几秒后引擎停住，恢复期内的点击全部无声
        self.hapticEngine.autoShutdownEnabled = NO;

        [self rebuildHapticPlayers];
        [self startHapticEngine];
    }
}

// 单个 player 连续触发会互相打断（表现为掉帧式的"没震"），改成小池轮转
- (void)rebuildHapticPlayers {
    if (self.hapticEngine == nil) return;
    self.tapPool = [NSMutableArray array];
    self.critPool = [NSMutableArray array];

    NSError *err = nil;
    CHHapticEventParameter *i1 = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:0.62];
    CHHapticEventParameter *s1 = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:0.5];
    CHHapticEvent *e1 = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[i1, s1] relativeTime:0 duration:0.02];
    CHHapticPattern *p1 = [[CHHapticPattern alloc] initWithEvents:@[e1] parameters:@[] error:&err];
    if (err == nil && p1) {
        for (NSInteger i = 0; i < 4; i++) {
            id<CHHapticPatternPlayer> pl = [self.hapticEngine createPlayerWithPattern:p1 error:&err];
            if (pl) [self.tapPool addObject:pl];
        }
    }

    NSError *err2 = nil;
    CHHapticEventParameter *i2 = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:1.0];
    CHHapticEventParameter *s2 = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:0.8];
    CHHapticEvent *e2 = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[i2, s2] relativeTime:0 duration:0.02];
    CHHapticEvent *e3 = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[i2, s2] relativeTime:0.045 duration:0.03];
    CHHapticPattern *p2 = [[CHHapticPattern alloc] initWithEvents:@[e2, e3] parameters:@[] error:&err2];
    if (err2 == nil && p2) {
        for (NSInteger i = 0; i < 3; i++) {
            id<CHHapticPatternPlayer> pl = [self.hapticEngine createPlayerWithPattern:p2 error:&err2];
            if (pl) [self.critPool addObject:pl];
        }
    }
    self.hapticReady = (self.tapPool.count > 0);
}

- (void)startHapticEngine {
    if (self.hapticEngine == nil) return;
    NSError *err = nil;
    if ([self.hapticEngine startAndReturnError:&err] && err == nil) {
        if (self.tapPool.count == 0) [self rebuildHapticPlayers];
        self.hapticReady = (self.tapPool.count > 0);
    } else {
        self.hapticReady = NO;
    }
}

- (void)vibrateLight { [self fireHapticStrong:NO]; }
- (void)vibrateHeavy { [self fireHapticStrong:YES]; }

- (void)fireHapticStrong:(BOOL)strong {
    CFTimeInterval now = CACurrentMediaTime();
    if (now - self.lastHapticAt < 0.02) return;
    self.lastHapticAt = now;

    if (@available(iOS 13.0, *)) {
        if (self.hapticReady && self.tapPool.count > 0) {
            NSArray *pool = strong ? self.critPool : self.tapPool;
            if (pool.count > 0) {
                NSInteger idx = (strong ? self.critIdx : self.tapIdx) % (NSInteger)pool.count;
                if (strong) self.critIdx = (self.critIdx + 1) % 100000;
                else self.tapIdx = (self.tapIdx + 1) % 100000;
                NSError *err = nil;
                if ([[pool objectAtIndex:idx] startAtTime:CHHapticTimeImmediate error:&err] && err == nil) return;
            }
            self.hapticReady = NO;
            if (now - self.lastRebuildAt > 1.0) {
                self.lastRebuildAt = now;
                [self startHapticEngine];
            }
        }
    }

    if (self.haptics.count == 0) return;
    NSInteger idx = self.hapticIdx % (NSInteger)self.haptics.count;
    self.hapticIdx = (self.hapticIdx + 1) % 100000;
    UIImpactFeedbackGenerator *g = [self.haptics objectAtIndex:idx];
    [g prepare];
    [g impactOccurred];
}

- (void)onControlTouchDown { [self vibrateLight]; }

- (void)attachHapticsToView:(UIView *)v {
    if ([v isKindOfClass:[UIControl class]]) {
        UIControl *c = (UIControl *)v;
        [c removeTarget:self action:@selector(onControlTouchDown) forControlEvents:UIControlEventTouchDown];
        [c addTarget:self action:@selector(onControlTouchDown) forControlEvents:UIControlEventTouchDown];
    }
    for (UIView *sub in v.subviews) {
        [self attachHapticsToView:sub];
    }
}

// ================= 收益飘字 =================
// 所有增加能量的来源统一走这里，前缀 + 颜色区分来源
- (void)updateSporePill {
    NSTimeInterval left = self.sporeBoostEnd - [[NSDate date] timeIntervalSince1970];
    if (left > 0) {
        self.sporeBuffPill.text = [NSString stringWithFormat:@"✨ ×%.0f  %.0fs", self.sporeBoostMult, ceil(left)];
        self.sporeBuffPill.hidden = NO;
        [self.view bringSubviewToFront:self.sporeBuffPill];
    } else {
        self.sporeBuffPill.hidden = YES;
    }
}

- (void)sporeBanner:(NSString *)title value:(NSString *)value detail:(NSString *)detail accent:(UIColor *)accent {
    CGFloat W = self.view.bounds.size.width, H = self.view.bounds.size.height;
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W - 48, 138)];
    card.center = CGPointMake(W / 2, H * 0.24);
    card.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.94];
    card.layer.cornerRadius = 22;
    card.layer.borderWidth = 2.5;
    card.layer.borderColor = accent.CGColor;
    card.layer.shadowColor = accent.CGColor;
    card.layer.shadowOpacity = 0.75;
    card.layer.shadowRadius = 20;
    card.layer.shadowOffset = CGSizeZero;
    card.userInteractionEnabled = NO;   // 点击穿透，不挡生物区与孢子按钮

    UILabel *t1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, card.bounds.size.width - 28, 22)];
    t1.text = title; t1.textAlignment = NSTextAlignmentCenter;
    t1.font = [UIFont boldSystemFontOfSize:17];
    t1.textColor = accent;
    [card addSubview:t1];

    UILabel *t2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, card.bounds.size.width - 20, 56)];
    t2.text = value; t2.textAlignment = NSTextAlignmentCenter;
    t2.font = [UIFont monospacedDigitSystemFontOfSize:44 weight:UIFontWeightHeavy];
    t2.textColor = [UIColor whiteColor];
    t2.adjustsFontSizeToFitWidth = YES;
    t2.minimumScaleFactor = 0.35;
    t2.layer.shadowColor = accent.CGColor;
    t2.layer.shadowOpacity = 0.9;
    t2.layer.shadowRadius = 10;
    t2.layer.shadowOffset = CGSizeZero;
    [card addSubview:t2];

    UILabel *t3 = [[UILabel alloc] initWithFrame:CGRectMake(14, 96, card.bounds.size.width - 28, 24)];
    t3.text = detail; t3.textAlignment = NSTextAlignmentCenter;
    t3.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    t3.textColor = [UIColor colorWithRed:0.95 green:0.90 blue:0.75 alpha:0.9];
    [card addSubview:t3];

    card.alpha = 0;
    card.transform = CGAffineTransformMakeScale(0.55, 0.55);
    [self.view addSubview:card];
    [self.view bringSubviewToFront:card];
    [UIView animateWithDuration:0.28 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8 options:0 animations:^{
        card.alpha = 1.0;
        card.transform = CGAffineTransformIdentity;
    } completion:nil];
    [UIView animateWithDuration:0.45 delay:2.6 options:0 animations:^{
        card.alpha = 0;
        card.center = CGPointMake(card.center.x, card.center.y - 48);
        card.transform = CGAffineTransformMakeScale(1.06, 1.06);
    } completion:^(BOOL f) { [card removeFromSuperview]; }];
}

- (void)floatText:(NSString *)text color:(UIColor *)color at:(CGPoint)pt {
    UILabel *lab = [[UILabel alloc] init];
    lab.text = text;
    lab.font = [UIFont boldSystemFontOfSize:26];
    lab.textColor = color;
    lab.layer.shadowColor = [UIColor blackColor].CGColor;
    lab.layer.shadowOpacity = 0.6;
    lab.layer.shadowRadius = 3;
    lab.layer.shadowOffset = CGSizeZero;
    [lab sizeToFit];
    lab.center = pt;
    lab.tag = 9901;
    [self.view addSubview:lab];
    lab.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:0.16 animations:^{ lab.transform = CGAffineTransformIdentity; }];
    [UIView animateWithDuration:0.95 delay:0.05 options:UIViewAnimationOptionCurveEaseOut animations:^{
        lab.center = CGPointMake(lab.center.x, lab.center.y - 96);
        lab.alpha = 0;
    } completion:^(BOOL f) { [lab removeFromSuperview]; }];
}

- (void)floatGain:(double)value prefix:(NSString *)prefix color:(UIColor *)color size:(CGFloat)size at:(CGPoint)pt rise:(CGFloat)rise {
    UILabel *lab = [[UILabel alloc] init];
    lab.text = [NSString stringWithFormat:@"%@ +%@", prefix, FmtNum(value)];
    lab.font = [UIFont boldSystemFontOfSize:size];
    lab.textColor = color;
    lab.layer.shadowColor = [UIColor blackColor].CGColor;
    lab.layer.shadowOpacity = 0.55;
    lab.layer.shadowRadius = 2.5;
    lab.layer.shadowOffset = CGSizeZero;
    [lab sizeToFit];
    lab.center = pt;
    lab.tag = 9901;
    [self.view addSubview:lab];
    [UIView animateWithDuration:0.72 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        lab.center = CGPointMake(lab.center.x, lab.center.y - rise);
        lab.alpha = 0;
    } completion:^(BOOL f) { [lab removeFromSuperview]; }];
}

- (CGPoint)creatureCenterInView {
    return [self.view convertPoint:CGPointMake(CGRectGetMidX(self.creatureArea.bounds), CGRectGetMidY(self.creatureArea.bounds)) fromView:self.creatureArea];
}

// ================= 点击 =================
- (void)handleTapAtPointInArea:(CGPoint)pArea {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    self.totalTaps += 1;
    if (now - self.lastTapTime <= 1.0) {
        self.combo = MIN([self comboCap], self.combo + [self mutComboStep]);
    } else {
        self.combo = 1.0;
    }
    self.lastTapTime = now;

    double gain = [self tapPower];
    BOOL crit = NO;
    double critChance = [self mutCritChance];
    if (critChance > 0 && (double)arc4random_uniform(1000) / 1000.0 < critChance) {
        crit = YES;
        gain *= 3.0;
    }
    // 🔗 暴击回响：暴击时 25% 概率追加一次等额收益（单独记账，飘字用黄色）
    double chainBonus = 0;
    if (crit && _muts[MutCritChain] > 0 && (double)arc4random_uniform(1000) / 1000.0 < MIN(0.6, 0.25 * (double)_muts[MutCritChain])) {
        chainBonus = gain;
    }
    // 🌧 孢子雨：点击时 12% 概率额外获得一份孢子收益（单独记账，紫色飘字）
    double sporeRainBonus = 0;
    if (_muts[MutSporeRain] > 0 && (double)arc4random_uniform(1000) / 1000.0 < MIN(0.24, 0.06 * (double)_muts[MutSporeRain])) {
        sporeRainBonus = (MAX(50.0 * [self tapPower], 20.0 * [self totalProd]) + 10) * [self geneSporeMult] * [self relicSporeMult] * (1.0 + 0.8 * (double)_muts[MutSpore]) * 0.6;
    }
    double totalGain = gain + chainBonus + sporeRainBonus;
    self.energy += totalGain;
    self.runEarned += totalGain;
    self.totalEarned += totalGain;
    self.energyPop = MIN(1.0, self.energyPop + (crit ? 0.9 : 0.45));
    [self refreshDynamic];

    if (crit) [self vibrateHeavy]; else [self vibrateLight];
    [self playSFX:(crit ? @"crit" : @"tap")];

    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.fromValue = @1.0; pulse.toValue = @0.9;
    pulse.duration = 0.06; pulse.autoreverses = YES;
    [self.creatureLabel.layer addAnimation:pulse forKey:@"pulse"];

    CGPoint p = [self.view convertPoint:pArea fromView:self.creatureArea];
    CGFloat offX = (CGFloat)((int)arc4random_uniform(50) - 25);

    UIColor *fxColor = crit ? [UIColor colorWithRed:1.0 green:0.30 blue:0.28 alpha:1] : StageAccent(self.stage);
    [self rippleAt:p color:fxColor radius:(crit ? 78 : 56)];
    [self sparkBurstAt:p color:fxColor count:(crit ? 30 : 12) speed:(crit ? 300 : 180)];
    if (crit) {
        [self shakeScreen:7];
        [self flashScreen:[UIColor colorWithRed:1.0 green:0.35 blue:0.30 alpha:1] alpha:0.16];
        [self popCreature];
    }

    // 普通点击：白色；暴击：红色
    UIColor *tapColor = crit ? [UIColor colorWithRed:1.0 green:0.24 blue:0.24 alpha:1]
                             : [UIColor colorWithWhite:1.0 alpha:1.0];
    [self floatGain:gain prefix:(crit ? @"✸" : @"👆") color:tapColor size:(crit ? 25 : 19)
                  at:CGPointMake(p.x + offX, p.y - 16) rise:80];

    // 暴击回响附带的收益：黄色
    if (chainBonus > 0) {
        [self floatGain:chainBonus prefix:@"🔗" color:[UIColor colorWithRed:1.0 green:0.85 blue:0.30 alpha:1]
                     size:18 at:CGPointMake(p.x - offX, p.y - 42) rise:76];
    }
    // 孢子雨：紫色
    if (sporeRainBonus > 0) {
        [self floatGain:sporeRainBonus prefix:@"🌧" color:[UIColor colorWithRed:0.72 green:0.50 blue:1.0 alpha:1]
                     size:17 at:CGPointMake(p.x + offX * 0.4, p.y - 66) rise:70];
    }
}

- (void)onQty:(UIButton *)b {
    self.buyQtyMode = b.tag;
    [self refreshAll];
}

- (void)buyRow:(NSInteger)i {
    NSInteger k = [self buyCountForRow:i];
    double cost = [self costFor:i owned:_counts[i] count:k];
    if (self.energy < cost) {
        if (self.buyQtyMode == 3) {
            NSInteger n = [self maxAffordableFor:i owned:_counts[i]];
            if (n <= 0) { [self toast:@"能量不足"]; return; }
            k = n;
            cost = [self costFor:i owned:_counts[i] count:k];
        } else {
            [self toast:@"能量不足"];
            return;
        }
    }
    self.energy -= cost;
    if (self.energy < 0.0) self.energy = 0.0;
    _counts[i] += k;
    [self playSFX:@"buy"];
    if (i >= 0 && i < (NSInteger)self.rows.count) {
        UIView *rv = self.rows[i];
        if ([rv isKindOfClass:[GenRow class]]) {
            CAKeyframeAnimation *pop = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            pop.values = @[@1.0, @1.035, @1.0];
            pop.keyTimes = @[@0, @0.35, @1];
            pop.duration = 0.22;
            [rv.layer addAnimation:pop forKey:@"buyPop"];
        }
    }
    [self refreshDynamic];
    [self refreshRows];
    [self saveState];
}

// ================= 进化 =================
- (void)onEvolve {
    if (self.stage >= kStageCount - 1) { [self toast:@"已经是最终形态啦"]; return; }
    if ([self needsBossForStage:self.stage + 1]) {
        if (_bossFails[self.stage + 1] >= 2) {
            [self toast:@"⛔️ 本关试炼已封锁：飞升重开轮回，用 DNA 点「⚔️ 试炼锋芒」再来"];
            return;
        }
        [self startBossForStage:self.stage + 1];
        return;
    }
    double cost = kEvolveCost[self.stage + 1] * kEvolveMult * [self difficultyEvoMult] * [self evoGeneTax] * [self autoEvoMult];
    if (self.energy < cost) { [self toast:@"能量不足，继续积攒！"]; return; }
    self.energy -= cost;
    if (self.energy < 0.0) self.energy = 0.0;
    self.stage += 1;
    if (self.stage > self.maxStage) self.maxStage = self.stage;
    {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        double gap = (self.lastEvolveAt > 0) ? (now - self.lastEvolveAt) : 999.0;
        if (self.lastEvolveAt > 0 && self.stage >= 6) {
            // 间隔越短，惩罚权重越高：<8s 记 4 点，<15s 记 2 点，<22s 记 1 点，正常间隔反向回落
            if (gap < 8.0)       { self.fastEvoCount = MIN(80, self.fastEvoCount + 4); }
            else if (gap < 15.0) { self.fastEvoCount = MIN(80, self.fastEvoCount + 2); }
            else if (gap < 22.0) { self.fastEvoCount = MIN(80, self.fastEvoCount + 1); }
            else                 { self.fastEvoCount = MAX(0, self.fastEvoCount - 1); }
            if (gap < 8.0) {
                [self toast:[NSString stringWithFormat:@"⚠️ 进化只用了 %.0f 秒 · 世界反噬加剧（压力 %ld）",
                            gap, (long)[self eventPressure]]];
                [self flashScreen:[UIColor colorWithRed:1 green:0.3 blue:0.2 alpha:1] alpha:0.18];
                [self shakeScreen:4];
            }
        }
        self.lastEvolveAt = now;
    }
    if (_muts[MutEvoWarm] > 0) self.evoWarmUntil = [[NSDate date] timeIntervalSince1970] + 15.0;
    [self playSFX:@"evolve"];
    [self vibrateHeavy];

    CGPoint cpt = [self creatureCenterInView];
    UIColor *accent = StageAccent(self.stage);
    [self flashScreen:[UIColor colorWithWhite:1.0 alpha:1.0] alpha:0.55];
    [self flashScreen:accent alpha:0.45];
    [self shockwaveAt:cpt color:accent maxRadius:MIN(self.view.bounds.size.width, 360)];
    [self sparkBurstAt:cpt color:accent count:70 speed:340];
    [self sparkBurstAt:cpt color:[UIColor colorWithWhite:1.0 alpha:1.0] count:30 speed:180];
    [self shakeScreen:11];
    [self popCreature];

    [self applyTheme:YES];
    [self rebuildRows];
    [self refreshAll];
    [self saveState];

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf presentMutationChoice];
    });
}

// ================= 变异 3 选 1 =================
- (void)presentMutationChoice {
    if (self.mutationSheetOpen) return;
    self.mutationSheetOpen = YES;

    NSMutableArray *cands = [NSMutableArray array];
    for (NSInteger i = 0; i < MutKinds; i++) {
        if (_muts[i] == 0) [cands addObject:@(i)];
    }
    NSMutableArray *pick = [NSMutableArray array];
    while (pick.count < 3) {
        NSInteger m;
        if (cands.count > 0) {
            NSInteger r = arc4random_uniform((uint32_t)cands.count);
            m = [cands[r] integerValue];
            [cands removeObjectAtIndex:r];
            if ([pick containsObject:@(m)]) {
                m = arc4random_uniform(MutKinds);
            }
        } else {
            m = arc4random_uniform(MutKinds);
        }
        if (![pick containsObject:@(m)]) [pick addObject:@(m)];
    }

    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    UIView *dim = [[UIView alloc] initWithFrame:self.view.bounds];
    dim.backgroundColor = [UIColor colorWithWhite:0 alpha:0.55];
    dim.alpha = 0;
    [self.view addSubview:dim];

    CGFloat cardW = W - 40;
    CGFloat rowH = 82;
    CGFloat cardH = 96 + 3 * rowH + 16;
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(20, (H - cardH) / 2, cardW, cardH)];
    card.backgroundColor = [UIColor colorWithRed:0.12 green:0.08 blue:0.20 alpha:1];
    card.layer.cornerRadius = 22;
    card.layer.borderWidth = 1;
    card.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.12].CGColor;
    card.transform = CGAffineTransformMakeScale(0.92, 0.92);
    [self.view addSubview:card];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, cardW - 40, 26)];
    title.text = @"🧬 选择变异路线";
    title.font = [UIFont boldSystemFontOfSize:19];
    title.textColor = [UIColor whiteColor];
    [card addSubview:title];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(20, 48, cardW - 40, 16)];
    sub.text = [NSString stringWithFormat:@"第 %ld 次进化 · 本轮有效，飞升后重置", (long)self.stage];
    sub.font = [UIFont systemFontOfSize:11];
    sub.textColor = [UIColor colorWithWhite:1 alpha:0.45];
    [card addSubview:sub];

    for (NSInteger idx = 0; idx < 3; idx++) {
        NSInteger m = [pick[idx] integerValue];
        CGFloat y = 76 + idx * rowH;
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(14, y, cardW - 28, rowH - 8);
        b.backgroundColor = [UIColor colorWithWhite:1 alpha:0.07];
        b.layer.cornerRadius = 14;
        b.tag = m;
        [b addTarget:self action:@selector(onMutationPick:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:b];

        UILabel *ic = [[UILabel alloc] initWithFrame:CGRectMake(12, (rowH - 8) / 2 - 15, 34, 30)];
        ic.text = [NSString stringWithUTF8String:kMuts[m].icon];
        ic.font = [UIFont systemFontOfSize:22];
        ic.textAlignment = NSTextAlignmentCenter;
        [b addSubview:ic];

        UILabel *nm = [[UILabel alloc] initWithFrame:CGRectMake(54, 12, cardW - 120, 22)];
        nm.text = [NSString stringWithUTF8String:kMuts[m].name];
        nm.font = [UIFont boldSystemFontOfSize:15];
        nm.textColor = [UIColor whiteColor];
        [b addSubview:nm];

        UILabel *ds = [[UILabel alloc] initWithFrame:CGRectMake(54, 34, cardW - 120, 16)];
        ds.text = [NSString stringWithUTF8String:kMuts[m].desc];
        ds.font = [UIFont systemFontOfSize:11];
        ds.textColor = [UIColor colorWithWhite:1 alpha:0.55];
        [b addSubview:ds];
    }

    self.mutationDimView = dim;
    self.mutationCardView = card;
    self.mutationCandidates = [pick copy];

    if (self.aiOn) {
        __weak typeof(self) ws = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws aiPickMutation];
        });
    }

    [UIView animateWithDuration:0.25 animations:^{
        dim.alpha = 1;
        card.transform = CGAffineTransformIdentity;
    }];
}

- (void)onMutationPick:(UIButton *)b {
    NSInteger m = b.tag;
    _muts[m] += 1;
    [self sparkBurstAt:[self creatureCenterInView]
                 color:[UIColor colorWithRed:0.78 green:0.62 blue:1.0 alpha:1] count:34 speed:260];
    [self dismissMutationSheet];
    [self refreshAll];
    [self saveState];
    [self toast:[NSString stringWithFormat:@"%@ %@ ×%ld", [NSString stringWithUTF8String:kMuts[m].icon],
               [NSString stringWithUTF8String:kMuts[m].name], (long)_muts[m]]];
}

- (void)dismissMutationSheet {
    UIView *card = self.mutationCardView;
    UIView *dim = self.mutationDimView;
    self.mutationCardView = nil;
    self.mutationDimView = nil;
    self.mutationSheetOpen = NO;
    if (card == nil && dim == nil) return;
    [UIView animateWithDuration:0.2 animations:^{
        dim.alpha = 0;
        card.alpha = 0;
        card.transform = CGAffineTransformMakeScale(0.94, 0.94);
    } completion:^(BOOL f) {
        [dim removeFromSuperview];
        [card removeFromSuperview];
    }];
}

// ---- 金色孢子 ----
- (void)scheduleSpore {
    NSTimeInterval delay = (22 + arc4random_uniform(20)) * [self geneSporeRateMult];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self spawnSpore];
        [self scheduleSpore];
    });
}

- (void)spawnSpore {
    if (self.sporeActive || self.view.window == nil || self.currentTab != 0) return;
    self.sporeActive = YES;
    CGFloat W = self.view.bounds.size.width;
    CGFloat zoneTop = CGRectGetMinY(self.creatureArea.frame);
    CGFloat zoneH = self.creatureArea.bounds.size.height;
    self.sporeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sporeBtn.frame = CGRectMake(20 + arc4random_uniform((uint32_t)(W - 100)), zoneTop + 20 + arc4random_uniform((uint32_t)(zoneH - 80)), 54, 54);
    self.sporeBtn.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0.2 alpha:0.95];
    self.sporeBtn.layer.cornerRadius = 27;
    self.sporeBtn.layer.shadowColor = [UIColor colorWithRed:1 green:0.8 blue:0.2 alpha:1].CGColor;
    self.sporeBtn.layer.shadowRadius = 12;
    self.sporeBtn.layer.shadowOpacity = 0.9;
    self.sporeBtn.layer.shadowOffset = CGSizeZero;
    [self.sporeBtn setTitle:@"✨" forState:UIControlStateNormal];
    self.sporeBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.sporeBtn addTarget:self action:@selector(onSpore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sporeBtn];

    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.fromValue = @1.0; pulse.toValue = @1.2;
    pulse.duration = 0.5; pulse.autoreverses = YES; pulse.repeatCount = HUGE_VALF;
    [self.sporeBtn.layer addAnimation:pulse forKey:@"sporePulse"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.sporeActive) {
            [self.sporeBtn removeFromSuperview];
            self.sporeActive = NO;
        }
    });
}

- (void)onSpore {
    if (!self.sporeActive) return;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    CGPoint spt = self.sporeBtn.center;
    UIColor *gold = [UIColor colorWithRed:1.0 green:0.78 blue:0.25 alpha:1];
    double amp = [self geneSporeMult] * [self relicSporeMult] * (1.0 + 0.8 * (double)_muts[MutSpore]);

    // 三种孢子效果之一：短时小倍率 / 短时大倍率 / 直接跳过 8 分钟
    NSInteger kind = (NSInteger)arc4random_uniform(3);
    if (kind == 2) {
        double reward = [self totalProd] * 480.0 * amp;
        self.energy += reward;
        self.runEarned += reward;
        self.totalEarned += reward;
        [self floatGain:reward prefix:@"⏩" color:[UIColor colorWithRed:1.0 green:0.72 blue:0.20 alpha:1]
                     size:24 at:spt rise:90];
        [self sporeBanner:@"⏩ 孢子 · 时间跃迁" value:[NSString stringWithFormat:@"+%@", FmtNum(reward)]
                   detail:@"直接到账接下来 8 分钟的产出" accent:gold];
    } else {
        double base = (kind == 1) ? 10.0 : 3.0;
        double dur  = (kind == 1) ? 12.0 : 20.0;
        double mult = MIN(80.0, base * amp);
        self.sporeBoostEnd = now + dur;
        self.sporeBoostMult = mult;
        [self updateSporePill];
        [self flashScreen:gold alpha:(kind == 1 ? 0.42 : 0.24)];
        [self shakeScreen:(kind == 1 ? 8 : 5)];
        [self shockwaveAt:spt color:gold maxRadius:MIN(self.view.bounds.size.width, 420)];
        [self sparkBurstAt:spt color:gold count:(kind == 1 ? 40 : 24) speed:260];
        [self sporeBanner:[NSString stringWithFormat:@"✨ 孢子 · %@", (kind == 1 ? @"爆发" : @"涌动")]
                     value:[NSString stringWithFormat:@"×%.0f", mult]
                    detail:[NSString stringWithFormat:@"接下来 %.0f 秒，全部产出 ×%.0f", dur, mult]
                    accent:gold];
        [self floatText:[NSString stringWithFormat:@"×%.0f", mult] color:gold at:spt];
    }
    [self playSFX:@"spore"];
    self.sporeActive = NO;
    [self.sporeBtn removeFromSuperview];
    self.sporeActive = NO;
    [self refreshDynamic];
}

// ---- DNA 商店 ----
- (void)onDNA {
    [self selectTab:1];

}

// ---- 飞升 ----
- (void)onAscend {
    NSInteger gain = [self ascDNAGain];
    if (gain <= 0) return;
    double nextProd = MAX(0.25, pow(0.85, (double)(self.ascensions + 1)));
    double nextCost = pow(1.22, (double)(self.ascensions + 1));
    NSInteger nextAuto = MIN(6, (self.fastEvoCount + self.bossRushCount * 2) / 3);
    [AscendDialogView presentInView:self.view gain:gain prod:nextProd cost:nextCost
                                evo:pow(1.30, (double)(self.ascensions + 1))
                               fast:self.fastEvoCount autoP:nextAuto
                           confirm:^{
        self.dna += gain;
        self.ascensions += 1;
        self.relicPoints += 2;
        self.energy = 0;
        self.shownEnergy = 0;
        self.runEarned = 0;
        self.stage = 0;
        self.combo = 1.0;
        for (NSInteger i = 0; i < 64; i++) { _bossFails[i] = 0; _bossDoneRound[i] = NO; }
        // 按本轮实际进化速度固化自适应难度（快则加难，慢则回落）
        self.autoDiff = MIN(6, (self.fastEvoCount + self.bossRushCount * 2) / 3);   // 进化过快 + 秒破守关者都折算进下一轮基线
        self.fastEvoCount = 0;
        self.bossRushCount = 0;
        self.lastEvolveAt = 0;
        NSInteger startLv = [self geneStartLineLevel];
        for (NSInteger i = 0; i < kStageCount; i++) _counts[i] = startLv;
        for (NSInteger i = 0; i < MutKinds; i++) _muts[i] = 0;
        [self clearFeeds];
        [self playSFX:@"ascend"];
        [self applyTheme:YES];
        CGPoint cpt = [self creatureCenterInView];
        UIColor *accent = StageAccent(self.stage);
        [self flashScreen:[UIColor colorWithRed:0.75 green:0.55 blue:1.0 alpha:1] alpha:0.7];
        [self shockwaveAt:cpt color:[UIColor colorWithRed:0.85 green:0.70 blue:1.0 alpha:1] maxRadius:MIN(self.view.bounds.size.width, 420)];
        [self sparkBurstAt:cpt color:[UIColor colorWithRed:0.85 green:0.70 blue:1.0 alpha:1] count:90 speed:380];
        [self sparkBurstAt:cpt color:accent count:50 speed:240];
        [self shakeScreen:13];
        [self popCreature];
        [self rebuildRows];
        [self refreshAll];
        [self saveState];
        [self toast:[NSString stringWithFormat:@"🕊 飞升成功！+%@🧬 · 🔮 遗物点 +2 · 新的轮回开始", FmtInt(gain)]];
    }];
}

// ================= AI 托管（规则型策略 AI，纯本地、不联网） =================
- (void)onToggleAI {
    self.aiOn = !self.aiOn;
    if (self.aiOn) {
        [self startAITimer];
        [self updateAIButton];
        [self aiTick];      // 立刻跑一轮，点开就能看到它开始买
        [self toast:@"🤖 AI 托管开启：自动购买 · 自动进化 · 自动打试炼 · 自动点孢子"];
    } else {
        [self stopAITimer];
        [self updateAIButton];
        [self toast:@"🤖 AI 托管已关闭"];
    }
    [self saveState];
}

- (void)updateAIButton {
    if (self.aiBtn == nil) return;
    [self.aiBtn setTitle:@"🤖" forState:UIControlStateNormal];
    if (self.aiOn) {
        self.aiBtn.backgroundColor = [UIColor colorWithRed:0.44 green:0.27 blue:0.95 alpha:0.95];
        self.aiBtn.layer.borderColor = [UIColor colorWithRed:0.76 green:0.58 blue:1.0 alpha:1.0].CGColor;
        if ([self.aiBtn.layer animationForKey:@"aiBreath"] == nil) {
            CABasicAnimation *b = [CABasicAnimation animationWithKeyPath:@"opacity"];
            b.fromValue = @0.72; b.toValue = @1.0;
            b.duration = 1.1; b.autoreverses = YES; b.repeatCount = HUGE_VALF;
            [self.aiBtn.layer addAnimation:b forKey:@"aiBreath"];
        }
    } else {
        self.aiBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
        self.aiBtn.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.22] CGColor];
        [self.aiBtn.layer removeAnimationForKey:@"aiBreath"];
        self.aiBtn.alpha = 0.9;
    }
}

- (void)startAITimer {
    if (self.aiTimer != nil) return;
    self.aiTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(aiTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.aiTimer forMode:NSRunLoopCommonModes];
}

- (void)stopAITimer {
    [self.aiTimer invalidate];
    self.aiTimer = nil;
}

// 托管收集能量：0.5 秒结算 5 次点击（等效 10 次/秒），只按一次飘字，不逐下震屏
- (double)aiTapOnce {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    self.totalTaps += 1;
    if (now - self.lastTapTime <= 1.0) {
        self.combo = MIN([self comboCap], self.combo + [self mutComboStep]);
    } else {
        self.combo = 1.0;
    }
    self.lastTapTime = now;

    double gain = [self tapPower];
    BOOL crit = NO;
    double critChance = [self mutCritChance];
    if (critChance > 0 && (double)arc4random_uniform(1000) / 1000.0 < critChance) { crit = YES; gain *= 3.0; }
    double chain = 0;
    if (crit && _muts[MutCritChain] > 0
        && (double)arc4random_uniform(1000) / 1000.0 < MIN(0.6, 0.25 * (double)_muts[MutCritChain])) chain = gain;
    double rain = 0;
    if (_muts[MutSporeRain] > 0
        && (double)arc4random_uniform(1000) / 1000.0 < MIN(0.24, 0.06 * (double)_muts[MutSporeRain])) {
        rain = (MAX(50.0 * [self tapPower], 20.0 * [self totalProd]) + 10) * [self geneSporeMult]
             * [self relicSporeMult] * (1.0 + 0.8 * (double)_muts[MutSpore]) * 0.6;
    }
    double total = gain + chain + rain;
    self.energy += total;
    self.runEarned += total;
    self.totalEarned += total;
    self.energyPop = MIN(1.0, self.energyPop + (crit ? 0.9 : 0.35));
    return total;
}

- (void)aiTapBurst {
    double sum = 0.0;
    for (NSInteger i = 0; i < 5; i++) sum += [self aiTapOnce];
    [self refreshDynamic];
    if (sum > 0 && (NSInteger)arc4random_uniform(2) == 0) {
        [self floatGain:sum prefix:@"🤖" color:[UIColor colorWithRed:0.72 green:0.66 blue:1.0 alpha:1]
                     size:16 at:[self creatureCenterInView] rise:70];
    }
}

// 托管选变异：按"对自动玩法收益最大"排序（高效代谢 > 掠食强化 > 暴击系 > 连击系 > 孢子系）
- (void)aiPickMutation {
    if (!self.aiOn || !self.mutationSheetOpen || self.mutationCandidates.count == 0) return;
    NSArray *weight = @[@95, @100, @70, @40, @50, @45, @55, @35, @55, @30, @60];
    NSInteger best = -1;
    double bestScore = -1.0;
    for (NSNumber *n in self.mutationCandidates) {
        NSInteger m = [n integerValue];
        if (m < 0 || m >= (NSInteger)weight.count) continue;
        double sc = [weight[m] doubleValue] + (double)arc4random_uniform(12) * 0.1;
        if (sc > bestScore) { bestScore = sc; best = m; }
    }
    if (best < 0) best = [self.mutationCandidates[0] integerValue];
    _muts[best] += 1;
    [self dismissMutationSheet];
    [self refreshAll];
    [self saveState];
    [self toast:[NSString stringWithFormat:@"🤖 已替你选：%@ %@ ×%ld",
               [NSString stringWithUTF8String:kMuts[best].icon],
               [NSString stringWithUTF8String:kMuts[best].name], (long)_muts[best]]];
}

// 托管打守关者：0.5 秒结算 4 次点击（等效 8 次/秒，人手极限），特效降频避免卡顿
- (void)aiHitBoss {
    if (self.bossOverlay == nil) return;
    double dmg = [self tapPower] * [self geneBossMult] * 4.0;
    self.bossHP -= dmg;
    [self updateBossLabels];
    CGFloat W = self.view.bounds.size.width, H = self.view.bounds.size.height;
    CGPoint pt = CGPointMake(W * (0.40 + 0.20 * (double)arc4random_uniform(100) / 100.0),
                             H * (0.30 + 0.12 * (double)arc4random_uniform(100) / 100.0));
    if ((NSInteger)arc4random_uniform(4) == 0) {
        UIColor *hit = [UIColor colorWithRed:1.0 green:0.42 blue:0.32 alpha:1];
        [self sparkBurstAt:pt color:hit count:8 speed:150];
        [self floatText:[NSString stringWithFormat:@"⚔️ -%@", FmtNum(dmg)] color:hit at:pt];
    }
    if (self.bossHP <= 0) [self finishBoss:YES];
}

- (void)aiTick {
    if (!self.aiOn) return;
    if (self.currentTab != 0) return;          // 只看护"生命"页，避免打乱其他页面
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

    // 1) 有试炼在打：全力攻击
    if (self.bossOverlay != nil) { [self aiHitBoss]; return; }
    // 0) 平时先把手点击打跑满（等效 10 次/秒）
    [self aiTapBurst];
    // 2) 孢子出现就点
    if (self.sporeActive && self.sporeBtn != nil) [self onSpore];
    // 3) 负面事件可解除时按收益判断是否付钱
    if (self.eventKind > 0 && self.eventCleanseBtn != nil && !self.eventCleanseBtn.hidden
        && self.cleanseCost > 0 && self.energy > self.cleanseCost * 1.6) {
        [self onCleanseEvent];
    }

    BOOL last = (self.stage >= kStageCount - 1);
    double evoCost = 0;
    if (!last) {
        evoCost = kEvolveCost[self.stage + 1] * kEvolveMult * [self difficultyEvoMult]
                * [self evoGeneTax] * [self autoEvoMult];
    }
    if (last) return;

    // 4) 有关卡试炼未过：攒够进化费就主动开战（失败 2 次则不再硬碰）
    if ([self needsBossForStage:self.stage + 1] && _bossFails[self.stage + 1] < 2
        && self.energy >= evoCost && now >= self.aiNextEvolveAt) {
        [self onEvolve];
        self.aiNextEvolveAt = now + 14.0;
        return;
    }
    // 5) 能进化且离上次进化 ≥14s（避免触发"进化过快"惩罚）
    if (![self needsBossForStage:self.stage + 1] && evoCost > 0
        && self.energy >= evoCost && now >= self.aiNextEvolveAt) {
        [self onEvolve];
        self.aiNextEvolveAt = now + 14.0;
        return;
    }
    // 6) 已经摸到进化费 85% 才停手攒钱，其余时候一直把能量投成产能
    if (evoCost > 0 && self.energy >= evoCost * 0.85) return;
    NSInteger best = [self bestRowIndex];
    if (best < 0) return;                       // 连最便宜的 1 个都买不起 → 等能量

    // 花销上限：默认花掉 90%，只有能量已远超进化费时才花光（避免能量永远显示 0）
    double spendCap = self.energy * 0.90;
    if (evoCost > 0 && self.energy >= evoCost * 1.6) spendCap = self.energy;

    NSInteger n = 0;
    double total = 0.0;
    while (n < 5000) {
        double c = [self costFor:best owned:_counts[best] + n count:1];
        if (c <= 0 || total + c > spendCap) break;
        total += c;
        n += 1;
    }
    if (n < 1) return;
    self.energy -= total;
    _counts[best] += n;
    [self refreshDynamic];
    [self refreshRows];
}

- (void)onReset {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"重置存档" message:@"将清空所有进度，包括 DNA 和飞升次数。确定吗？" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [ac addAction:[UIAlertAction actionWithTitle:@"全部重置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        self.energy = 0; self.shownEnergy = 0; self.runEarned = 0; self.stage = 0; self.combo = 1;
        self.dna = 0; self.ascensions = 0; self.offlineUnlocked = NO; self.geneLevel = 0;
        self.geneTapLevel = 0; self.geneSporeLevel = 0; self.geneAutoLevel = 0; self.geneOfflineLevel = 0;
        self.geneAscendLevel = 0; self.geneStartLevel = 0; self.geneSporeRateLevel = 0; self.geneBossLevel = 0;
        self.totalEarned = 0;
        self.maxStage = 0; self.relicPoints = 0; self.totalTaps = 0;
        // 自适应难度/反噬累积必须一起归零，否则"重置存档"后压力仍残留（v7.5.4 修复）
        self.autoDiff = 0; self.fastEvoCount = 0; self.bossRushCount = 0;
        for (NSInteger i = 0; i < 64; i++) _bossFails[i] = 0;
        for (NSInteger i = 0; i < kRelicCount; i++) _relicLv[i] = 0;
        for (NSInteger i = 0; i < 64; i++) { _bossDoneRound[i] = NO; _bossDone[i] = NO; }
        for (NSInteger i = 0; i < 8; i++) _achDone[i] = NO;
        for (NSInteger i = 0; i < kStageCount; i++) _bossDone[i] = NO;

        // 彻底抹掉所有 v3_* 存档键，避免遗漏字段（如 bossfail/bossr/autodiff）在重置后残留
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        for (NSString *k in [[ud dictionaryRepresentation] allKeys]) {
            if ([k hasPrefix:@"v3_"]) [ud removeObjectForKey:k];
        }
        [self clearFeeds];
        for (NSInteger i = 0; i < kStageCount; i++) _counts[i] = 0;
        for (NSInteger i = 0; i < MutKinds; i++) _muts[i] = 0;
        [self applyTheme:YES];
        [self rebuildRows];
        [self refreshAll];
        [self saveState];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)toast:(NSString *)text {
    CGFloat W = self.view.bounds.size.width;
    UILabel *t = [[UILabel alloc] init];
    t.text = text;
    t.font = [UIFont boldSystemFontOfSize:14];
    t.textColor = [UIColor whiteColor];
    t.backgroundColor = [UIColor colorWithWhite:0 alpha:0.78];
    t.textAlignment = NSTextAlignmentCenter;
    t.layer.cornerRadius = 14;
    t.clipsToBounds = YES;
    t.numberOfLines = 2;
    [t sizeToFit];
    CGFloat tw = MIN(W - 40, t.bounds.size.width + 32);
    CGFloat H = self.view.bounds.size.height;
    t.frame = CGRectMake((W - tw) / 2, H - 150, tw, MAX(34, t.bounds.size.height + 14));
    t.alpha = 0;
    [self.view addSubview:t];
    [UIView animateWithDuration:0.25 animations:^{ t.alpha = 1; } completion:^(BOOL f) {
        [UIView animateWithDuration:0.4 delay:1.8 options:0 animations:^{ t.alpha = 0; } completion:^(BOOL f2) { [t removeFromSuperview]; }];
    }];
}


// ================= 音效 =================
- (AVAudioPCMBuffer *)sfxBufferWithNotes:(NSArray<NSArray<NSNumber *> *> *)notes total:(double)total gain:(double)gain {
    AVAudioFormat *fmt = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:1];
    AVAudioFrameCount frames = (AVAudioFrameCount)(total * 44100.0);
    AVAudioPCMBuffer *buf = [[AVAudioPCMBuffer alloc] initWithPCMFormat:fmt frameCapacity:frames];
    if (buf == nil) return nil;
    buf.frameLength = frames;
    float *ch = buf.floatChannelData[0];
    for (AVAudioFrameCount i = 0; i < frames; i++) ch[i] = 0;
    for (NSArray<NSNumber *> *n in notes) {
        double f = n[0].doubleValue, st = n[1].doubleValue, d = n[2].doubleValue;
        NSUInteger i0 = (NSUInteger)(st * 44100.0);
        NSUInteger i1 = MIN((NSUInteger)frames, (NSUInteger)((st + d) * 44100.0));
        for (NSUInteger i = i0; i < i1; i++) {
            double t = (double)(i - i0) / 44100.0;
            double env = exp(-5.5 * t / d);
            if (t < 0.004) env *= t / 0.004;
            ch[i] += (float)(sin(2.0 * M_PI * f * t) * env * gain);
        }
    }
    return buf;
}

- (void)setupSFX {
    self.sfxBuffers = [NSMutableDictionary dictionary];
    // 点击：短促木琴"哒"
    self.sfxBuffers[@"tap"]  = [self sfxBufferWithNotes:@[@[@520, @0, @0.045]] total:0.055 gain:0.16];
    // 暴击：两声高音
    self.sfxBuffers[@"crit"] = [self sfxBufferWithNotes:@[@[@880, @0, @0.06], @[@1320, @0.045, @0.075]] total:0.125 gain:0.20];
    // 购买：轻快双音
    self.sfxBuffers[@"buy"]  = [self sfxBufferWithNotes:@[@[@660, @0, @0.05], @[@990, @0.045, @0.06]] total:0.11 gain:0.15];
    // 进化：上行三音
    self.sfxBuffers[@"evolve"] = [self sfxBufferWithNotes:@[@[@523, @0, @0.14], @[@659, @0.13, @0.14], @[@784, @0.26, @0.20]] total:0.50 gain:0.17];
    // 飞升：四音上行和弦
    self.sfxBuffers[@"ascend"] = [self sfxBufferWithNotes:@[@[@392, @0, @0.28], @[@523, @0.12, @0.28], @[@659, @0.26, @0.30], @[@784, @0.40, @0.45]] total:0.95 gain:0.18];
    // 时代事件：低沉轰鸣
    self.sfxBuffers[@"event"] = [self sfxBufferWithNotes:@[@[@96, @0, @0.30], @[@72, @0.16, @0.40], @[@140, @0.42, @0.22]]
                                                   total:0.78 gain:0.20];
    // 孢子：清脆铃音
    self.sfxBuffers[@"spore"] = [self sfxBufferWithNotes:@[@[@1568, @0, @0.09], @[@2093, @0.045, @0.11]] total:0.22 gain:0.16];

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryAmbient error:nil];
    [session setActive:YES error:nil];

    AVAudioFormat *fmt = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:1];
    self.sfxEngine = [[AVAudioEngine alloc] init];
    self.sfxNode = [[AVAudioPlayerNode alloc] init];
    [self.sfxEngine attachNode:self.sfxNode];
    [self.sfxEngine connect:self.sfxNode to:self.sfxEngine.mainMixerNode format:fmt];
    self.sfxEngine.mainMixerNode.outputVolume = 0.9;
    NSError *err = nil;
    self.sfxReady = [self.sfxEngine startAndReturnError:&err];
}

- (void)playSFX:(NSString *)key {
    if (!self.sfxReady) return;
    AVAudioPCMBuffer *buf = self.sfxBuffers[key];
    if (buf == nil) return;
    if (!self.sfxEngine.isRunning) {
        NSError *err = nil;
        if (![self.sfxEngine startAndReturnError:&err]) return;
    }
    [self.sfxNode scheduleBuffer:buf atTime:nil options:AVAudioPlayerNodeBufferInterrupts completionHandler:nil];
    if (!self.sfxNode.isPlaying) [self.sfxNode play];
}

@end
