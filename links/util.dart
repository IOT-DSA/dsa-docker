import "dart:async";
import "dart:convert";
import "dart:io";

typedef void ProcessHandler(Process process);
typedef void OutputHandler(String str);

class BetterProcessResult extends ProcessResult {
  final String output;

  BetterProcessResult(int pid, int exitCode, stdout, stderr, this.output) :
      super(pid, exitCode, stdout, stderr);
}

Directory getDir(String path) => new Directory(path);
File getFile(String path) => new File(path);

Future<BetterProcessResult> exec(
  String executable,
  {
  List<String> args: const [],
  String workingDirectory,
  Map<String, String> environment,
  bool includeParentEnvironment: true,
  bool runInShell: false,
  stdin,
  ProcessHandler handler,
  OutputHandler stdoutHandler,
  OutputHandler stderrHandler,
  OutputHandler outputHandler,
  File outputFile,
  bool inherit: false,
  bool writeToBuffer: false
  }) async {
  IOSink raf;

  if (outputFile != null) {
    if (!(await outputFile.exists())) {
      await outputFile.create(recursive: true);
    }

    raf = await outputFile.openWrite(mode: FileMode.APPEND);
  }

  try {
    Process process = await Process.start(
      executable,
      args,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell
    );

    if (raf != null) {
      await raf.writeln("[${currentTimestamp}] == Executing ${executable} with arguments ${args} (pid: ${process.pid}) ==");
    }

    var buff = new StringBuffer();
    var ob = new StringBuffer();
    var eb = new StringBuffer();

    process.stdout.transform(const Utf8Decoder()).listen((str) async {
      if (writeToBuffer) {
        ob.write(str);
        buff.write(str);
      }

      if (stdoutHandler != null) {
        stdoutHandler(str);
      }

      if (outputHandler != null) {
        outputHandler(str);
      }

      if (inherit) {
        stdout.write(str);
      }

      if (raf != null) {
        await raf.writeln("[${currentTimestamp}] ${str}");
      }
    });

    process.stderr.transform(const Utf8Decoder()).listen((str) async {
      if (writeToBuffer) {
        eb.write(str);
        buff.write(str);
      }

      if (stderrHandler != null) {
        stderrHandler(str);
      }

      if (outputHandler != null) {
        outputHandler(str);
      }

      if (inherit) {
        stderr.write(str);
      }

      if (raf != null) {
        await raf.writeln("[${currentTimestamp}] ${str}");
      }
    });

    if (handler != null) {
      handler(process);
    }

    if (stdin != null) {
      if (stdin is Stream) {
        stdin.listen(process.stdin.add, onDone: process.stdin.close);
      } else if (stdin is List) {
        process.stdin.add(stdin);
      } else {
        process.stdin.write(stdin);
        await process.stdin.close();
      }
    }

    var code = await process.exitCode;
    var pid = process.pid;

    if (raf != null) {
      await raf.writeln("[${currentTimestamp}] == Exited with status ${code} ==");
      await raf.flush();
      await raf.close();
    }

    return new BetterProcessResult(
      pid,
      code,
      ob.toString(),
      eb.toString(),
      buff.toString()
    );
  } finally {
    if (raf != null) {
      await raf.flush();
      await raf.close();
    }
  }
}

String get currentTimestamp {
  return new DateTime.now().toString();
}

Future<dynamic> readJsonFile(String path, [Map defaultValue]) async {
  var file = new File(path);

  if (!(await file.exists()) && defaultValue != null) {
    return defaultValue;
  }

  var content = await file.readAsString();
  return const JsonDecoder().convert(content);
}

Future saveJsonFile(String path, value) async {
  var file = new File(path);
  var content = const JsonEncoder.withIndent("  ").convert(value);
  await file.writeAsString(content + "\n");
}

Future extractZipFile(String path, String target) async {
  var dir = new Directory(target);
  if (!(await dir.exists())) {
    await dir.create(recursive: true);
  }
  List<String> args = ["-C", target, "-xvf${path}"];
  BetterProcessResult ml = await exec(
    "bsdtar", args: ["-tf${path}"], writeToBuffer: true);
  List<String> contents = ml.stdout.split("\n");
  contents.removeWhere((x) => x == null || x.isEmpty || x.endsWith("/"));
  if (contents.every((l) => l.contains("/"))) {
    args.addAll(["--strip-components", "1"]);
  }

  var result = await exec("bsdtar", args: args);
  if (result.exitCode != 0) {
    throw new Exception("Failed to extract archive.");
  }
}

void cd(String path) {
  var dir = new Directory(path);
  Directory.current = dir;
}

Future makeZipFile(String target) async {
  var tf = new File(target);

  if (!(await tf.parent.exists())) {
    await tf.parent.create(recursive: true);
  }

  var result = await exec("zip", args: [
    "-r",
    tf.absolute.path,
    "."
  ]);

  if (result.exitCode != 0) {
    throw new Exception("Failed to make ZIP file!");
  }
}

Future<dynamic> loadJsonHttp(String url) async {
  var uri = Uri.parse(url);
  var client = new HttpClient();
  var request = await client.getUrl(uri);
  var response = await request.close();
  if (response.statusCode != 200) {
    throw new HttpException("Bad Status Code: ${response.statusCode}", uri: uri);
  }
  var content = await response.transform(const Utf8Decoder()).join();
  client.close(force: true);
  return const JsonDecoder().convert(content);
}

class Downloader {
  final HttpClient client;

  factory Downloader() {
    return new Downloader.forClient(new HttpClient());
  }

  Downloader.forClient(this.client);

  download(String url, String path, {String message: "Downloading {file.name} ({file.size}):\n  "}) async {
    var file = new File(path);
    var parent = file.parent;
    if (!(await parent.exists())) {
      await parent.create(recursive: true);
    }

    var name = file.path.split("/").last;

    message = message.replaceAll("{file.name}", name);

    var uri = Uri.parse(url);
    var request = await client.getUrl(uri);
    request.persistentConnection = true;
    var response = await request.close();
    if (response.statusCode != 200) {
      throw new HttpException("Bad Status Code: ${response.statusCode}", uri: uri);
    }

    var progress = 0;
    var r = file.openWrite();
    var last = "0% |${' ' * 50}|";

    var fileSize = "${response.contentLength}b";
    if (response.contentLength > 1024) {
      fileSize = "${response.contentLength ~/ 1024}kB";
    }

    if (response.contentLength > (1024 * 1024)) {
      fileSize = "${(response.contentLength / (1024 * 1024)).toStringAsFixed(2)}mb";
    }

    message = message.replaceAll("{file.size}", fileSize);

    stdout.write("${message} ${last}");
    var watch = new Stopwatch();

    update(List<int> data) {
      progress += data.length;
      r.add(data);
      stdout.write("\b" * last.length);
      var bms = (progress / 1024) / watch.elapsed.inSeconds;
      var pcnt = ((progress / response.contentLength) * 100).clamp(0, 100).toInt();
      var percent = pcnt ~/ 2;
      var left = 50 - percent;
      last = "${pcnt}%${pcnt <= 9 ? '  ' : (pcnt < 100 ? ' ' : '')} |${'\u2588' * percent}${' ' * left}|";

      var wwg = progress;
      String fileSize = "${wwg}b";

      if (wwg > 1024) {
        fileSize = "${wwg ~/ 1024}kB";
      }

      if (wwg > (1024 * 1024)) {
        fileSize = "${(wwg / (1024 * 1024)).toStringAsFixed(2)}mb";
      }

      last += " ${fileSize}";

      if (bms.isFinite) {
        var t = bms.toInt();
        String out = "${t}kB/s";
        if (t > 1024) {
          t = (t / 1024).toStringAsFixed(2);
          out = "${t}mb/s";
        }
        last += " (${out})";
      }
      stdout.write(last);
    }

    watch.start();
    update([]);
    await response.listen((data) {
      update(data);
    }).asFuture();
    watch.stop();
    await r.close();
    stdout.writeln();
  }

  void close() {
    client.close(force: true);
  }
}
