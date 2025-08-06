# Lab0 - Python Programming Practice

## Smart Device Simulator

### Introduction

Bob is developing a smart home device simulator to model smart devices processing commands and reporting status via a callback function. He created an abstract `SmartDevice` class as a blueprint, with `LightDevice` and `TVDevice` inheriting and implementing operations. Now that Bob has fallen ill, his project hangs in the balance. Can you step in and bring his smart home device simulator to life?

### Requirements

#### 1. Complete the Implementation

Fill in the missing parts of the following class methods in `lab0/python/smart_device/main.py`:

- `device_name` (getter and setter) in the `SmartDevice` class.
- callback property in the `SmartDevice` class.
- operate method for `LightDevice` and `TVDevice` classes to properly handle device commands.

#### 2. Implement a Prime Channel Filter

The `TVDevice` operates with channel numbers, but Bob loves prime numbers. Help him create a filter to select prime-numbered channels from a given range (0 to 50).

### Expected Output

```plaintext
[Light] Turn ON
[Light] Turn OFF
[Light] Invalid command.
[Light2] Turn ON
[TV] Switched to channel 1
[TV] Invalid channel.
[TV] Switched to channel 2
[TV] Switched to channel 3
[TV] Switched to channel 5
[TV] Switched to channel 7
[TV] Switched to channel 11
[TV] Switched to channel 13
[TV] Switched to channel 17
[TV] Switched to channel 19
[TV] Switched to channel 23
[TV] Switched to channel 29
[TV] Switched to channel 31
[TV] Switched to channel 37
[TV] Switched to channel 41
[TV] Switched to channel 43
[TV] Switched to channel 47
```
