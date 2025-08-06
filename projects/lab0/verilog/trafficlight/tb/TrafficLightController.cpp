#include <verilated.h>

#include <cassert>
#include <chrono>
#include <cstdlib>  // for system("cls") or system("clear")
#include <fstream>
#include <iostream>
#include <string>
#include <thread>
#include <vector>

#include "VTrafficLightController.h"
#include "verilated_vcd_c.h"

using namespace std;
#define CYCLE 10

#define step(dut, fp, time)   \
    (fp)->dump(time);         \
    (time) += CYCLE / 2;      \
    (dut)->clk = !(dut)->clk; \
    (dut)->eval();

#define set_signal(dut, signal, value) \
    (signal) = (value);                \
    (dut)->eval();

void clearScreen() {
#ifdef _WIN32
    system("cls");
#else
    int ret = system("clear");
    (void)ret;  // suppress unused result warning
#endif
}

void set_golden(vector<bool>& red_golden, vector<bool>& yellow_golden, vector<bool>& green_golden,
                vector<int>& lefttime_golden) {
    vector<tuple<bool, bool, bool, int>> golden_values = {
        {false, false, false, 0},  // 21
        {true, false, false, 5},   // 20
        {true, false, false, 4},   // 19
        {true, false, false, 3},   // 18
        {true, false, false, 2},   // 17
        {true, false, false, 1},   // 16
        {false, false, true, 7},   // 15
        {false, false, true, 6},   // 14
        {false, false, true, 5},   // 13
        {false, false, true, 4},   // 12
        {false, false, true, 3},   // 11
        {false, false, true, 2},   // 10
        {false, false, true, 2},   // 9
        {false, false, true, 1},   // 8
        {false, true, false, 3},   // 7
        {false, true, false, 2},   // 6
        {false, true, false, 1},   // 5
        {true, false, false, 5},   // 4
        {true, false, false, 4},   // 3
        {true, false, false, 3},   // 2
        {true, false, false, 2},   // 1
    };

    for (size_t i = 0; i < golden_values.size(); ++i) {
        red_golden[i] = get<0>(golden_values[i]);
        yellow_golden[i] = get<1>(golden_values[i]);
        green_golden[i] = get<2>(golden_values[i]);
        lefttime_golden[i] = get<3>(golden_values[i]);
    }
}

// Show a traffic light with red, yellow, green lights on or off
void showTrafficLight(VTrafficLightController* dut) {
    clearScreen();
    if (dut->en == 0) {
        cout << "Watch out !!! Traffic light is disabled!" << endl;
    }
    if (int(dut->left_time) > 0) {
        cout << "This is a traffic light!" << endl << endl;
        cout << "======================" << endl;
        cout << "|| ";
        if (dut->red)
            cout << "🔴";
        else
            cout << "⚪";
        cout << " | ";
        if (dut->yellow)
            cout << "🟡";
        else
            cout << "⚪";
        cout << " | ";
        if (dut->green)
            cout << "🟢";
        else
            cout << "⚪";
        cout << " | " << int(dut->left_time) << " ||" << endl;
        cout << "======================" << endl;
        cout << "||" << endl;
        cout << "||" << endl;
        cout << "||" << endl;
        cout << "||" << endl;
        cout << "||" << endl;
        cout << "||" << endl;
        this_thread::sleep_for(std::chrono::seconds(1));
    }
}

void check(VTrafficLightController* dut, vector<bool>& red_golden, vector<bool>& yellow_golden, vector<bool>& green_golden,
           vector<int>& lefttime_golden, int& count, bool& pass) {
    cout << "Time: " << (20 - count) << " Expected: red = " << red_golden[21 - count]
         << ", yellow = " << yellow_golden[21 - count] << ", green = " << green_golden[21 - count]
         << ", lefttime = " << lefttime_golden[21 - count];
    if (dut->red != red_golden[21 - count] || dut->yellow != yellow_golden[21 - count] ||
        dut->green != green_golden[21 - count] || dut->left_time != lefttime_golden[21 - count]) {
        pass = false;
        cout << " Got: red = " << bool(dut->red) << ", yellow = " << bool(dut->yellow)
             << ", green = " << bool(dut->green) << ", left_time=" << bool(dut->left_time);
        cout << " Test failed" << endl;
    } else {
        cout << " Test passed" << endl;
    }
    --count;
}

int main() {
    vector<bool> red_golden(21, false);
    vector<bool> yellow_golden(21, false);
    vector<bool> green_golden(21, false);
    vector<int> lefttime_golden(21, 0);
    set_golden(red_golden, yellow_golden, green_golden, lefttime_golden);
    bool pass = true;
    int time = 0;

    Verilated::traceEverOn(true);
    VerilatedVcdC* fp = new VerilatedVcdC();
    auto dut = new VTrafficLightController;
    dut->trace(fp, 99);
    fp->open("wave/trafficlight_wave.vcd");
    set_signal(dut, dut->rst, 1);
    set_signal(dut, dut->clk, 0);
    step(dut, fp, time);
    // set config
    set_signal(dut, dut->rst, 0);
    set_signal(dut, dut->en, 1);
    set_signal(dut, dut->red_time_i, 5);
    set_signal(dut, dut->yellow_time_i, 3);
    set_signal(dut, dut->green_time_i, 7);
    step(dut, fp, time);
    step(dut, fp, time);

    int count = 20;

    while (count > 0) {
        step(dut, fp, time);
        if (!dut->clk) {
            if (count == 10) {
                set_signal(dut, dut->en, 0);
            } else {
                set_signal(dut, dut->en, 1);
            }
            showTrafficLight(dut);
            check(dut, red_golden, yellow_golden, green_golden, lefttime_golden, count, pass);
        }
    }

    if (pass) {
        ifstream inFile("../art/pass.txt");
        string line;
        while (getline(inFile, line)) {
            cout << line << endl;
        }
        inFile.close();
    } else {
        ifstream inFile("../art/fail.txt");
        string line;
        while (getline(inFile, line)) {
            cout << line << endl;
        }
        inFile.close();
    }

    fp->close();
    delete dut;
    delete fp;
    return 0;
}
