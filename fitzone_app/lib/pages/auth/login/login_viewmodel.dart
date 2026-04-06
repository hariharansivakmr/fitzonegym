import '../../common/base_viewmodel.dart';

class LoginViewModel extends BaseViewModel {
  Future<void> sendOtp() async {
    setLoading(true);

    await Future.delayed(const Duration(seconds: 2));

    setLoading(false);
  }

  Future<bool> verifyOtp(String otp) async {
    setLoading(true);

    await Future.delayed(const Duration(seconds: 2));

    setLoading(false);

    return true;
  }
}