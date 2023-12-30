import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

List<TextSpan> extractText(String rawString) {
  List<TextSpan> textSpan = [];

  final urlRegExp = new RegExp(
      r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

  getLink(String linkString) {
    if (linkString.contains('http://') ||linkString.contains('https://') ){

    }else {linkString='http://'+linkString;}
    textSpan.add(
      TextSpan(
        text: linkString,
        style: new TextStyle(color: Colors.blue),
        recognizer: new TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunchUrl(Uri.parse(linkString))) {
              await launchUrl(Uri.parse(linkString));
            }
            else {
              await launchUrl(Uri.parse(linkString), mode: LaunchMode.externalNonBrowserApplication,
              );}
          },
      ),
    );
    return linkString;
  }

  getNormalText(String normalText) {
    textSpan.add(
      TextSpan(
        text: normalText,
        style: new TextStyle(color: Colors.black),
      ),
    );
    return normalText;
  }

  rawString.splitMapJoin(
    urlRegExp,
    onMatch: (m) => getLink("${m.group(0)}"),
    onNonMatch: (n) => getNormalText("${n.substring(0)}"),
  );

  return textSpan;}