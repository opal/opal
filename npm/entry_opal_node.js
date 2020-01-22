import opal from 'opal.rb';
opal();
Opal.load('opal');
import opal_node from 'nodejs.rb';
opal_node();
Opal.load('nodejs');
// make promise available by default, used by require_lazy
import promise from 'promise.rb'
Opal.load('promise');
export default Opal;
