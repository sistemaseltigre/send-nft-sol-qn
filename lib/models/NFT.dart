class NFT {
  String? name;
  String? imageUrl;
  String? description;
  String? tokenAddress;

  NFT({this.name, this.imageUrl, this.description});

  NFT.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imageUrl = json['imageUrl'];
    description = json['description'];
    tokenAddress = json['tokenAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['imageUrl'] = this.imageUrl;
    data['description'] = this.description;
    data['tokenAddress'] = this.tokenAddress;
    return data;
  }
}
