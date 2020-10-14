( echo "var data = " && curl https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19/zakladni-prehled.json && echo ";" )> lib/data.dart
