import 'package:midgard_repository/midgard_repository.dart';
import 'package:midgard_repository/src/helpers.dart';

import 'midgard_repository.dart';

void main() async {
  final midgardApi = MidgardAPIClient();
  final nodeApi = new ThorNodeAPIClient();
  var pools = await nodeApi.getPools();

}
