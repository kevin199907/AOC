// `DUMP_SIGNAL(file, posedge clock, 1, data, %h)
// dump SIGNAL when CONDITION is met
`define DUMP_SIGNAL(FILE, PERIOD, CONDITION, SIGNAL, FORMAT)  \
  always@(PERIOD) begin                                       \
    if (CONDITION) begin                                      \
      $fwrite(FILE, "SIGNAL =  FORMAT\n", SIGNAL);            \
    end                                                       \
  end                                               


// `DUMP_MEM()
`define DUMP_MEM(FILE, MEM, FROM, TO, FORMAT)                 \
  $fwrite(FILE, "// (MEM``0, MEM``1, MEM``2, MEM``3)\n");       \
  for (int idx = FROM; idx <= TO; idx = idx + 1) begin        \
      $fwrite(FILE, "MEM[%d] = FORMAT FORMAT FORMAT FORMAT\n", idx, MEM``0[idx], MEM``1[idx], MEM``2[idx], MEM``3[idx]); \
  end                                                         