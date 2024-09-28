# Demo in micro-python
These instructions assume micro-python on a Pi Pico. Most demos will work on the regular Pi Pico, whereas the HTTP Server examples require the wifi capabilities of the Pi Pico W.

## Http Robot
This uses the onboard wifi capabilities of the Pico W. To run this:
- Copy the files to the device. You will need:
  - `http_robot.py` - this is the code that drives the actual robot; interfaces with the Pico GPIOs, etc.
  - `http_server.py` - this is a really simple webserver implementation I wrote so that `http_robot.py` can do its thing.
  - `robot.css`, `robot.html` and `robot.css` - These are the web front-end for the robot. It handles user touches (or mouse input) and turns them into messages that are sent to the webserver.
  - `wifi.txt` - this will need editing for your network; the first line should contain the wireless network SSID, the second, the network passphrase
- Make sure you've edited that `wifi.txt` to suit your network.
- Run `http_robot.py` and watch the output. It'll probably give you some output like the example below:

```
Connecting to Network...
connected
ip = 192.168.1.212
Setting up webserver...
```

You'll use that IP address to connect from your computer or phone. Ensure the computer or phone are on the same wireless network as the robot, then navigate to `http://<server ip>/`. So, from the example above, you'd use `http://192.168.1.212/`

You can then (ensuring the battery is connected correctly to your bot) un-plug the USB cable and drive the bot using your phone or laptop.

To use the web controller, touch or click at the top of the page to move forward, at the bottom to move back and left / right to turn anticlockwise / clockwise respectively.

Hopefully, I'll get to clear this up in the not-too-distant future.