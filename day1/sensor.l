#!/usr/bin/env roseus

;;(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "kobuki_msgs")

(ros::roseus "button_sensor")

(defun cb (msg)
  (describe (send msg :button))
  (describe (send msg :state)))
(ros::subscribe "/mobile_base/events/button" kobuki_msgs::ButtonEvent #'cb)

(ros::rate 10)

(do-until-key
 (ros::spin-once)
 (ros::sleep)
)

