# pp_flutter_kits

## 创建插件工程

### 纯Dart库插件

``` bash
flutter create --template=package 插件名
```

### 原生插件

``` bash
flutter create --template=plugin --platforms=android,ios 插件名
#--org 指定组织
flutter create --org com.example --template=plugin --platforms=android,ios 插件名
```

### 创建示例工程

``` bash
flutter create example
```
