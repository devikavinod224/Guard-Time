import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parents_app/utils/appstate.dart';
import 'package:parents_app/utils/models.dart';

class AuthController extends GetxController {
  RxBool isLoggedIn = false.obs;
  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;

  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return false; // User canceled the sign-in process

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      user.value = authResult.user;
      UserModel newUser = UserModel(
        // id: user.value!.uid.toString(),
        // devices: [], 
        // ignore: prefer_null_aware_operators
        id: AppState().user?.id ?? user.value!.uid,
        email: user.value!.email.toString(),
        firstName: user.value!.displayName != null &&
                user.value!.displayName!.contains(" ")
            ? user.value!.displayName!.split(" ")[0]
            : user.value!.displayName ?? "Unknown",
        // isSignedIn: true,
        lastName: user.value!.displayName != null &&
                user.value!.displayName!.contains(" ")
            ? user.value!.displayName!.split(" ").sublist(1).join(" ")
            : "",
        // otpExpires: DateTime.now(),
        // otpTimestamp: DateTime.now(),
        phone: AppState().user?.phone ?? "NA",
        // otp: "123456",
      );
      AppState().user = newUser;
      if (AppState().user != null &&
          AppState().user!.phone != null &&
          AppState().user!.phone != "NA") {
        var temp = await AppState().createUser(newUser);
        if (!temp) {
          return false;
        }
      } else {
        var temp = await AppState().createUserByEmail(newUser);
        if (!temp) {
          return false;
        }
      }
      isLoggedIn.value = true;
      isLoading.value = false;
      return true;
    } catch (e) {
      print("Google Sign In Error: $e");
      isLoading.value = false;
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    user.value = null;
    isLoggedIn.value = false;
  }
}
