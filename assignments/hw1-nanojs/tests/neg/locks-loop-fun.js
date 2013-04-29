function random(){
  var x;
  return x;
}

function pos(){
  ensures(0 < $result);
  var x = random();
  assume(x > 0);
  return x;
}

function create(){
  return 0;
}

function acquire(l){
  assert(l == 0);
  return 1;
}

function release(l){
  assert(l == 1);
  return 0;
}

function main(){
  var n    = pos();
  var flag = random();
  var l    = create();

  while (0 < n){
    if (0 < flag){
      l = acquire(l)
    }
    if (0 <= flag){
      l = release(l)
    }
    n = n - 1;
  }
  assert(l == 0);
}

