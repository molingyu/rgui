# RPGMaker GUI Framework

一个现代化的适用于 RPG Maker 的 GUI 框架。支持 [RGSS3](http://miaowm5.github.io/RMVA-F1/RPGVXAcecn/rgss/index.html)、[RGM](https://github.com/gxm11/RGModern)、[RGD](https://cirno.blog/archives/290#instructions) 运行时。

## 使用
下载 `dist` 文件夹下的 `rgui.rb`。 将其复制到 RM 插入脚本处，且最好位于顶层。

具体使用请参照 [Example](https://github.com/molingyu/rgui/tree/master/example) 和 [使用手册](https://molingyu.github.io/rgui)。

## 特性
* 强大的事件处理框架，支持异步事件和`filter`等特性。
* 支持非规则的 UI 组件热区。
* 提供便利的 UI 动画的接口。
* 数据绑定。

## UI组件
- [x] 精灵按钮
- [x] 图片框
- [x] 标签
- [ ] 进度条
- [ ] 文字按钮
- [ ] 横排容器
- [ ] 竖排容器

## 二次开发
需要 `ruby-1.9` 以上的环境。

```bash
git clone https://github.com/molingyu/rgui.git
bundle install 
```

`rake api_doc` 生成新的 API 文档。

`env_rgm` `env_rgd` `env_default` 用于切换目标运行时。

`rake pack` 则会打包输出到 `dist`。 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/molingyu/rgui. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).