# 数据绑定

使用 `DataBind` 模块来实现数据绑定。当两个 object 的数据被绑定后，一方变动另一方也会跟着变动。使用 `DataBind` 可以极大的增加 UI 的开发效率。

```ruby
test = Struct.new(:value)
a = test.new
b = test.new
c = test.new
a.value = 0
p a.value, b.value, c.value
DataBind.single_bind(a, :value, b, :value)
DataBind.single_bind(a, :value, c, :value){ |value| value < 2 }
a.value = 2
p a.value, b.value, c.value
```
输出
```bash
0
nil
nil
2
2
false
```

当然，你也可以通过 `DataBind.bind`来进行双向绑定。由于 `DataBind` 本身会监听变动前后的值，所以即使环状绑定也没有问题。