const int INTAKE_MAIN = 1;
const int INTAKE_SUB = 2;

class GraphData {
  int main;
  int sub;
  int total;

  GraphData({
    this.main = 0,
    this.sub = 0,
    this.total = 0,
  });

  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      main: json['main'] ?? 0,
      sub: json['sub'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}