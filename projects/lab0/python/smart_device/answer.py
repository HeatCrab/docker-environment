from abc import ABC, abstractmethod
from typing import Callable


# Abstract class for smart devices
class SmartDevice(ABC):
    def __init__(self, device_name: str, callback: Callable[[str, str], None]):
        self._device_name = device_name
        self._callback = callback

    @property
    def device_name(self):
        return self._device_name

    @device_name.setter
    def device_name(self, new_name: str):
        if isinstance(new_name, str) and new_name.strip():
            self._device_name = new_name
        else:
            print("Invalid device name.")

    @property
    def callback(self):
        return self._callback

    @abstractmethod
    def operate(self, command):
        pass


class LightDevice(SmartDevice):
    def operate(self, command: str):
        if command.lower() == "on":
            result = "Turn ON"
        elif command.lower() == "off":
            result = "Turn OFF"
        else:
            result = "Invalid command."

        self.callback(self.device_name, result)


class TVDevice(SmartDevice):
    def operate(self, command: int):
        if command > 0:
            result = f"Switched to channel {command}"
        else:
            result = "Invalid channel."

        self.callback(self.device_name, result)


# Callback function for smart devices
def device_status(device_name, message):
    print(f"[{device_name}] {message}")


# Creating devices
light = LightDevice("Light", device_status)
tv = TVDevice("TV", device_status)

# Testing the devices
light.operate("on")
light.operate("off")
light.operate("turn to a car")

# change the device name
light.device_name = "Light2"
light.operate("on")

# Testing the TV
tv.operate(1)
tv.operate(0)


def is_prime(num):
    if num < 2:
        return False
    for i in range(2, num):
        if num % i == 0:
            return False
    return True


channels = [i for i in range(1, 50) if is_prime(i)]
for channel in channels:
    tv.operate(channel)
