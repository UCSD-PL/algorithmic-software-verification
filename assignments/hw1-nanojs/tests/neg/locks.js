function random(){
  var x;
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
  assert(l == 1);
  return 0;
}


function main(){
  var l = create();
  var x = random();
  if (0 <  x){ l = acquire(l); }
  if (0 <= x){ l = release(l); }
  assert(l == 0);
}



