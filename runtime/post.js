
init();

})(undefined);

// if in a commonjs system already (node etc), exports become our opal
// object. Otherwise, in the browser, we just get a top level opal var
if ((typeof require !== 'undefined') && (typeof module !== 'undefined')) {
  module.exports = opalscript;
}
