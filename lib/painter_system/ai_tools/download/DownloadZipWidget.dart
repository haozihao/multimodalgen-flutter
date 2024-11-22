import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:authentication/models/user.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:utils/utils.dart';

import '../../../app/model/user_info_global.dart';
import '../../gallery_card_item.dart';

typedef DownloadCallback = void Function(double progress, String status);

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

class DownloadZipWidget extends StatefulWidget {
  final List<String> urls;
  final String path;
  final String projectName;
  final DownloadCallback callback;
  final GalleryInfo galleryInfo;

  DownloadZipWidget({
    required this.urls,
    required this.path,
    required this.callback,
    required this.projectName,
    required this.galleryInfo,
  });

  @override
  _DownloadZipWidgetState createState() => _DownloadZipWidgetState();
}

class _DownloadZipWidgetState extends State<DownloadZipWidget> {
  List<double> _progresses = [];
  List<String> _statuses = [];
  List<int> _totalBytes = [];
  List<int> _receivedBytes = [];
  List<int> _startTimes = [];
  late String destinationDir;

  @override
  void initState() {
    super.initState();
    _progresses = List<double>.filled(widget.urls.length, 1.0);
    _statuses = List<String>.filled(widget.urls.length, '开始...');
    _totalBytes = List<int>.filled(widget.urls.length, 0);
    _receivedBytes = List<int>.filled(widget.urls.length, 0);
    _startTimes = List<int>.filled(
        widget.urls.length, DateTime.now().millisecondsSinceEpoch);
    destinationDir =
        widget.path + FileUtil.getFileSeparate() + widget.projectName;
  }

  ///下载和解压
  Future<void> _startDownload() async {
    if (widget.galleryInfo.vip != 0) {
      User user = GlobalInfo().user;
      if (user.vipLevel! < 4) {
        MotionToast.warning(description: Text('请先激活软件！')).show(context);
        return;
      }
    }
    if (widget.path.isEmpty) {
      MotionToast.warning(description: Text('请先设置安装路径!')).show(context);
      return;
    }

    ///判断文件夹是否存在
    // 获取临时目录
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/download.zip';
    logger.d("下载tempPath:$tempPath");

    if (widget.urls.length == 1) {
      // 下载单个文件
      await _downloadFile(widget.urls.first, tempPath, 0);
    } else {
      // 下载分包文件
      for (int i = 0; i < widget.urls.length; i++) {
        final partUrl = widget.urls[i];
        final partPath = '$tempPath.${(i + 1).toString().padLeft(3, '0')}';

        await _downloadFile(partUrl, partPath, i);
      }

      // 合并分包文件
      setState(() {
        _progresses.fillRange(0, _progresses.length, 1.0);
        _statuses.fillRange(0, _statuses.length, '合并分包文件');
      });
      widget.callback(1.0, '合并分包文件');
      await _mergeParts(tempPath, widget.urls.length);
    }

    // 合并完成，开始解压
    setState(() {
      _progresses.fillRange(0, _progresses.length, 0.99);
      _statuses.fillRange(0, _statuses.length, '正在安装...');
    });
    widget.callback(0.99, '正在安装...');
    await _unzipFile(tempPath, destinationDir);

    // 解压完成
    setState(() {
      _progresses.fillRange(0, _progresses.length, 1.0);
      _statuses.fillRange(0, _statuses.length, '完成');
    });
    widget.callback(1.0, '完成');
    MotionToast.success(description: Text("安装完成")).show(context);
  }

  Future<void> _downloadFile(String url, String savePath, int index) async {
    _startTimes[index] = DateTime.now().millisecondsSinceEpoch;

    await HttpUtil.instance.client.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          _totalBytes[index] = total;
          _receivedBytes[index] = received;

          final currentTime = DateTime.now().millisecondsSinceEpoch;
          final elapsedTime = (currentTime - _startTimes[index]) / 1000; // 秒

          if (elapsedTime > 0) {
            final downloadSpeed =
                (_receivedBytes[index] / (1024 * 1024)) / elapsedTime; // MB/s
            _statuses[index] = '下载中: ${downloadSpeed.toStringAsFixed(1)} MB/s';
          }

          final progress = received / total;
          setState(() {
            _progresses[index] = progress;
          });
          widget.callback(progress, _statuses[index]);
        }
      },
    );
  }

  Future<void> _mergeParts(String basePath, int partCount) async {
    final outputFile = File(basePath);
    final outputStream = outputFile.openWrite();

    try {
      for (int i = 1; i <= partCount; i++) {
        final partFile = File('$basePath.${i.toString().padLeft(3, '0')}');
        await outputStream.addStream(partFile.openRead());
        await partFile.delete(); // 删除分包文件
      }
    } finally {
      await outputStream.close();
    }
  }

  ///省内存方式解压
  Future<void> _unzipFile(String zipFilePath, String destinationDir) async {
    final inputStream = InputFileStream(zipFilePath);
    // Decode the zip from the InputFileStream. The archive will have the contents of the
    // zip, without having stored the data in memory.
    final archive = ZipDecoder().decodeBuffer(inputStream);

    // For all of the entries in the archive
    int totalFiles = archive.files.length;
    int currentFileIndex = 0;
    await Future.forEach(archive, (file) async {
      final filename = '$destinationDir/${file.name}';
      logger.d("解压到：$filename");
      final progress = currentFileIndex / totalFiles;
      setState(() {
        _statuses[0] = '安装中...$currentFileIndex / $totalFiles';
        _progresses[0] = progress;
      });
      if (file.isFile) {
        final outputStream = OutputFileStream(filename);
        // The writeContent method will decompress the file content directly to disk without
        // storing the decompressed data in memory.
        file.writeContent(outputStream);
        // Make sure to close the output stream so the File is closed.
        outputStream.close();
      } else {
        await Directory(filename).create(recursive: true);
      }
      currentFileIndex++;
    });
  }

  String _formatBytes(int bytes) {
    final double megabytes = bytes / (1024 * 1024);
    if (megabytes > 1024) {
      final double gigabytes = megabytes / 1024;
      return '${gigabytes.toStringAsFixed(2)} GB';
    } else {
      return '${megabytes.toStringAsFixed(2)} MB';
    }
  }

  String _getFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    bool isDownloaded = Directory(destinationDir).existsSync();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            child: ElevatedButton(
              onPressed: () {
                //如果是重新下载，则提示用户
                if (isDownloaded) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('本地已安装'),
                        content: const Text('点击确定将重新下载并覆盖！'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              _startDownload();
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  _startDownload();
                }
              },
              child: Text(isDownloaded ? '重新下载' : '开始下载'),
            ),
            width: 100,
            height: 40,
          ),
          ...List.generate(widget.urls.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _progresses[index] >= 1.0
                  ? SizedBox.shrink()
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              Text(_statuses.firstWhere(
                                  (status) => status != '完成',
                                  orElse: () => '完成')),
                              Spacer(),
                              Text(
                                  '${_formatBytes(_receivedBytes[index])}/${_formatBytes(_totalBytes[index])}'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            // Text(_getFileNameFromUrl(widget.urls[index])),
                            SizedBox(width: 20),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: _progresses[index],
                                minHeight: 7,
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        )
                      ],
                    ),
            );
          }),
        ],
      ),
    );
  }
}
