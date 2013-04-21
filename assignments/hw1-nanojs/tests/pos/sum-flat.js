function sum(n){
  assume(n > 0);
  var r = 0;
  var i = n;
  while (0 < i) {
    r = r + 1;
    i = i - 1;
  }
  assert (i == 0);
  assert (n == r);
  assert (0 <  r);
}
