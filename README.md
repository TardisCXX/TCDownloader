# TCDownloader

**TCDownloader** iOS文件下载器，支持音频、视频等文件下载，包括断点续传，只需要一行代码就能实现暂停、取消、离线下载和多任务下载功能，也可以当做是一个功能组件，集成进项目。

## TCDownloader的使用
在需要用到的地方 `#import <TCDownloaderManager.h>`

在需要`下载`的点击事件中调用：

```Objective-C
[[TCDownloaderManager sharedManager] downloadWithURL:url
                                            message:^(long long totalSize, NSString *downloadedPath) {
                                                NSLog(@"下载文件总大小:%lld,下载路径:%@", totalSize, downloadedPath);
                                            }
                                            progress:^(float progress) {
                                                NSLog(@"下载进度:%f", progress);
                                            }
                                            success:^(NSString *downloadedPath) {
                                                NSLog(@"下载成功");
                                            }
                                            failure:^(NSString *errMsg) {
                                                NSLog(@"下载失败:%@", errMsg);
                                            }];
```

在需要`暂停`的点击事件中调用：
```Objective-C
[[TCDownloaderManager sharedManager] pauseAll];
// 或
[[TCDownloaderManager sharedManager] pauseWithUrl:url];
```

## 安装
1. CocoaPods安装：
```
pod 'TCDownloader' 
```
2. 下载ZIP包,将`TCDownloader`资源文件拖到工程中。

## 其他
为了不影响您项目中导入的其他第三方库，本库没有依赖任何其他框架，可以放心使用。
* 如果在使用过程中遇到BUG，希望你能Issues我，谢谢（或者尝试下载最新的框架代码看看BUG修复没有）
* 如果您有什么建议可以Issues我，谢谢
* 后续我会持续更新，为它添加更多的功能，欢迎star :)
