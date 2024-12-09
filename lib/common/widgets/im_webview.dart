import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImWebview extends StatelessWidget {
  String? title;
  String? htmlContent;
  String? url;
  String? file;
  ImWebview({this.htmlContent,this.title,this.url,this.file});

  @override
  Widget build(BuildContext context) {
    final WebViewController controller =
        WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );
    if(url !=null )
      controller.loadRequest(Uri.parse(url!));
    else if(file !=null )
      controller.loadFile(file!);
    else
      controller.loadHtmlString(htmlContent??'');
    return Scaffold(
      appBar: AppBar(
        title: Text(title??''),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      ),
      body: WebViewWidget(controller: controller).paddingSymmetric(horizontal: 10,vertical: 20),
    );
  }
}