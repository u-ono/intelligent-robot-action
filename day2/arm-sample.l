#!/usr/bin/env roseus

(load "package://dxl_armed_turtlebot/euslisp/dxl-armed-turtlebot-interface.l")
(dxl-armed-turtlebot-init)
(load "package://dxl_armed_turtlebot/euslisp/arm-move-sample.l")
(dxl-arm-sample)

(dxl-arm-check)
