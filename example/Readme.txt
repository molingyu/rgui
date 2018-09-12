
RGDirect Version 1.2.1
Copyright (C) 2018 invwindy / fux2

# =======================================================================
# 简介 / Introduction
# =======================================================================

RGDirect (RGD) 是对 RPG Maker VX Ace (RMVA) 的脚本系统 RGSS3 的部分重新实现和功能扩展。它的主要作用是提升游戏的绘图效率、增强绘图扩展性，同时修正一些存在于原版 RGSS3 的漏洞。

RGD 使用 DirectX9 重新实现了 RGSS3 的 Bitmap, Graphics, Viewport, Sprite, Tilemap 和 Plane 绘图相关类和模块，利用 GPU 资源，使得绘制大地图、大图片、较多旋转缩放精灵的时候足够高效，杜绝了原版 RGSS 的卡顿现象。RGD 内置了 Sprite 和 Viewport 的 shader 接口，可以很方便地添加实时计算的自定义特效代码。位图操作方面，RGD 在实现原有操作的基础上，文字绘制内置了采用像素字的选项，可以不依赖外部 DLL 绘制像素字体。在图像绘制之外，RGD 加入了鼠标输入的功能，可以使用 Mouse 模块方便地获取鼠标的位置和按键状态。

这项工作由我和 Fux2 共同完成。Fux2 负责所有 C++ 代码和 Ruby 交互、Ruby 对象处理以及描绘文字相关的功能，我负责 D3D 绘图相关的功能。感谢 Mayaru 绘制了 RGD 的形象和图标文件。

如果有任何询问或意见，请发送邮件到 cirno@live.cn。

RGDirect (RGD) is a partial reimplementation and functional extension of the script system of RPG Maker VX Ace (RMVA), RGSS3. The main purporse of this project is to enhance the rendering efficiency, expansibility and to fix some bugs on original RGSS3.

RGD reimplements graphical classes and modules in RGSS3, Bitmap, Graphics, Viewport, Sprite, Tilemap and Plane, using DirectX9 technique. The performance for drawing maps, images of large size and scaling, rotating sprites of large number with GPU is greatly higher compared to the lag in RGSS3. RGD has a built-in shader interface in Sprites and Viewports which is used for real-time custom effect code. On bitmap operations, besides the operators in RGSS3, RGD implements built-in pixel font option without using external DLLs. In addition, RGD implements mouse input. You may use module Mouse to get mouse position and button status easily.

This work is completed by Fux2 and me. Fux2 completed all the communications between C++ and ruby, and functions on drawing texts. I completed the functions related to D3D rendering. Many thanks to Mayaru for drawing the character and icons of RGD.

If you have any questions or advice, please send email to cirno@live.cn.

# =======================================================================
# 使用约定 / Terms of Use
# =======================================================================

RGDirect 可以在 RPG Maker VX Ace 制作的非商业或商业游戏中使用。

请勿用于违反相关国家法律法规的用途，请勿用于伤害他人的合理合法权益。

请勿以制作者之外的其他名义二次发布 RGDirect。

RGDirect 的开发者不对使用过程中和使用后的任何问题负责。

如果出现任何冲突，以相关法律法规、Enterbrain 公司的官方规定为准。

RGDirect is permitted to use in non-commercial or commercial games made with RPG Maker VX Ace.

Do not use RGDirect in violating the laws and regulations of related countries, and do not use it to harm the legitimate rights and interests of other people.

Do not republish RGDirect outside the name of the developers.

Developers on RGDirect are not responsible for any problems during and after use.

In the event of any conflict, laws and regulations of related countries, and the official instructions from Enterbrain Corporation shall prevail.

# =======================================================================
# 更多信息 / More Information
# =======================================================================

https://cirno.mist.so/archives/290
