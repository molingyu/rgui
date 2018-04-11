# 动画

通过 `action_manager` 可以获取 UI 组件的动画管理器接口。`add_action(name, conf)` 函数为组件添加一个指定的动画效果。

```ruby
@image_box = RGUI::Component::ImageBox.new({image: 'image.png'})
@image_box.action_manager.add_action(:breath, {speed: 0.6})
```

## 统一事件
对于非 `loop` 动画，在动画执行完毕的时候会触发一个名为 `:action_end` 的事件。可以通过 `event_manager` 捕获。

## 动画效果
|名称|进度|说明|
|----|----|----|
|[呼吸](actions/breath.md)|已完成|组件的透明度会在一个范围内来回变换，类似呼吸灯|
|切片动画|开发中|切片动画，会根据配置信息来替换组件的 `sprite#bitmap`|
|位移|计划中|提供一个可配置的位移相关的动画|
|震动|计划中|组件的位置会在一个固定点的周围震荡（震荡方向可指定）|
|心跳|计划中|组件的会在一个范围内来回缩放|

## 拓展

请阅读 [自定义动画效果](action_module.md) 部分。