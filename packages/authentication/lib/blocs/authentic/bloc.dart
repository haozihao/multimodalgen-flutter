import 'dart:async';
import 'dart:convert';

import 'package:app/app.dart';
import 'package:authentication/authentication.dart';
import 'package:authentication/models/user.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/model/user_info_global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utils/utils.dart';

var logger = Logger(printer: PrettyPrinter());

///登录和用户数据全局管理
class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc() : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthByPassword>(_onAuthByPassword);
    on<AuthByRegister>(_onAuthByRegister);
    on<Logout>(_onLoggedOut);
    on<LoginEvent>(_onLogIn);
    on<UpdateAuthInfo>(_onAuthUserInfoUpdate);
  }

  void _onAppStarted(AuthEvent event, Emitter<AuthState> emit) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (event is AppStarted) {
      String? token = sp.getString(SpKey.tokenKey);
      String? userJson = sp.getString(SpKey.userKey);
      if (token != null && userJson != null) {
        // bool disable = JwtDecoder.isExpired(token);
        bool disable = false;
        print("App启动获取本地登录信息：" + disable.toString() + "  userInfo:" + userJson);
        if (!disable) {
          HttpUtil.instance.setToken(token);
          User user = User.fromJson(json.decode(userJson));
          GlobalInfo.instance.user = user;
          emit(AuthSuccess(user));
        } else {
          // 说明 token 过期
          await _removeToken(sp);
          await _removeUser(sp);
        }
      }
    }

    // if(event is Logout){
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   print("登出"+event.user.toString());
    //   await prefs.setString(
    //       SpKey.userKey, jsonEncode(event.user));
    // }

    // if (event is UpdateAuthInfo) {
    //   print("升级用户信息的通知"+event.user.toString());
    //   emit(AuthSuccess(event.user));
    // }
  }

  // 持久化 token
  Future<void> _persistToken(String token, SharedPreferences sp) async {
    await sp.setString(SpKey.tokenKey, token);
  }

  // 持久化 token
  Future<void> _removeToken(SharedPreferences sp) async {
    await sp.remove(SpKey.tokenKey);
  }

  // 持久化 token
  Future<void> _removeUser(SharedPreferences sp) async {
    await sp.remove(SpKey.userKey);
  }

  // 持久化 user
  Future<void> _persistUser(User user, SharedPreferences sp) async {
    // print("存入sp的user内容:"+jsonEncode(user));
    await sp.setString(SpKey.userKey, jsonEncode(user));
  }

  FutureOr<void> _onAuthByPassword(
      AuthByPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
  }

  FutureOr<void> _onAuthByRegister(
      AuthByRegister event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
  }

  //用户信息发生变更
  FutureOr<void> _onAuthUserInfoUpdate(
      UpdateAuthInfo event, Emitter<AuthState> emit) async {
    // emit (AuthLoading());
    print("升级用户信息的通知" + event.user.toString());
    emit(AuthSuccess(event.user));
    // await Future.delayed(const Duration(milliseconds: 500));
    // TaskResult<User> result = await repository.getUserInfo(uid: event.uid);
    //
    // if (result.success&& result.data!=null) {
    //   // 更新用户信息成功
    //   SharedPreferences sp = await SharedPreferences.getInstance();
    //   await _persistUser(result.data!,sp);
    //   emit (AuthSuccess(result.data!));
    // } else {
    //   emit (const AuthFailure('用户名和密码不匹配'));
    // }
  }

  FutureOr<void> _onLogIn(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const LogInState());
  }

  FutureOr<void> _onLoggedOut(Logout event, Emitter<AuthState> emit) async {
    logger.d("登出" + event.user.toJson().toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SpKey.tokenKey, '');
    await prefs.setString(SpKey.userKey, jsonEncode(event.user));
    emit(const AuthInitial());
  }
}
