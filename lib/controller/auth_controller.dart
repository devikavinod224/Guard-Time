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

  // --- Email/Password Logic ---

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    try {
      isLoading.value = true;
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      user.value = credential.user;
      
      if (user.value != null) {
          // Update Display Name
          await user.value!.updateDisplayName(name);
          
          UserModel newUser = UserModel(
            id: user.value!.uid,
            email: email,
            firstName: name.contains(" ") ? name.split(" ")[0] : name,
            lastName: name.contains(" ") ? name.split(" ").sublist(1).join(" ") : "",
            phone: "NA",
          );
          
          AppState().user = newUser;
          // Create user in Firestore
          return await AppState().createUserByEmail(newUser);
      }
      return false;
    } catch (e) {
      Get.snackbar("Sign Up Failed", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      user.value = credential.user;
      
      if (user.value != null) {
          // Load user data into AppState if needed, or AppState might handle it via listener
           UserModel existingUser = UserModel(
            id: user.value!.uid,
            email: email,
            firstName: user.value!.displayName?.split(" ")[0] ?? "Unknown",
            lastName: "",
            phone: "NA",
          );
          AppState().user = existingUser;
          // You might want to fetch the FULL user profile from Firestore here if AppState doesn't do it automatically
          // But based on existing code, AppState().createUserByEmail seems to handle the "ensure exists" logic.
          // Let's assume a simple fetch or re-use of create (which merges) is fine for now.
          return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    user.value = null;
    isLoggedIn.value = false;
  }
}
