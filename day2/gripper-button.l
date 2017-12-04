#!/usr/bin/env roseus

;;(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "kobuki_msgs")
(load "package://dxl_armed_turtlebot/euslisp/dxl-armed-turtlebot-interface.l")
(dxl-armed-turtlebot-init)
(load "package://daisya_euslisp_tutorials/euslisp/daisya-ik.l")
(ik-demo0 :robot *dxl-armed-turtlebot*)

(ros::roseus "gripper_button")

(defun cb (msg)
  (cond
   ((= (send msg :button) 0)
    (send *dxl-armed-turtlebot* :gripper :arm :angle-vector #f(50))
    (send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 1000 :gripper-controller)
    (send *ri* :wait-interpolation :gripper-controller)
    )
   ((= (send msg :button) 1)
    (send *ri* :start-grasp)
    (send *ri* :wait-interpolation :gripper-controller)
    )
   ((= (send msg :button) 2)
    (send *ri* :stop-grasp)
    (send *ri* :wait-interpolation :gripper-controller)
    )
   )
  )

(ros::subscribe "/mobile_base/events/button" kobuki_msgs::ButtonEvent #'cb)

(do-until-key
 (ros::spin-once)
 )
