fn isSpace( _ b:Int )->Bool=b==' '||b=='\n'
fn main(){
    var n=0
  for b in [32,65,10]{ if isSpace(b){n+=1} }
        print("$n")
}
