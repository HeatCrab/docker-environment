#include <verilated.h>  // Include common routines

#include <cassert>
#include <fstream>
#include <iostream>

#include "VRippleCarryAdder.h"
#include "verilated_vcd_c.h"

using namespace std;

#define MAX_CYCLE 100000
#define CYCLE 10

#define step(dut, fp, time) \
    (fp)->dump(time);       \
    (time) += CYCLE / 2;    \
    (dut)->eval();

#define set_signal(dut, signal, value) \
    (signal) = (value);                \
    (dut)->eval();

void test(VRippleCarryAdder* dut, int test_a, int test_b, bool test_cin, bool& pass) {
    int64_t golden_sum = (int64_t)test_a + (int64_t)test_b + (int64_t)test_cin;
    golden_sum = golden_sum & 0xFFFFFFFF;         // Ensure golden_sum is 32-bit
    bool golden_cout = (golden_sum >> 32) & 0x1;  // Extract the carry-out bit
    set_signal(dut, dut->a, test_a);
    set_signal(dut, dut->b, test_b);
    set_signal(dut, dut->cin, test_cin);

    cout << "a: " << test_a << " b: " << test_b << " cin: " << test_cin << " -> ";
    if (dut->sum == golden_sum && dut->cout == golden_cout) {
        cout << "Simulation pass!" << endl;
    } else {
        cout << "sum: " << (int)dut->sum << " cout: " << (int)dut->cout << " (expected sum: " << golden_sum
             << " expected cout: " << golden_cout << ")" << endl;
        pass = false;
    }
}

int main(int argc, char** argv) {
    int time = 0;
    bool pass = true;

    Verilated::traceEverOn(true);
    VerilatedVcdC* fp = new VerilatedVcdC();

    auto dut = new VRippleCarryAdder;
    dut->trace(fp, 99);
    fp->open("wave/RippleCarryAdder.vcd");

    // Test
    test(dut, 5, 3, 0, pass);
    step(dut, fp, time);
    test(dut, -12243, 234, 0, pass);
    step(dut, fp, time);
    test(dut, 232114, 5434, 0, pass);
    step(dut, fp, time);
    test(dut, 0x7FFFFFFF, 1, 0, pass);
    step(dut, fp, time);

    string path = pass ? "../art/pass.txt" : "../art/fail.txt";
    ifstream in_file(path);
    string line;
    while (getline(in_file, line)) {
        cout << line << endl;
    }
    in_file.close();

    fp->close();
    dut->final();
    delete dut;
    return pass ? EXIT_SUCCESS : EXIT_FAILURE;
}
