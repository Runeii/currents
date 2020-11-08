splitList(List list, num chunkLength) {
  var chunks = [];
  for (var i = 0; i < list.length; i += chunkLength) {
    chunks.add(
      list.sublist(
        i,
        i + chunkLength > list.length ? list.length : i + chunkLength,
      ),
    );
  }
  return chunks;
}
