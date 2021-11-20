import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SystemDetailsSliver extends HookWidget {
  String apiKey;

  SystemDetailsSliver(this.apiKey);

  @override
  Widget build(BuildContext context) {
    final _platformVersion = useState<String?>(null);
    final _ablyVersion = useState<String?>(null);

    useEffect(() {
      ably
          .platformVersion()
          .then((version) => _platformVersion.value = version);
      ably.version().then((version) => _ablyVersion.value = version);
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        TextRow('Running on', _platformVersion.value),
        TextRow('Ably version', _ablyVersion.value),
        TextRow('Ably Client ID', Constants.clientId),
        if (apiKey == '')
          RichText(
            text: const TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                      text: 'Warning: ',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Ably API key is not configured, use '),
                  TextSpan(
                      text: '`flutter run '
                          '--dart-define=ABLY_API_KEY=your_api_key`',
                      style: TextStyle()),
                  TextSpan(
                      text: "or add this to the 'additional run args' "
                          'in the run configuration in '
                          'Android Studio.')
                ]),
          )
        else
          TextRow('Ably API key', hideApiKeySecret(apiKey)),
      ],
    );
  }

  String hideApiKeySecret(String apiKey) {
    // What is an API Key?: https://faqs.ably.com/what-is-an-app-api-key
    final keyComponents = apiKey.split(':');
    if (keyComponents.length != 2) {
      return apiKey;
    }
    final publicApiKey = keyComponents[0];
    final apiKeySecret = keyComponents[1];
    return '$publicApiKey:${'*' * apiKeySecret.length}';
  }
}
