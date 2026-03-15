#!/usr/bin/env python3
"""Clean Vivaldi bookmarks and sync to Safari.

Vivaldi's bookmark_bar has this structure:
  Bookmarks (bookmark_bar)
  ├── Home (Vivaldi default)
  ├── Shopping (Vivaldi default)
  ├── Travel (Vivaldi default)
  ├── Bookmarks [16] (Vivaldi default with Vivaldi subfolder)
  ├── Bookmarks [33+] (user content — Website, AI, Cloud, etc.)
  ├── Other bookmarks
  └── possibly empty folders from prior cleanup

This script extracts ONLY user content from the inner Bookmarks folder
that contains Website/crosswall/AI/etc, skipping Vivaldi defaults and
Edge imports, then syncs to Safari.
"""
import json, plistlib, uuid, os, subprocess, re

VIVALDI = os.path.expanduser(
    "~/Library/Application Support/Vivaldi/Default/Bookmarks")
SAFARI = os.path.expanduser("~/Library/Safari/Bookmarks.plist")

# ── Vivaldi default folder names to skip ──
SKIP_FOLDERS = {
    "Home", "Vivaldi",
    "Imported from Microsoft Edge Profile 1.",
    "Imported from Microsoft Edge 用户配置 1.",
    "Other bookmarks",
}

# ── Name shortening ──
EXPLICIT = {
    "Sci-Hub":"Sci-Hub","n8n-io/n8n":"n8n","pppscn/SmsForwarder":"SmsForwarder",
    "0nn0/terminal-mac-cheatsheet":"Mac终端速查",
    "kelseyhightower/kubernetes":"K8s Hard Way",
    "blackmatrix7/ios_rule_script":"ios分流规则",
    "AlexiaChen/YinWangBak":"王垠文集",
    "liminbai/Awesome-GameEmulator":"游戏模拟器合集",
    "GalaxyXieyu/didatodolist":"滴答清单MCP",
    "getsomecat/GetSomeCats":"GetSomeCats",
    "Kiritocyz/Clash":"Clash脚本模板",
    "zqq-nuli/auto-audio-book":"AI有声书",
    "clashmeta.yaml":"ClashMeta配置",
    "raw.githubusercontent":"Clash Override",
    "LPT: Don't minimize":"LPT:做社交发起者",
    "LPT: Instead of say":"LPT:说谢谢等待",
    "LPT: Feeling stuck":"LPT:写信给自己",
    "LPT: If you ever":"LPT:社交从提问开始",
    "LPT: Find 100":"LPT:按和弦找歌",
    "What's one social":"让人讨喜的社交技巧",
    "What\u2019s one social":"让人讨喜的社交技巧",
    "Why is it always":"社交悖论",
    "I Ghosted Everyone":"30岁孤独反思",
    "Is China still doing":"维吾尔问题讨论",
    "Adding a user with sudo":"JupyterHub sudo",
    "The resume that got":"Google 300K简历",
    "iPadOS/iOS/macOS26 解锁":"NSRingo解锁",
    "快时尚电商行业智能体":"Claude SDK部署",
    "AmEx Blue Cash":"AmEx BCP",
    "Internet Archive":"Internet Archive",
    "Chatbot Arena":"Chatbot Arena",
    "Coding Without a Laptop":"AR眼镜编程",
    "Fine-Tuning a Vision":"微调Qwen2-VL",
    "Fine-Tuning | Quantize":"微调Qwen2-VL",
    "Demystifying Kolmog":"KAN入门",
    "Kalmogorov-Arnold":"KAN-IEEE",
    "neural networks - What":"Attention K/Q/V",
    "I don't know how CPU":"CPU模拟器",
    "How Postgres stores":"Postgres存储原理",
    "Regex Chess":"Regex Chess",
    "Be A Property Owner":"做互联网房东",
    "Custom Hand-drawn":"StoryMotion",
    "The New Skill in AI":"AI Context Eng.",
    "Nerd Fonts - Iconic":"Nerd Fonts",
    "Speedtest by Ookla":"Speedtest",
    "IP/DNS Detect":"IP/DNS Detect",
    "ITDOG - 在线":"ITDOG测速",
    "Ping, mtr, dig":"多点Ping/MTR",
    "[摩集电商]":"摩集电商MBP",
    "OS X Daily":"OS X Daily",
    "Relume —":"Relume AI建站",
    "vibe了一个一键批量":"Amazon S&S取消",
    "2026 年还能正常":"100+网盘搜索",
    "【长期更新】汇总":"Cherry Studio合集",
    "Airline Seat Maps":"SeatGuru",
    "Best Mac Apps":"Best Mac Apps",
    "Input Source Pro":"Input Source Pro",
    "Marius Hosting":"Marius Hosting",
    "MacRumors Buyer":"MacRumors指南",
    "DeepWiki | AI":"DeepWiki",
    "The Rust Programming":"Rust编程语言",
    "Engineering.fyi":"Engineering.fyi",
    "Transfer Playlists":"Tune My Music",
    "Doctor Of Credit":"Doctor Of Credit",
    "How to Grow Professional":"拓展职业人脉",
    "Invoke | Generative":"Invoke AI",
    "GPT Learning Hub":"GPT Learning Hub",
    "The GW Career":"GW Career Center",
    "Vibe-Coding as a VC":"Vibe Coding VC",
    "Zero to Mastery":"PyTorch入门",
    "2023 Online US Tax":"海外报税软件",
    "Appointments | Colum":"GWU预约",
    "6 Techniques I Use":"Shell脚本UX",
    "nixCraft - Linux":"nixCraft",
    "A Mathematical Frame":"Transformer数学",
    "Search for Charts":"数据可视化图表检索",
    "Rules for Writing":"写技术教程规则",
    "The Structure of a PDF":"PDF文件结构",
    "Dive into Deep":"动手学深度学习",
    "2021年新教程":"Obsidian中文教程",
    "Collector of Revenue":"St.Louis税收",
    "Indiana Taxpayer":"Indiana税务",
    "I'm Switching to Python":"转投Python",
    "AI QR Code":"AI QR生成器",
    "Working Class Deep":"Working Class DL",
    "Can't Get Much":"Can't Get Higher",
    "Focused and Diffuse":"专注vs发散思维",
    "Git Cheat Sheet":"Git速查表",
    "git-cheat-sheet-edu":"Git速查表",
    "git-cheat-sheet.pdf":"Git速查表PDF",
    "Graphical vi-vim":"Vim速查表",
    "Markdown Cheat":"Markdown速查",
    "Tmux Cheat Sheet":"Tmux速查表",
    "County of Orange":"OC税务",
    "Corporate Filing":"Missouri公司注册",
    "Missouri Business":"Missouri商业注册",
    "Account Information":"Citi Online",
    "Member Center | Blue":"Blue Shield CA",
    "Online Medical":"在线问诊",
    "#UNTAG - We think":"UNTAG",
    "Celestial Heavens":"英雄无敌-CH",
    "TopVPS.Info":"TopVPS",
    "ESTKme Technology":"ESTKme eSIM",
    "Duolingo - The":"Duolingo日语",
    "Lenny's Newsletter":"Lenny's NL",
    "Cool Papers":"Cool Papers",
    "Science and Math":"Quanta Magazine",
    "The Platonic":"Platonic表征假说",
    "Max Rewards vs":"Max vs CardPointers",
    "Diablo 3 Season":"Diablo3天梯",
    "Escaping Flatland":"Escaping Flatland",
    "Chipstrat | Austin":"Chipstrat",
    "My Obsidian Note":"Obsidian工作流",
    "DavidZ's Blog":"DavidZ Blog",
    "Mac App Comparisons":"Mac App对比2025",
    "Aplia :: Engage":"Aplia",
    "Psychology Research":"心理学研究",
    "Sign in to Business":"Business Banking",
    "字幕转换器":"字幕格式转换",
    "英雄世界":"英雄无敌-HW",
    "The Ultimate Vibe":"Vibe Coding指南",
    "Qwen3.5 Fine-tuning":"Qwen3.5微调",
    "OpenClaw飞书":"OpenClaw飞书",
    "Rust/DIRECTORY":"Rust算法大全",
    "使用Surge规则脚本":"Surge规则自动化",
    "Rabbit-Spec/Surge":"Surge配置脚本",
    "Surge 模块与脚本":"Surge代理模块",
    "Surge Ponte 实现":"Surge Ponte",
    "利用私有 Gist":"Gist同步Surge/QX",
    "使用dae为Docker":"dae Docker代理",
    "分享一个群晖部署":"群晖WireGuard",
    "说几个在泥潭国旅游":"日本省钱tips",
    "【教育无国界】":"免费edu教程",
    "恶意软件分析":"恶意软件分析",
    "【家里云】":"HomeLab入门",
    "MacOS26 快捷指令":"macOS26快捷指令",
    "请教一下 mac":"Mac必装App",
    "chrome://net":"Chrome DNS工具",
    "Claude for Chrome":"Claude Chrome",
    "赛博电子人的软件库":"赛博软件库",
    "Clash verge 流量":"Clash流量规则",
    "【分享】Jet Brains":"JetBrains激活",
    "Office Tool Plus":"Office Tool Plus",
    "日本配全定制":"日本定制眼镜",
    "用钱能买到":"微光夜视仪",
    "腕表：从入门":"腕表入门",
    "Kai丨【2024":"眼镜选购",
    "降低防御性沟通":"降低防御性沟通",
    "【教程】苹果手机":"iPhone侧载",
    "欢迎加入 HamCQ":"HamCQ无线电",
    "双持Megathread":"双持全解",
    "【加密货币】":"币圈黑话",
    "Obsidian 中文论坛":"Obsidian中文",
    "分享一个自己梳理":"计算机基础全梳理",
    "Get started | Learn":"Learning Synths",
    "Follow 公测了":"Follow推荐订阅",
    "分享 Follow":"Follow订阅分享",
    "看看你的 iPhone":"iPhone锁屏入口",
    "（水帖）泥潭":"泥潭常用工具",
    "追影追剧新方式":"Emby公益服",
    "分享一个自用的clash":"Clash自定义节点",
    "精选提示词库":"Awesome Prompts",
    "Vibe Coding教程":"Vibe Coding教程",
    "JS逆向学习":"JS逆向入门",
    "JS逆向技巧":"JS逆向实战",
    "How to set an icon":"Mac文件图标",
    "前言 | 深入高":"深入高可用系统",
    "Docker 搭建微信":"Docker微信机器人",
    "Ghostty Config":"Ghostty配置",
    "0 - 概述 - Modern":"图形引擎指南",
    "How to Vulkan":"Vulkan 2026",
    "Vulkan Resources":"Vulkan资源",
    "hkdmit.likegears":"DMIT HK",
    "人 X 社区":"niracler社区",
    "My HomeLab":"HomeLab服务",
    "自己动手写":"手写Git",
    "简介 | MIT6":"MIT 6.S081",
    "首页 | Yuzai":"Yuzai Blog",
    "Windows各类别":"Windows最强软件",
    "基于 WSL2":"WSL2深度学习",
    "iOS 17老人":"iPhone长辈模式",
    "settings / appearance":"cobalt外观",
    "North America":"北美票帝",
    "北美票帝":"北美票帝",
    "Nix 与 NixOS":"NixOS Flakes",
    "Introduction · macOS":"macOS Setup",
    "Introduction · Reverse":"逆向工程入门",
    "Cockpit Project":"Cockpit",
    "云图 – 云计算":"云图CloudAtlas",
    "KQV attention":"KQV Attention",
    "The Data Visuali":"数据可视化目录",
    "TJX Rewards":"TJX Mastercard",
    "Crate and Barrel":"Crate&Barrel卡",
    "Brooks Brothers":"Brooks Brothers卡",
    "Irvine Ranch Water":"Irvine水务",
    "indiana Payments":"Indiana缴税",
    "Google Cloud在线":"Google Ping测速",
    "ASN查询":"ASN/IP查询",
    "DigVPS":"DigVPS",
    "洛杉矶有什么":"洛杉矶美食",
    "通信人家园":"通信人家园",
    "Developer Roadmaps":"roadmap.sh",
    "Teach Yourself":"自学CS",
    "ASUS Wireless":"ASUS GT-AX11000",
    "Gregory Szorc":"Gregory Szorc",
    "在一台VPS":"单VPS部署K8s",
    "【新手攻略】":"里程票入门",
    "Steam Trading":"Steam挂刀行情",
    "Google AI Studio":"Google AI Studio",
    "cantrip.org":"cantrip排序",
    "AeroLOPA":"AeroLOPA选座",
    "README - Everything":"Everything curl",
    "科学空间|":"科学空间",
    "Home | drew":"drew's blog",
    "記載著 Will":"Will Will Web",
    "Python Tutorials":"Real Python",
    "Coursera | OC":"Coursera(OC)",
    "W3Schools Online":"W3Schools",
    "Path Finding":"GraphAcademy",
    "College Central":"College Central",
    "Client Area - DMIT":"DMIT",
    "Healthy Paws":"宠物保险",
    "Home | Federal":"Federal学生贷款",
    "PHP: Hypertext":"PHP官网",
    "Home | Orange Coast":"OCC",
    "MyLab / Mastering":"MyLab/Mastering",
    "Arkansas Secretary":"Arkansas注册",
    "IBM SPSS":"IBM SPSS",
    "Projects · Dashboard":"GitLab Projects",
    "掌握这人生开挂":"人生开挂18招",
    "daixiaobang":"daixiaobang",
    "Synology723":"Synology NAS",
    "Proxy SwitchyOmega":"SwitchyOmega教程",
    "subconverter/":"subconverter",
    "mack-a/v2ray":"v2ray八合一",
    "都是 V 友":"iPhone去广告",
    "ddgksf2013":"ddgksf2013",
    "这是一个机场推荐":"机场推荐",
    "重新开贴，机场":"机场订阅分享",
    "⭐LangGPT":"LangGPT提示词",
    "通往 AGI":"通往AGI之路",
    "Skills for All":"Cisco Skills",
    "购买订阅 - EdNovas":"EdNovas云",
    "American Express":"AmEx登录",
    "My files - OneDrive":"OneDrive",
    "My Drive - Google":"Google Drive",
    "Google Cloud console":"Google Cloud",
    "Cloudflare Dash":"Cloudflare",
    "American Funds":"American Funds",
    "Covered California":"Covered CA",
    "Kaiser Permanente":"Kaiser",
    "University of Missouri":"UMSL",
    "Banner Secured":"Banner",
    "Linksys Smart":"Linksys路由",
    "pet spa Customer":"宠物SPA",
    "Home Warranty":"Home Warranty",
    "homeowner portal":"HOA业主",
    "California DMV":"CA DMV",
    "Omni Management":"Omni Management",
    "Medium – Where":"Medium",
    "Nordstrom Card":"Nordstrom卡",
    "Walgreens Credit":"Walgreens卡",
    "Your MSD Account":"MSD Account",
    "全球主机交流论坛":"全球主机论坛",
    "博客园 - 开发者":"博客园",
    "Home | Costco":"Costco Travel",
    "Let's talk about PrEP":"STI预防科普",
    "The GW Career Center":"GW Career Center",
}

STRIP = [
    r"\s*[-–—|·]\s*(LINUX DO|V2EX|美卡论坛|Medium|Substack|IEEE).*$",
    r"\s*[-–—]\s*(搞七捻三|资源荟萃|开发调优|文档共建|软件分享|败家|旅行|生活|法律|闲聊).*$",
    r"\s*\|\s*by\s+\w+.*$", r"\s*:\s*r/\w+$", r"\s*<span.*$",
]


def shorten(name):
    if name.startswith("GitHub - "):
        name = name[9:]
    for prefix, short in EXPLICIT.items():
        if name.startswith(prefix):
            return short
    for pat in STRIP:
        name = re.sub(pat, '', name, flags=re.I)
    if len(name) > 20:
        for sep in [' | ', ' — ', ' – ', ' · ', ' - ']:
            if sep in name:
                parts = name.split(sep)
                if 4 <= len(parts[0]) <= 20:
                    name = parts[0]
                    break
                elif 4 <= len(parts[-1]) <= 20:
                    name = parts[-1]
                    break
    if len(name) > 20:
        name = name[:17] + "..."
    return name.strip()


def shorten_all(node):
    if node.get('type') == 'url':
        node['name'] = shorten(node['name'])
    for c in node.get('children', []):
        shorten_all(c)


# ── Dedup ──
def dedup(children):
    seen = set()
    out = []
    for c in children:
        if c.get('type') == 'url':
            u = c.get('url', '')
            if u not in seen:
                seen.add(u)
                out.append(c)
        elif c.get('type') == 'folder':
            c['children'] = dedup(c.get('children', []))
            out.append(c)
        else:
            out.append(c)
    return out


# ── Extract user bookmarks from Vivaldi ──
def find_folder(node, name):
    for c in node.get('children', []):
        if c.get('type') == 'folder' and c.get('name') == name:
            return c
    return None


def extract_user_bookmarks(vdata):
    """Return list of user bookmark folders, skipping Vivaldi defaults.

    Handles two structures:
    1. Nested: bookmark_bar > ... > Bookmarks(with Website/AI/etc)
    2. Flat: bookmark_bar has user folders directly (Favo, AI, Cloud, etc.)
    """
    bar = vdata['roots']['bookmark_bar']

    # Check if already flat (user folders directly on bar)
    direct_user = [c for c in bar.get('children', [])
                   if c.get('type') == 'folder'
                   and c.get('name') in (
                       'Favo', 'Website', 'AI', 'Cloud', 'crosswall', 'Forum',
                       'Tools', 'Learning', 'Work', 'Blog', 'Video', 'Shopping',
                       'Credit Card', 'Investment & Insurance', 'Utility & House ',
                       'Travel', 'Legal & Tax', 'College', 'Tips', 'Miscellany')]
    if direct_user:
        # Flat structure — bar has user folders directly
        source = bar
    else:
        # Nested structure — find inner Bookmarks folder
        source = None
        for child in bar.get('children', []):
            if (child.get('type') == 'folder'
                    and child.get('name') == 'Bookmarks'
                    and (find_folder(child, 'Website')
                         or find_folder(child, 'crosswall')
                         or find_folder(child, 'AI'))):
                source = child
                break
        if not source:
            print("WARNING: Cannot find user bookmarks folder")
            return []

    # Collect user folders, skip imports and Vivaldi defaults
    user_folders = []
    for child in source.get('children', []):
        if child.get('type') == 'folder':
            if child.get('name') in SKIP_FOLDERS:
                continue
            if 'Imported' in child.get('name', ''):
                continue
            user_folders.append(child)

    # Dedup and shorten within each folder
    for f in user_folders:
        f['children'] = dedup(f.get('children', []))
    for f in user_folders:
        shorten_all(f)

    return user_folders


# ── Safari conversion ──
def new_uuid():
    return str(uuid.uuid4()).upper()


def to_safari(node):
    """Convert Vivaldi node to Safari plist format."""
    if node.get('type') == 'url':
        return {
            'WebBookmarkType': 'WebBookmarkTypeLeaf',
            'WebBookmarkUUID': new_uuid(),
            'URLString': node.get('url', ''),
            'URIDictionary': {'title': node.get('name', '')},
        }
    elif node.get('type') == 'folder':
        children = []
        for child in node.get('children', []):
            c = to_safari(child)
            if c:
                children.append(c)
        return {
            'WebBookmarkType': 'WebBookmarkTypeList',
            'WebBookmarkUUID': new_uuid(),
            'Title': node.get('name', ''),
            'Children': children,
        }
    return None


def count_urls(node):
    n = 0
    if node.get('WebBookmarkType') == 'WebBookmarkTypeLeaf':
        n = 1
    elif node.get('type') == 'url':
        n = 1
    for c in node.get('Children', []) + node.get('children', []):
        n += count_urls(c)
    return n


def sync():
    # Load Vivaldi
    with open(VIVALDI, 'r', encoding='utf-8') as f:
        vdata = json.load(f)

    # Extract user bookmarks only
    user_folders = extract_user_bookmarks(vdata)
    if not user_folders:
        print("No user bookmarks found, aborting")
        return

    # Convert to Safari format
    safari_items = []
    for folder in user_folders:
        converted = to_safari(folder)
        if converted:
            safari_items.append(converted)

    # Load Safari
    subprocess.run(['plutil', '-convert', 'xml1', SAFARI], check=True)
    with open(SAFARI, 'rb') as f:
        sdata = plistlib.load(f)

    # Find or create BookmarksBar
    root_children = sdata.get('Children', [])
    bar_node = next(
        (n for n in root_children if n.get('Title') == 'BookmarksBar'), None)
    if not bar_node:
        bar_node = {
            'WebBookmarkType': 'WebBookmarkTypeList',
            'WebBookmarkUUID': new_uuid(),
            'Title': 'BookmarksBar',
            'Children': [],
        }

    bar_node['Children'] = safari_items

    # Rebuild root: keep History proxy, BookmarksMenu, ReadingList
    new_root = [n for n in root_children
                if n.get('WebBookmarkType') == 'WebBookmarkTypeProxy']
    new_root.append(bar_node)

    menu = next(
        (n for n in root_children if n.get('Title') == 'BookmarksMenu'), None)
    new_root.append(menu or {
        'WebBookmarkType': 'WebBookmarkTypeList',
        'WebBookmarkUUID': new_uuid(),
        'Title': 'BookmarksMenu',
        'Children': [],
    })

    rl = next(
        (n for n in root_children
         if n.get('Title') == 'com.apple.ReadingList'), None)
    if rl:
        new_root.append(rl)

    sdata['Children'] = new_root

    # Save
    with open(SAFARI, 'wb') as f:
        plistlib.dump(sdata, f)
    subprocess.run(['plutil', '-convert', 'binary1', SAFARI], check=True)

    total = sum(count_urls(f) for f in safari_items)
    print(f"Synced {total} bookmarks in {len(safari_items)} folders to Safari")


if __name__ == '__main__':
    sync()
