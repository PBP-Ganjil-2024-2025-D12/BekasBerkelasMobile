import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/review_rating/models/user.dart';

class UserService {
  String baseUrl = "http://localhost:8000";

  Future<User> fetchUser(CookieRequest request, username) async {
    try {
      final response = await request.get(
        '$baseUrl/profile/$username/show_user_json/',
      );
      var data = response;
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  Future<SellerProfile> fetchSellerInfo(CookieRequest request, username) async {
    try {
      final response = await request.get(
        '$baseUrl/profile/$username/show_user_json/',
      );
      var data = response;
      return SellerProfile.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching seller info: $e');
    }
  }

  Future<BuyerProfile> fetchBuyerInfo(CookieRequest request, username) async {
    try {
      final response = await request.get(
        '$baseUrl/profile/$username/show_user_json/',
      );
      var data = response;
      return BuyerProfile.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching buyer profile: $e');
    }
  }

}