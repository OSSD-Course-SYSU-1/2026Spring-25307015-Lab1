# DecodePlayControl 项目文档

## 项目概述

**DecodePlayControl** 是一个基于HarmonyOS的视频播放控制应用，支持多视频切换、播放控制（播放/暂停/恢复/速度调整/Seek）、全屏模式。该应用采用ArkTS（前端UI和逻辑）和C++（原生媒体处理）混合开发架构，利用HarmonyOS原生媒体API实现高效视频解码和渲染。

- **版本**：1.0.0
- **包名**：com.example.decodeplaycontrol
- **目标设备**：手机
- **主要功能**：视频播放、解码控制、渲染显示

## 架构说明

项目遵循HarmonyOS模块化架构：
- **前端（ArkTS）**：负责UI界面、用户交互和状态管理。
- **后端（C++）**：负责底层媒体解码、播放控制和渲染。
- **桥接**：通过NAPI（Native API）实现ArkTS与C++的互操作。
- **构建工具**：使用hvigor进行编译打包，生成`.hap`应用包。

整体流程：用户通过ArkTS界面操作 → 视图模型调用C++播放器 → C++处理解码/渲染 → 结果反馈到UI。

## 模块功能详解

### 1. 根目录和配置模块
- **build-profile.json5**：全局构建配置，定义编译目标、签名等。
- **hvigorfile.ts**：构建脚本，管理编译流程和依赖。
- **oh-package.json5**：包管理，声明依赖库（如@kit.PerformanceAnalysisKit）。
- **app.json5**：应用级配置，包括包名、版本、图标、标签。
- **hvigor-config.json5**：hvigor工具的配置。
- **oh_modules/**：全局依赖存储（不提交，由包管理器安装）。
- **.gitignore**：忽略规则，确保不提交构建产物和临时文件。

### 2. entry/ 主模块
应用的入口模块，包含所有核心代码。

#### 2.1 配置和资源
- **build-profile.json5**：模块构建配置。
- **hvigorfile.ts**：模块构建脚本。
- **oh-package.json5** 和 **oh-package-lock.json5**：模块依赖管理。
- **module.json5**：模块定义，配置EntryAbility（主能力）和EntryBackupAbility（备份能力）。
- **entry/src/main/resources/**：模块资源，包括：
  - `base/element/string.json`：字符串资源。
  - `base/media/`：媒体资源（如图标）。
  - `en_US/element/` 和 `zh_CN/element/`：多语言支持。
  - `dark/element/` 和其他：主题资源。
  - `rawfile/`：原始文件（如视频资源）。

#### 2.2 ArkTS 前端代码 (entry/src/main/ets/)
- **common/**：
  - **CommonConstants.ets**：定义常量，如默认播放速度（Const.VIDEO_DEFAULT_SPEED）。
  - **TimeUtils.ets**：时间格式化工具，提供`getShowTime`函数将毫秒转换为显示格式。
- **entryability/EntryAbility.ets**：应用入口能力，处理应用启动、窗口管理和生命周期事件。
- **entrybackupability/EntryBackupAbility.ets**：备份能力，支持应用数据备份和恢复。
- **model/PlayerStateModel.ets**：播放状态枚举模型，包括IDLE、PLAYING、PAUSED等状态。
- **pages/Index.ets**：主页面组件（@Entry装饰器），负责加载视频资源（1.mp4、2.mp4、3.mp4），管理全屏状态，并渲染VideoPlayView。
- **view/VideoPlayView.ets**：视频播放视图组件，处理UI布局、用户交互（如播放按钮、全屏切换），并绑定视图模型。
- **viewmodel/VideoPlayViewModel.ets**：视图模型类（@Observed），管理播放逻辑：
  - 状态变量：播放状态、当前时间、总时长、速度、Seek状态等。
  - 方法：初始化播放器、播放/暂停/恢复、设置速度、Seek、清理资源。
  - 与C++交互：通过`libplayer.so`调用原生播放器。

#### 2.3 C++ 原生代码 (entry/src/main/cpp/)
- **CMakeLists.txt**：构建脚本，编译共享库`libplayer.so`，链接HarmonyOS媒体库（如libnative_media_core.so）。
- **capabilities/**：媒体处理能力。
  - **AudioDecoder.h/cpp**：音频解码器，实现音频流解码。
  - **VideoDecoder.h/cpp**：视频解码器，实现视频流解码。
  - **Demuxer.h/cpp**：媒体解复用器，从媒体文件中分离音视频流。
  - **CodecCallback.h/cpp**：编解码回调，处理解码事件和错误。
- **common/**：公共定义。
  - **SampleInfo.h**：媒体样本信息结构体。
  - **AudioSampleInfo.h/VideoSampleInfo.h**：音频/视频样本详情。
  - **MediaError.h**：错误码定义。
  - **MediaLog.h**：日志工具。
- **player/**：播放器核心。
  - **Player.h/cpp**：主播放器类，实现播放控制：
    - 方法：Init（初始化）、Start（开始）、Pause（暂停）、Resume（恢复）、SetSpeed（设置速度）、Seek（跳转）、GetRenderTimeStamp（获取渲染时间戳）。
    - 线程：VideoDecInputThread（视频解码输入）、VideoDecOutputThread（输出）、AudioDecInputThread（音频输入）等。
  - **PlayerNative.h/cpp**：原生接口，桥接ArkTS和C++，提供NAPI函数供前端调用。
- **render/**：渲染引擎。
  - **XComponentManager.h/cpp**：XComponent管理器，管理HarmonyOS的XComponent组件。
  - **XComponentRender.h/cpp**：视频渲染器，将解码后的视频帧渲染到XComponent上。
- **types/libplayer/Index.d.ts** 和 **oh-package.json5**：TypeScript类型定义和包配置，用于ArkTS导入C++库。

#### 2.4 构建输出 (entry/build/)
- **intermediates/**：中间文件，如CMake对象、资源合并、源码映射。
- **outputs/**：最终产物，包括`entry-default-unsigned.hap`（未签名应用包）和`pack.info`。

### 3. 其他目录
- **screenshots/**：应用截图，用于文档或应用商店展示。
- **LICENSE** 和 **OAT.xml**：开源许可证和合规文件。

## 关键组件功能
- **播放控制**：通过VideoPlayViewModel管理播放状态，支持多视频切换、速度调整（0.5x-2x）、进度Seek。
- **解码和渲染**：C++层使用HarmonyOS媒体API进行硬件加速解码，渲染到XComponent。
- **UI交互**：ArkTS处理触摸事件、全屏切换、进度条更新。
- **状态同步**：视图模型使用@Track和@ObjectLink实现响应式更新。
- **错误处理**：日志记录（hilog）和错误回调，确保稳定性。

## 构建和运行
1. **环境要求**：HarmonyOS SDK、DevEco Studio。
2. **安装依赖**：运行`ohpm install`。
3. **构建**：使用hvigor构建，生成.hap包。
4. **运行**：安装到HarmonyOS设备，启动应用加载视频并播放。
5. **调试**：使用hilog查看日志，检查播放状态。

此文档基于代码分析生成，如需更新，请参考最新源码。