# Teleprompter_iOS
iOS端提词器，画中画功能

## 前言
最近在做直播机业务，手机端iOS端需做提词器功能，也需要用到画中画功能。功能描述简单，在找相关资料的时候发现能给到的帮助很少，其实关键的地方很少很少，但以此谋利的比较多，本着程序员的开源精神，现在分享出来。

**同道自取、异途绕行。**

## 问题阐述
其中的几个问题点先总结一下：
```
1、展示在画中画页面上

2、双击画中画，大小切换导致变形

3、画中画页面隐藏播放、快进、快退按钮

4、切后台、打开照相机视频等保活问题
```
下面以代码形式讲解问题的解决方案

## 提词展示在画中画
通过获取Window，拿到画中画所在的PGHostedWindow，合适时机将提词器放在PGHostedWindow上即可
```
firstWindow = [UIApplication sharedApplication].windows.firstObject;

[firstWindow addSubview:self.pipTextView];
```
这一步没有什么难的，需要加到画中画上的页面可以自定义内容

## 大小切换导致变形
开启画中画后，双击可改变画中画的大小，我在代码里为了省事用了frame布局，此时就会在切换大小的时候变形。而正常开发的时候用autolayout布局不会出现此情况。
我在这里加了重新刷新frame的方法修正这个问题，正常开发autolayout布局可忽略这个问题。

## 隐藏无关按钮
这个问题是大多数同胞卡的问题点，隐藏快进、快退按钮可以通过属性requiresLinearPlayback设置为YES解决，但是仍解决不了播放按钮的隐藏以及打开照相机黑屏问题。
做如下设置即可
```
[self.pipVC setValue:@1 forKey:@"controlsStyle"];
```
此时也无需设置requiresLinearPlayback属性，全篇关键代码仅此一句。

## 切后台保活
此问题我参考了别人总结的现成工具，在SceneDelegate对应方法里直接调用，可参考Demo。

## 结束语
感谢您的star，大家的支持是我不断努力的坚强后盾。
