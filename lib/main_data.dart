import 'dart:async';

import 'src/CreditCards/card_detail_public.dart';

class MainData {
  String? _userEmail;
  String? get userEmail => _userEmail;

  void setuserEmail(String userEmail) {
    _userEmail = userEmail;
  }

  String? _idMissionOnProcess;
  String? get idMissionOnProcess => _idMissionOnProcess;

  void setidMissionOnProcess(String idMissionOnProcess) {
    _idMissionOnProcess = idMissionOnProcess;
  }
}
