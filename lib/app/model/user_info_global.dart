import 'package:authentication/models/user.dart';

///全局信息类
class GlobalInfo {
  static final GlobalInfo _instance = GlobalInfo._();

  GlobalInfo._(){
    _user = User(
        name: '未登录',
        authToken: '09078be9ebf444b5ac2be1a30775df66',
        pegg: 1000,
        gender: 0,
        vType: 0,
        userId: 10001086,
        vipLevel: 4,
        vipEnd: -1,
        headIcon:
        'https://imgs.pencil-stub.com/data/avatar/2021-12-28/e5767cd381874fcb9d89ff350442f3b8.png');
  }

  factory GlobalInfo() => _instance;

  User? _user;

  static GlobalInfo get instance => _instance;

  User get user => _user!;

  set user(User value) {
    _user = value;
  }

  void reset(){
    _user =  User(
        name: '未登录',
        pegg: -1,
        gender: 0,
        vType: 0,
        userId: -1,
        vipEnd: -1,
        headIcon:
        'https://imgs.pencil-stub.com/data/avatar/2021-12-28/e5767cd381874fcb9d89ff350442f3b8.png', authToken: '');
  }
}