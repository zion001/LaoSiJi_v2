class PayloadHeadModel {
  String? cmd;
  String? seq;

  PayloadHeadModel({this.cmd, this.seq});

  factory PayloadHeadModel.fromJson(Map<String, dynamic> json) =>
      PayloadHeadModel(
        cmd: json['cmd'] as String?,
        seq: json['seq'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'cmd': cmd,
        'seq': seq,
      };
}

class PayloadModel {
  PayloadHeadModel? head;
  dynamic content;
  int? error_code;
  String? error_msg;

  PayloadModel({this.head, this.content, this.error_code, this.error_msg});

  factory PayloadModel.fromJson(Map<String, dynamic> json) => PayloadModel(
        head: json['head'] == null
            ? null
            : PayloadHeadModel.fromJson(json['head']),
        content: json['content'],
        error_code: json['error_code'] as int?,
        error_msg: json['error_msg'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'head': head?.toJson(),
        'content': content,
      };
}
