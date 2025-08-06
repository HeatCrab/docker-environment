from abc import ABC, abstractmethod
from typing import Callable


# Abstract class for smart devices
class SmartDevice(ABC):
    def __init__(self, device_name: str, callback: Callable[[str, str], None]):
        self._device_name = device_name
        self._callback = callback

    @property
    def device_name(self):
        """ " Implement your code here"""

        pass

    @device_name.setter
    def device_name(self, new_name: str):
        """ " Implement your code here"""

        pass

    @property
    def callback(self):
        """ " Implement your code here"""

        pass

    @abstractmethod
    def operate(self, command):
        pass


class LightDevice(SmartDevice):
    def operate(self, command: str):
        """ " Implement your code here"""

        pass


class TVDevice(SmartDevice):
    def operate(self, command: int):
        """ " Implement your code here"""

        pass


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
    pass


# One-liner to change prime channels from 0 to n
n = 50

"""" Implement your code here """
channels = [""" Use one-liner to list prime channels from 0 to n """]
for channel in channels:
    tv.operate(channel)
