/*@ qualif PlusOne(v:int,x:int)   : v = x + 1    */    // DEMO

/*@ inc :: (int) => int */
function inc(x){
  var res = x + 1;
  return res;
}

/*@ main :: () => void */
function main(){
  var a = pos();
  var b = inc(a);
  assert (b == (a + 1));
  assert(b > 0);
}

