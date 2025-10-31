import 'package:markdown/markdown.dart' as md;

class ImgsTagSyntax extends md.BlockSyntax {
  static final _pattern = RegExp(r'<img-group([^>]*)>([\s\S]*?)<\/img-group>', multiLine: true);

  ImgsTagSyntax();

  @override
  RegExp get pattern => _pattern;

  @override
  md.Node? parse(md.BlockParser parser) {
    final match = _pattern.firstMatch(parser.current.content);
    if (match == null) return null;

    // 如需用属性可在此处理
    // final attrs = _parseAttributes(match.group(1));
    final content = match.group(2)?.trim() ?? '';

    // 消费当前行
    parser.advance();

    // 这里直接返回 img-group 元素，属性和内容作为子节点
    var node = md.Element('img-group', _parseInnerImages(content));
    return node;
  }

  // 属性解析方法已移除，如需用属性可自行补充

  /// 解析内部图片标签
  List<md.Node> _parseInnerImages(String content) {
    final imgRegex = RegExp(r'!\[[^\]]*\]\(([^)]+)\)');
    final nodes = <md.Node>[];
    for (final match in imgRegex.allMatches(content)) {
      nodes.add(md.Element.text('img', match.group(1)!));
    }
    return nodes;
  }
}
