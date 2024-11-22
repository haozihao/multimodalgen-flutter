//本地stable diffution配置参数
import 'dart:ffi';

class SDConfig {
  final int id;

  //webui地址
  String url;

  //模型
  String mode;

  //lora
  String lora;

  //vae
  String vae;

  //seed号
  int seed;

  //迭代次数
  int step;

  //提示词相关性
  int correlation;

  //重绘幅度
  int redrawRange;

  //采样方式
  String sampling;

  //脸部修复(0:false,1:true)
  int restoration;

  //提示词
  String positivePrompt;
  String negativePrompt;

  //翻译
  String baiduId;
  String baiduKey;

  SDConfig(
      this.id,
      this.url,
      this.mode,
      this.lora,
      this.vae,
      this.sampling,
      this.correlation,
      this.seed,
      this.step,
      this.redrawRange,
      this.restoration,
      this.positivePrompt,
      this.negativePrompt,
      this.baiduId,
      this.baiduKey);

  Map<String, Object?> toJson() => {
        "id": 1,
        "url": url,
        "mode": mode,
        "lora": lora,
        "vae": vae,
        "sampling": sampling,
        "correlation": correlation,
        "seed": seed,
        "step": step,
        "redrawRange": redrawRange,
        "positivePrompt": positivePrompt,
        "negativePrompt": negativePrompt,
        "baiduId": baiduId,
        "baiduKey": baiduKey,
      };

  @override
  String toString() {
    return "{url: $url, baiduId: $baiduId, baiduKey: $baiduKey}";
  }

  static SDConfig fromMap(Map<String, dynamic> data) {
    return SDConfig(
      1,
      data['url'],
      data['mode'],
      data['lora'],
      data['vae'],
      data['sampling'],
      data['correlation'],
      data['seed'] as int,
      data['step'] as int,
      data['redrawRange'] as int,
      data['restoration'],
      data['positivePrompt'],
      data['negativePrompt'],
      data['baiduId'],
      data['baiduKey'],
    );
  }
}
