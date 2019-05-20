import opal from 'opal.rb';
opal();
Opal.load('opal');
// make promise available by default, used by require_lazy
import promise from 'promise.rb'
Opal.load('promise');
export default Opal;
