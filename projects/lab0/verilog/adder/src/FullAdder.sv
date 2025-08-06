module FullAdder (
    input logic a,
    input logic b,
    input logic cin,
    output logic sum,
    output logic cout
);
    // Implement this module using gate-level Verilolg

    logic xor1, and1, and2, and3;

    xor(xor1, a, b);
    xor(sum, xor1, cin);
    and(and1, a, b);
    and(and2, b, cin);
    and(and3, a, cin);
    or(cout, and1, and2, and3);

endmodule
