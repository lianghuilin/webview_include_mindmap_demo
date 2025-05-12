import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
          )
          ..addJavaScriptChannel(
            'MindMapCaller',
            onMessageReceived: (JavaScriptMessage message) {
              String rawSvg = message.message;
              print('img data $rawSvg');
            },
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
        <title>MindMap</title> 
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

        <!-- 引入插件 -->
        <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
        <!-- 引入markmap.js -->
        <script src="https://cdn.jsdelivr.net/npm/markmap-autoloader@latest"></script>
      </head>
      <body>
        <h1 id="title">思维导图</h1>

        <div style="display: none;" id="base64Container">img init data</div>

        <!-- markdown mindmap容器 -->
        <div id="markmap" class="markmap">
          <!-- markdown数据内容 -->
          <script type="text/template">
            ${mindString}
          </script>
        </div>

      </body>
      </html>
''');

    void invokeBtnHandle() async {
      print('invokeBtnHandle come in');
      controller.runJavaScript('''
        function printTest() {
          console.log('printTest come in');
          document.querySelector('h1').innerText = 'Hello, MindMap! ${DateTime.now()}';
        }
        printTest();
      ''');
    }

    void exportBtnHandle() async {
      String result =
          await controller.runJavaScriptReturningResult(
                '''document.getElementById('base64Container').innerText''',
              )
              as String;
      print('reuslt $result');
    }

    void buildImgHandle() async {
      controller.runJavaScript('''
        try {
          const _svg = document.querySelector('#markmap');
          html2canvas(_svg).then((canvas) => {
            const svgData = canvas.toDataURL('image/png');
            document.getElementById('base64Container').innerText = svgData;
            // MindMapCaller.postMessage(svgData);
          });
        } catch (error) {
          console.error('SVG转换为图片失败, ' + error, 'error');
        };
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  buildImgHandle();
                },
                child: Text('Build'),
              ),
              ElevatedButton(
                onPressed: () {
                  exportBtnHandle();
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
