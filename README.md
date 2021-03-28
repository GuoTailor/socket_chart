# socket_chart

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


使用postgresql做为数据库\
构建flutter应用
```
flutter build windows
```
构建完成后到socket_chart\build\windows\runner\Release目录下生成可执行文件\
构建Springboot应用
```
cd service
mvn package -Dmaven.test.skip=true
```