String born({bool inFuture = false, bool isMale = true}) {
  if (inFuture) {
    return 'родится';
  }
  return isMale ? "родился" : 'родилась';
}

String hired({bool inFuture = false, bool isMale = true}) {
  if (inFuture) {
    return 'устроится';
  }
  return isMale ? "устроился" : 'устроилась';
}

String fired({bool inFuture = false, bool isMale = true}) {
  if (inFuture) {
    return 'уволится';
  }
  return isMale ? "уволился" : 'уволилась';
}
