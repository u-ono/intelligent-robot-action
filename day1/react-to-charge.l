#!/usr/bin/env roseus

(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "sensor_msgs")
(ros::load-ros-manifest "kobuki_msgs")

(ros::roseus "react-to-charge")

(ros::advertise "/mobile_base/commands/sound" kobuki_msgs::Sound 1)
(ros::rate 1)

(setq sound-msg (instance kobuki_msgs::Sound :init))
(send sound-msg :value 6)

(defun cb (msg)
    (setq percent (send msg :percentage))
    (if (< percent 20)
        (ros::publish "/mobile_base/commands/sound" sound-msg)
        nil))

(ros::subscribe "/laptop_charge" sensor_msgs::BatteryState #'cb)
(do-until-key
    (ros::sleep)
    (ros::spin-once))
(exit)
