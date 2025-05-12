import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    WebViewController controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                print('WebView is loading (progress: $progress%)');
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
              },
              onWebResourceError: (WebResourceError error) {
                print('Web resource error: ${error.description}');
              },
            ),
          );

    const String mindString = '''
## 项目背景与目标  
- 测试d听安卓录音上传功能的实现与稳定性  

## 功能需求  
### 录音与上传功能  
- 测试d听安卓录音上传  
  - 验证录音功能在安卓设备上的正常运行  
  - 验证录音文件的上传流程与完整性  

## 技术实现  
### 平台适配  
- 安卓系统录音接口调用  
- 文件传输协议实现  

## 项目管理  
- 测试执行记录  
  - 发言人1: 00:00:02 提出测试需求  
  - 发言人2: 00:00:02 确认测试需求
''';

    controller.loadHtmlString('''
  <!DOCTYPE html>
      <html>
      <head>
        <title>Mindmap</title> 
        <style>
        .markmap {
          position: relative;
          height:100vh; 
          width: 100%;
          background-color:#fff;
        }

        svg.markmap {
          width: 100%;
          height: 100vh;
        }
        </style>
        <!-- 引入markmap.js -->
        <script src="https://cdn.jsdelivr.net/npm/markmap-autoloader@latest"></script>
      </head>
      <body>
        <h1>思维导图</h1>
        <!-- markdown mindmap容器 -->
        <div class="markmap">
          <!-- markdown数据内容 -->
          <script type="text/template">
            ${mindString}
          </script>
        </div>

        <script type="text/javascript">
          window.exportSVGtoImage = function(fileName = 'markmapImage', type = 'png') {
            const _svg = document.querySelector('svg.markmap');
            if (!_svg) {
              console.error('SVG元素未找到');
              return;
            }

            try {
              const { width, height } = _svg.getBoundingClientRect();
              const imgData = covertSVG2Image(_svg, fileName, width, height, type);
              window.WebViewBridge.postMessage(imgData);
            } catch (error) {
              console.error('SVG转换为图片失败, ' + error, 'error');
            }
          }

          function echo() {
            console.log('echo come in---');
          }

          const covertSVG2Image = (node, name, width, height, type = 'png') => {
            try {
                let serializer = new XMLSerializer()
                let source = '<?xml version="1.0" standalone="no"?>\r\n' + serializer.serializeToString(node);

                let image = new Image()
                image.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(source)
                let canvas = document.createElement('canvas')
                canvas.width = width
                canvas.height = height
                let context = canvas.getContext('2d')
                context.fillStyle = '#fff'
                context.fillRect(0, 0, 10000, 10000)
                image.onload = function () {
                    context.drawImage(image, 0, 0)
                }
                const svgData = canvas.toDataURL('image/'+ type);
                return svgData;
            } catch (error) {
                console.error('SVG转换为图片失败, ' + error, 'error');
            }
          }

        function echoTest() {
          console.log('echoTest come in');
          document.querySelector('h1').innerText = 'Hello, MindMap!';
        }
        </script>
      </body>
      </html>
''');

    void invokeBtnHandle() async {
      print('invokeBtnHandle come in');
      await Future.delayed(const Duration(milliseconds: 2000));
      controller.runJavaScript('''
        function printTest() {
          console.log('printTest come in');
          document.querySelector('h1').innerText = 'Hello, MindMap! ${DateTime.now()}';
        }
        printTest();
      ''');
    }

    return MaterialApp(
      title: 'WebView MindMap Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        scaffoldBackgroundColor: Colors.blueGrey,
      ),
      home: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  print('Export Button Pressed come in');
                },
                child: const Text('Export'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('Invoke Button Pressed');
                  invokeBtnHandle();
                },
                child: const Text('Invoke'),
              ),
            ],
          ),
          Container(
            height: 600,
            width: 500,
            color: Colors.white,
            child: WebViewWidget(controller: controller),
          ),
          //
        ],
      ),
    );
  }
}
