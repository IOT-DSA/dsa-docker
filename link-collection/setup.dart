import "dart:async";
import "dart:convert";
import "dart:io";

import "util.dart";

const String DEFAULT_REPO_URL =
  "https://dsa.s3.amazonaws.com/links/links.json";

main(List<String> args) async {
  var links = getEnvList("LINKS");

  var downloader = new Downloader();
  var repositoryUrl = getEnv("REPOSITORY_URL", DEFAULT_REPO_URL);
  var json = await loadJsonHttp(repositoryUrl);
  var repository = {};
  for (var entry in json) {
    repository[entry["name"]] = entry;
  }

  var successes = [];

  for (var name in links) {
    if (repository[name] == null) {
      print("Warning: No DSLink found named '${name}' - Skipping...");
      continue;
    }
    var entry = repository[name];
    var rname = entry["name"];
    var zipUrl = entry["zip"];
    await downloader.download(
      zipUrl,
      "${rname}.zip"
    );
    await extractZipFile("${rname}.zip", "${rname}");
    await new File("${rname}.zip").delete();
    successes.add(rname);
  }

  await new File("/app/links.dat").writeAsString(successes.join(" "));
  downloader.close();
}

String getEnv(String key, [String defaultValue]) {
  String value = Platform.environment[key];
  if (value == null) {
    value = defaultValue;
  }

  return value;
}

List<String> getEnvList(String key) {
  String string = Platform.environment[key];
  if (string == null) {
    string = "";
  }

  return string.split(" ");
}
