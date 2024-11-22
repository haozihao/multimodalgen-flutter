import 'package:authentication/models/user.dart';
import 'package:equatable/equatable.dart';

///********************************验证行为********************************

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

// 发送 邮箱验证
class AuthByPassword extends AuthEvent {
  final String username;
  final String password;

  const AuthByPassword({required this.username,required this.password});

  @override
  List<Object> get props => [username,password];
}


//更新用户信息事件
class UpdateAuthInfo extends AuthEvent {
  final User user;

  const UpdateAuthInfo({required this.user});

  @override
  List<Object> get props => [user];
}

//弹窗登录的事件
class LoginEvent extends AuthEvent {

  const LoginEvent();

  @override
  List<Object> get props => [];
}


// 用户注册也是认证的一部分
class AuthByRegister extends AuthEvent{
  final String email;
  final String code;

  const AuthByRegister(this.email, this.code);
}

class Logout extends AuthEvent {

  final User user;
  final bool tokenDisable;

  const Logout({required this.user,this.tokenDisable=false});
}

class TokenDisabled extends AuthEvent {

  const TokenDisabled();
}