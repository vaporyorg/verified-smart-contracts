requires "bihu-lemmas.k"

module {MODULE}-SPEC
  imports ETHEREUM-SIMULATION
  imports BIHU-LEMMAS

{RULES}

  // to avoid unnecessary case analyses
  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]

endmodule
