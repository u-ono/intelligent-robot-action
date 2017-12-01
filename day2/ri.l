#!/usr/bin/env roseus

(load "package://dxl_armed_turtlebot/euslisp/dxl-armed-turtlebot-interface.l")
(dxl-armed-turtlebot-init)
(load "package://daisya_euslisp_tutorials/euslisp/daisya-ik.l")

(do-until-key
 (send *dxl-armed-turtlebot* :angle-vector #f(0 0 0 0 0 0 0))
 (send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 500)
 (send *ri* :wait-interpolation)
)
