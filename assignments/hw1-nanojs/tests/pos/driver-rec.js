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
  assert(l==0);
  return 1;
}

function release(l){
  assert(l==1);
  return 0;
}

function driver() {
  var newCount = pos();
  var oldCount = pos(); 
  var l        = create();
  if (newCount < oldCount){
    while (newCount != oldCount){
      l        = acquire(l);
      oldCount = newCount;
      if (0 < newCount){
        l = release(l);
        newCount = newCount - 1;
      }
    }
    l = release(l);
  }
}

