class TextData {
  String? sId;
  String? content;
  String? style;
  int? iV;

  TextData({this.sId, this.content, this.style, this.iV});

  TextData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    content = json['content'];
    style = json['style'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['content'] = this.content;
    data['style'] = this.style;
    data['__v'] = this.iV;
    return data;
  }
}