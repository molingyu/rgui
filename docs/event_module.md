# 事件

`RGUI` 的事件系统是一个修改过的 `trigger/on` 模型。每个 UI 组件都有一个 `event_manager` 实例。

`RGUI` 的事件系统独特之处在于使用 Fiber 来包裹事件回调，从而可以在回调函数里通过 Fiber.yield 来把执行挂起。当事件再次被触发后，则返回到被挂起的地方继续执行。这样的做法给传统的 `trigger/on` 模型赋予了强大的控制能力。从而做到和 FRP 类似的效果。在事件系统里，已经定义了一批利用 Fiber 实现的 Helper 方法。

## 触发
`event_manager#trigger(name, info)` 触发一个事件。 `info` 是一个 `Hash` 实例。一般来说包含 `:old` 和 `:new` 两个键（这不是必须的，不过对于 RGUI 内部触发的事件都会保持这个格式）。

## 回调
一个事件可以有多个回调。通过 `event_manager#on(name){ ... }` 的方式给对应的事件添加回调。 `name` 参数必须为一个 `Symbol` 或 `Symbol` 数组。当为数组时，可以批量的定义回调。

## 事件回调里的 Helper 方法
* `wait`
* `filter`
* `delete`
* `after_delete`
* `time_await`
* `count_await`

## Input 事件
* 鼠标事件
    * `:mouse_in`
    * `:mouse_out`
    * `:mouse_in`
    * `:click`
    * `:double_click`
   
* 键盘事件
    * `keypress_KEYNAME`
    * `keydown_KEYNAME`
    * `keyup_KEYNAME`

`KEYNAME` 表
 
|code|按键|
|----|----|
|`:MOUSE_LB`|鼠标左键|
|`:MOUSE_RB`|鼠标右键|
|`:MOUSE_MB`|鼠标中键|
|`:KEY_BACK`|Back 键|
|`:KEY_TAB`|Tab 键|
|`:KEY_CLEAR`|Clear 键|
|`:KEY_ENTER`|Enter 键|
|`:KEY_SHIFT`|Shift 键|
|`:KEY_CTRL`|Ctrl 键|
|`:KEY_ALT`|Alt 键|
|`:KEY_PAUSE`|Pause 键|
|`:KEY_CAPITAL`|Capital 键|
|`:KEY_ESC`|Esc 键|
|`:KEY_SPACE`|Space 键|
|`:KEY_PRIOR`|Page Up 键|
|`:KEY_NEXT`|Page Down 键|
|`:KEY_END`|End 键|
|`:KEY_HOME`|Home 键|
|`:KEY_LEFT`|Left Arrow 键|
|`:KEY_UP`|Up Arrow 键|
|`:KEY_RIGHT`|Right Arrow 键|
|`:KEY_DOWN`|Down Arrow 键|
|`:KEY_SELECT`|键|
|`:KEY_EXECUTE`|键|
|`:KEY_INS`|Ins 键|
|`:KEY_DEL`|Delete 键|
|`:KEY_HELP`|键|
|`:KEY_0`|数字 0 键|
|`:KEY_1`|数字 1 键|
|`:KEY_2`|数字 2 键|
|`:KEY_3`|数字 3 键|
|`:KEY_4`|数字 4 键|
|`:KEY_5`|数字 5 键|
|`:KEY_6`|数字 6 键|
|`:KEY_7`|数字 7 键|
|`:KEY_8`|数字 8 键|
|`:KEY_9`|数字 9 键|
|`:KEY_A`|A 键|
|`:KEY_B`|B 键|
|`:KEY_C`|C 键|
|`:KEY_D`|D 键|
|`:KEY_E`|E 键|
|`:KEY_F`|F 键|
|`:KEY_G`|G 键|
|`:KEY_H`|H 键|
|`:KEY_I`|I 键|
|`:KEY_J`|J 键|
|`:KEY_K`|K 键|
|`:KEY_L`|L 键|
|`:KEY_M`|M 键|
|`:KEY_N`|N 键|
|`:KEY_O`|O 键|
|`:KEY_P`|P 键|
|`:KEY_Q`|Q 键|
|`:KEY_R`|R 键|
|`:KEY_S`|S 键|
|`:KEY_T`|T 键|
|`:KEY_U`|U 键|
|`:KEY_V`|V 键|
|`:KEY_W`|W 键|
|`:KEY_X`|X 键|
|`:KEY_Y`|Y 键|
|`:KEY_Z`|Z 键|
|`:KEY_NUM_0`|小键盘数字 0 键|
|`:KEY_NUM_1`|小键盘数字 1 键|
|`:KEY_NUM_2`|小键盘数字 2 键|
|`:KEY_NUM_3`|小键盘数字 3 键|
|`:KEY_NUM_4`|小键盘数字 4 键|
|`:KEY_NUM_5`|小键盘数字 5 键|
|`:KEY_NUM_6`|小键盘数字 6 键|
|`:KEY_NUM_7`|小键盘数字 7 键|
|`:KEY_NUM_8`|小键盘数字 8 键|
|`:KEY_NUM_9`|小键盘数字 9 键|
|`:KEY_NULTIPLY`|* 键|
|`:KEY_ADD`|+ 键|
|`:KEY_SEPARATOR`|Separator 键|
|`:KEY_SUBTRACT`|- 键|
|`:KEY_DECIMAL`|. 键|
|`:KEY_DIVIDE`|/ 键|
|`:KEY_F1`|F1 键|
|`:KEY_F2`|F2 键|
|`:KEY_F3`|F3 键|
|`:KEY_F4`|F4 键|
|`:KEY_F5`|F5 键|
|`:KEY_F6`|F6 键|
|`:KEY_F7`|F7 键|
|`:KEY_F8`|F8 键|
|`:KEY_F9`|F9 键|
|`:KEY_F10`|F10 键|
|`:KEY_F11`|F11 键|
|`:KEY_F12`|F12 键|
|`:KEY_NUMLOCK`|Num Lock 键|
|`:KEY_SCROLL`|Scroll Lock 键|