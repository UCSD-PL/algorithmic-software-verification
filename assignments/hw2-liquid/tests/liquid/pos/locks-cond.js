/*@ create :: () => int */
function create(){
  return 0;
}

/*@ acquire :: (int) => int */
function acquire(l){
  assert(l == 0);
  return 1;
}

/*@ release :: (int) => int */
function release(l){
  assert(l != 0);
  return 0;
}

/*@ loop :: (int, int) => int */
function loop(n, l) {
  var flag = random();
  if (0 < n){
    if (0 < flag){ 
      l = acquire(l); 
    }
    if (0 < flag){ 
      l = release(l);
    }
    loop(n-1, l);
  }
  return l;
}

/*@ main :: ({n:int|n > 0}) => void */
function main(n){
  var flag = random();
  var l    = create();
  loop(n, l);
  assert(l == 0);
}

