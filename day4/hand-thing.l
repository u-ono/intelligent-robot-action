#!/usr/bin/env roseus

(defun hand-thing ()
  (send *dxl-armed-turtlebot* :angle-vector #f(0.0 0.0 0.0 0.0 0.0 0.0 0.0))
  (send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 100)
  (send *ri* :wait-interpolation)

  (send *ri* :stop-grasp)
  (send *ri* :wait-interpolation :gripper-controller)
  (unix::usleep 1000000)
  
  t)
