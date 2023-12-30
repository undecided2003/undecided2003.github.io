import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class dynamicLinkProvider {
  Future<String> createLink(String refCode) async {
    final String url = "https://drba.org/app/?ref=$refCode";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        androidParameters:
        const AndroidParameters(
            packageName: "org.drba.drbaapp", minimumVersion: 0),
        iosParameters:
        const IOSParameters(
            bundleId: "org.drba.drbaapp", minimumVersion: "0",
            appStoreId: "6471546649"
        ),
        link: Uri.parse(url),
        uriPrefix: "https://drba.page.link");
    final FirebaseDynamicLinks link = await FirebaseDynamicLinks.instance;
    final refLink = await link.buildShortLink(parameters);
    return refLink.shortUrl.toString();
  }
}